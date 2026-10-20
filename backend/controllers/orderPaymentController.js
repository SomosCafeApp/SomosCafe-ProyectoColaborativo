import mongoose from "mongoose";

import Order from "../models/orderModel.js";
import User from "../models/userModel.js";
import Notification from "../models/notificationModel.js";

import { deleteCloudinaryImage } from "../utils/cloudinary.js";
import { releaseCouponForOrder } from "../utils/coupons.js";

// ===================================
// PAYMENT FLOW (transferencia por QR)
// ===================================
// AWAITING_PROOF → (cliente sube captura) → PROOF_SUBMITTED
//   → (admin valida)   → VALIDATED   + pedido CONFIRMED
//   → (admin invalida) → INVALIDATED + pedido CANCELLED
//
// El efectivo no pasa por aquí: se cobra al entregar o en el local.

const shortId = (order) =>
    order._id.toString().slice(-6).toUpperCase();

// Estados en los que el cliente todavía puede subir (o reemplazar)
// su comprobante.
const PROOF_EDITABLE_STATUSES = [
    "AWAITING_PROOF",
    "PROOF_SUBMITTED"
];

// Estados en los que el admin aún puede invalidar el pago.
const INVALIDATABLE_STATUSES = [
    "PROOF_SUBMITTED",
    "VALIDATED"
];

// Una notificación nunca debe romper la acción principal.
const safeNotify = async (payload) => {

    try {

        await Notification.create({
            type: "ORDER",
            ...payload
        });

    } catch (error) {

        console.error(
            "Payment notification error:",
            error
        );

    }

};

const notifyAdmins = async (order) => {

    try {

        const admins = await User.find({ role: "ADMIN" })
            .select("_id");

        if (admins.length === 0) return;

        await Notification.insertMany(
            admins.map(admin => ({
                userId: admin._id,
                title: "Comprobante por validar",
                message:
                    `El pedido #${shortId(order)} tiene un ` +
                    "comprobante de pago esperando tu revisión.",
                type: "ORDER",
                relatedId: order._id
            }))
        );

    } catch (error) {

        console.error(
            "Notify admins error:",
            error
        );

    }

};

// multer ya subió el archivo a Cloudinary antes de llegar aquí: si
// la petición se rechaza, hay que borrarlo para no dejarlo huérfano.
const rejectUpload = async (req, res, status, message) => {

    if (req.file?.path) {
        await deleteCloudinaryImage(req.file.path);
    }

    return res.status(status).json({ message });

};

// ===================================
// UPLOAD PAYMENT PROOF - USER
// ===================================
export const uploadPaymentProof = async (req, res) => {

    try {

        if (!mongoose.isValidObjectId(req.params.id)) {
            return rejectUpload(
                req, res, 400, "ID de pedido inválido"
            );
        }

        if (!req.file?.path) {
            return res.status(400).json({
                message: "La imagen del comprobante de pago es obligatoria"
            });
        }

        const order = await Order.findById(req.params.id);

        if (!order) {
            return rejectUpload(
                req, res, 404, "Pedido no encontrado"
            );
        }

        if (order.userId.toString() !== req.user.id.toString()) {
            return rejectUpload(
                req, res, 403,
                "No tienes autorización para actualizar este pedido"
            );
        }

        if (order.paymentMethod !== "TRANSFER") {
            return rejectUpload(
                req, res, 400,
                "Este pedido no se paga por transferencia"
            );
        }

        if (order.status === "CANCELLED") {
            return rejectUpload(
                req, res, 400,
                "Este pedido fue cancelado"
            );
        }

        if (!PROOF_EDITABLE_STATUSES.includes(order.paymentStatus)) {
            return rejectUpload(
                req, res, 400,
                "El comprobante de pago ya no se puede cambiar"
            );
        }

        const previousUrl = order.paymentProof?.url || null;

        // Atómico: si el admin validó o canceló justo en este
        // instante, no se pisa su decisión.
        const updated = await Order.findOneAndUpdate(
            {
                _id: order._id,
                userId: req.user.id,
                paymentMethod: "TRANSFER",
                paymentStatus: { $in: PROOF_EDITABLE_STATUSES },
                status: { $ne: "CANCELLED" }
            },
            {
                $set: {
                    paymentProof: {
                        url: req.file.path,
                        uploadedAt: new Date()
                    },
                    paymentStatus: "PROOF_SUBMITTED"
                }
            },
            { new: true }
        );

        if (!updated) {
            return rejectUpload(
                req, res, 409,
                "El pedido cambió mientras tanto. Recarga e inténtalo de nuevo."
            );
        }

        // Si reemplazó un comprobante anterior, el viejo se borra.
        if (previousUrl) {
            await deleteCloudinaryImage(previousUrl);
        }

        await notifyAdmins(updated);

        return res.status(200).json({
            message: "Comprobante de pago subido correctamente",
            order: updated
        });

    } catch (error) {

        console.error("Upload payment proof error:", error);

        if (req.file?.path) {
            await deleteCloudinaryImage(req.file.path);
        }

        return res.status(500).json({
            message: "Error al subir el comprobante de pago",
            error: error.message
        });

    }

};

// ===================================
// VALIDATE PAYMENT - ADMIN
// ===================================
export const validatePayment = async (req, res) => {

    try {

        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({
                message: "ID de pedido inválido"
            });
        }

        const order = await Order.findById(req.params.id);

        if (!order) {
            return res.status(404).json({
                message: "Pedido no encontrado"
            });
        }

        if (order.paymentMethod !== "TRANSFER") {
            return res.status(400).json({
                message: "Solo se pueden validar pagos por transferencia"
            });
        }

        if (order.status === "CANCELLED") {
            return res.status(400).json({
                message: "Este pedido fue cancelado"
            });
        }

        if (order.paymentStatus !== "PROOF_SUBMITTED") {
            return res.status(400).json({
                message: "No hay un comprobante de pago esperando validación"
            });
        }

        const update = {
            paymentStatus: "VALIDATED",
            paymentReviewedAt: new Date()
        };

        // Pago validado = pedido aceptado. De ahí en adelante el
        // admin sigue el flujo normal (preparar, listo, entregar).
        if (order.status === "PENDING") {
            update.status = "CONFIRMED";
        }

        const updated = await Order.findOneAndUpdate(
            {
                _id: order._id,
                paymentStatus: "PROOF_SUBMITTED",
                status: order.status
            },
            { $set: update },
            { new: true }
        );

        if (!updated) {
            return res.status(409).json({
                message:
                    "El pedido cambió mientras tanto. Recarga e inténtalo de nuevo."
            });
        }

        await safeNotify({
            userId: updated.userId,
            title: "Pago validado",
            message:
                `Validamos el pago de tu pedido #${shortId(updated)}. ` +
                "¡Comenzamos a preparar tu café!",
            relatedId: updated._id
        });

        return res.status(200).json({
            message: "Pago validado correctamente",
            order: updated
        });

    } catch (error) {

        console.error("Validate payment error:", error);

        return res.status(500).json({
            message: "Error al validar el pago",
            error: error.message
        });

    }

};

// ===================================
// INVALIDATE PAYMENT - ADMIN
// ===================================
// Comprobante falso o que no corresponde: el pago se invalida y el
// pedido se cancela automáticamente.
export const invalidatePayment = async (req, res) => {

    try {

        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({
                message: "ID de pedido inválido"
            });
        }

        const order = await Order.findById(req.params.id);

        if (!order) {
            return res.status(404).json({
                message: "Pedido no encontrado"
            });
        }

        if (order.paymentMethod !== "TRANSFER") {
            return res.status(400).json({
                message: "Solo se pueden invalidar pagos por transferencia"
            });
        }

        if (!INVALIDATABLE_STATUSES.includes(order.paymentStatus)) {
            return res.status(400).json({
                message: "No hay un comprobante de pago para invalidar"
            });
        }

        if (
            order.status === "CANCELLED" ||
            order.status === "DELIVERED"
        ) {
            return res.status(400).json({
                message:
                    "Este pedido ya está cerrado y no se puede modificar"
            });
        }

        const now = new Date();

        const updated = await Order.findOneAndUpdate(
            {
                _id: order._id,
                paymentStatus: order.paymentStatus,
                status: order.status
            },
            {
                $set: {
                    paymentStatus: "INVALIDATED",
                    paymentReviewedAt: now,
                    status: "CANCELLED",
                    cancelledAt: now
                }
            },
            { new: true }
        );

        if (!updated) {
            return res.status(409).json({
                message:
                    "El pedido cambió mientras tanto. Recarga e inténtalo de nuevo."
            });
        }

        // Pedido cancelado: el cupón que se usó vuelve al cliente.
        await releaseCouponForOrder(updated._id);

        await safeNotify({
            userId: updated.userId,
            title: "Pago no validado",
            message:
                `No pudimos validar el comprobante de tu pedido ` +
                `#${shortId(updated)}, por eso fue cancelado. ` +
                "Si crees que es un error, comunícate con la cafetería.",
            relatedId: updated._id
        });

        return res.status(200).json({
            message: "Pago invalidado y pedido cancelado",
            order: updated
        });

    } catch (error) {

        console.error("Invalidate payment error:", error);

        return res.status(500).json({
            message: "Error al invalidar el pago",
            error: error.message
        });

    }

};
