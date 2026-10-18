import mongoose from "mongoose";

import Order, {
    ORDER_STATUSES,
    DELIVERY_TYPES,
    DELIVERY_FEE,
    PAYMENT_METHODS,
    CANCEL_WINDOW_MINUTES,
    USER_CANCELLABLE_STATUSES,
    USER_CANCELLABLE_PAYMENT_STATUSES
} from "../models/orderModel.js";
import Product from "../models/productModel.js";
import Address from "../models/addressModel.js";
import Cart from "../models/cartModel.js";
import User from "../models/userModel.js";
import Point from "../models/pointsModel.js";
import Notification from "../models/notificationModel.js";

import {
    resolveCustomization,
    customizationPrice
} from "../utils/customization.js";

import { getDiscountResolver } from "../utils/promotions.js";

import {
    claimUserCoupon,
    releaseCouponForOrder
} from "../utils/coupons.js";

import { deleteCloudinaryImage } from "../utils/cloudinary.js";

import { pointsForOrder } from "../utils/rewardsConfig.js";

import { notifyAllAdmins, formatMoney } from "../utils/notify.js";

const MAX_NOTES_LENGTH = 300;

const PHONE_REGEX = /^\+?[0-9\s-]{7,15}$/;

const shortId = (order) =>
    order._id.toString().slice(-6).toUpperCase();

// ===================================
// STATUS FLOW
// ===================================
// PENDING → CONFIRMED → PREPARING → READY → OUT_FOR_DELIVERY → DELIVERED
// y CANCELLED desde cualquier estado que aún no sea final.
// Los pedidos "En local" (PICKUP) no pasan por OUT_FOR_DELIVERY:
// READY → DELIVERED. Los de envío (DELIVERY) sí deben pasar por él.
//
// Los pedidos por TRANSFER no avanzan (salvo cancelar) hasta que el
// admin valide el comprobante: validar el pago los pasa a CONFIRMED
// (ver orderPaymentController.js).

const NEXT_STATUSES = {
    PENDING: ["CONFIRMED", "CANCELLED"],
    CONFIRMED: ["PREPARING", "CANCELLED"],
    PREPARING: ["READY", "CANCELLED"],
    READY: ["OUT_FOR_DELIVERY", "DELIVERED", "CANCELLED"],
    OUT_FOR_DELIVERY: ["DELIVERED", "CANCELLED"],
    DELIVERED: [],
    CANCELLED: []
};

const allowedNextStatuses = (order) =>
    NEXT_STATUSES[order.status].filter(next => {
        if (next === "OUT_FOR_DELIVERY") {
            return order.deliveryType === "DELIVERY";
        }
        if (next === "DELIVERED" && order.status === "READY") {
            return order.deliveryType === "PICKUP";
        }
        return true;
    });

const statusNotification = (order, status) => {

    const id = `#${shortId(order)}`;

    switch (status) {
        case "CONFIRMED":
            return {
                title: "Pedido confirmado",
                message: `Tu pedido ${id} fue confirmado.`
            };
        case "PREPARING":
            return {
                title: "Estamos preparando tu pedido",
                message: `Tu pedido ${id} ya está en preparación.`
            };
        case "READY":
            return {
                title: "Tu pedido está listo",
                message: order.deliveryType === "PICKUP"
                    ? `Tu pedido ${id} está listo para recoger en el local.`
                    : `Tu pedido ${id} está listo y saldrá en breve.`
            };
        case "OUT_FOR_DELIVERY":
            return {
                title: "Tu pedido va en camino",
                message: `Tu pedido ${id} ya salió a entregarse.`
            };
        case "DELIVERED":
            return {
                title: "Pedido entregado",
                message: `Tu pedido ${id} fue entregado. ` +
                    `¡Ganaste ${pointsForOrder(order)} puntos!`
            };
        case "CANCELLED":
            return {
                title: "Pedido cancelado",
                message: `Tu pedido ${id} fue cancelado por el local.`
            };
        default:
            return null;
    }
};

// Punto único de efectos secundarios al cambiar de estado
// (notificación + puntos al entregar). Nunca debe romper el cambio de
// estado: si falla, solo se registra en el log.
const runStatusSideEffects = async (order, status) => {

    try {

        // Pedido cancelado: el cupón que se usó vuelve al cliente.
        if (status === "CANCELLED") {
            await releaseCouponForOrder(order._id);
        }

        if (status === "DELIVERED") {

            const alreadyAwarded = await Point.exists({
                orderId: order._id,
                type: "purchase"
            });

            if (!alreadyAwarded) {

                // 1 punto por cada $1.000 en productos (ver
                // utils/rewardsConfig.js).
                const earned = pointsForOrder(order);

                await User.findByIdAndUpdate(
                    order.userId,
                    { $inc: { points: earned } }
                );

                await Point.create({
                    userId: order.userId,
                    orderId: order._id,
                    amount: earned,
                    type: "purchase",
                    description: `Compra - pedido #${shortId(order)}`
                });
            }
        }

        const content = statusNotification(order, status);

        if (content) {
            await Notification.create({
                userId: order.userId,
                title: content.title,
                message: content.message,
                type: "ORDER",
                relatedId: order._id
            });
        }

    } catch (error) {

        console.error(
            "Order status side effects error:",
            error
        );

    }
};

// ===================================
// GET USER ORDERS
// ===================================
export const getUserOrders = async (req, res) => {

    try {

        const orders = await Order.find({
            userId: req.user.id
        })
            .populate("addressId")
            .sort({ createdAt: -1 });

        return res.status(200).json({
            message: "User orders retrieved successfully",
            orders
        });

    } catch (error) {

        console.error("Get user orders error:", error);

        return res.status(500).json({
            message: "Error retrieving user orders",
            error: error.message
        });

    }

};

// ===================================
// GET ORDER BY ID
// ===================================
export const getOrderById = async (req, res) => {

    try {

        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({
                message: "Invalid order id"
            });
        }

        const order =
            await Order.findById(req.params.id)
                .populate("addressId")
                .populate(
                    "userId",
                    "name lastName email phone"
                );

        if (!order) {
            return res.status(404).json({
                message: "Order not found"
            });
        }

        // USER CAN ONLY SEE THEIR OWN ORDER
        if (
            req.user.role !== "ADMIN" &&
            order.userId._id.toString() !==
            req.user.id.toString()
        ) {
            return res.status(403).json({
                message: "You are not authorized to access this order"
            });
        }

        return res.status(200).json({
            message: "Order retrieved successfully",
            order
        });

    } catch (error) {

        console.error("Get order error:", error);

        return res.status(500).json({
            message: "Error retrieving order",
            error: error.message
        });

    }

};

// ===================================
// CREATE ORDER
// ===================================
// El cliente solo manda QUÉ quiere (producto, cantidad, opciones) y
// DÓNDE/CÓMO (entrega, receptor, dirección, CASH o TRANSFER). Precios,
// personalizaciones, envío, descuento y total se calculan aquí.
export const createOrder = async (req, res) => {

    try {

        const {
            items,
            deliveryType,
            recipientName,
            recipientPhone,
            addressId,
            paymentMethod,
            couponId,
            notes
        } = req.body;

        // ===================================
        // DELIVERY
        // ===================================

        if (!DELIVERY_TYPES.includes(deliveryType)) {
            return res.status(400).json({
                message: "Delivery type must be PICKUP or DELIVERY"
            });
        }

        // ===================================
        // RECIPIENT
        // ===================================

        const name = (recipientName || "").toString().trim();
        const phone = (recipientPhone || "").toString().trim();

        if (!name) {
            return res.status(400).json({
                message: "Recipient name is required"
            });
        }

        if (!PHONE_REGEX.test(phone)) {
            return res.status(400).json({
                message: "A valid recipient phone is required"
            });
        }

        // ===================================
        // NOTES
        // ===================================

        const orderNotes = (notes || "").toString().trim();

        if (orderNotes.length > MAX_NOTES_LENGTH) {
            return res.status(400).json({
                message:
                    `Notes cannot exceed ${MAX_NOTES_LENGTH} characters`
            });
        }

        // ===================================
        // ADDRESS (solo para envío; debe ser del usuario)
        // ===================================

        let address = null;

        if (deliveryType === "DELIVERY") {

            if (
                !addressId ||
                !mongoose.isValidObjectId(addressId)
            ) {
                return res.status(400).json({
                    message: "Address is required for delivery"
                });
            }

            address = await Address.findOne({
                _id: addressId,
                userId: req.user.id
            });

            if (!address) {
                return res.status(404).json({
                    message: "Address not found"
                });
            }
        }

        // ===================================
        // PAYMENT METHOD (efectivo o transferencia)
        // ===================================

        if (!PAYMENT_METHODS.includes(paymentMethod)) {
            return res.status(400).json({
                message: "Payment method must be CASH or TRANSFER"
            });
        }

        // ===================================
        // ITEMS
        // ===================================

        if (
            !items ||
            !Array.isArray(items) ||
            items.length === 0
        ) {
            return res.status(400).json({
                message: "Order must contain at least one item"
            });
        }

        const productIds = [];

        for (const item of items) {
            if (
                !item ||
                !mongoose.isValidObjectId(item.productId)
            ) {
                return res.status(400).json({
                    message: "Invalid product id"
                });
            }
            productIds.push(item.productId.toString());
        }

        const uniqueIds = [...new Set(productIds)];

        const products = await Product.find({
            _id: { $in: uniqueIds }
        }).populate("categoryId", "name");

        if (products.length !== uniqueIds.length) {
            return res.status(404).json({
                message: "One or more products were not found"
            });
        }

        const orderItems = [];

        // Promociones vigentes para este usuario (se calculan aquí,
        // nunca se aceptan descuentos enviados por el cliente).
        const resolveDiscount =
            await getDiscountResolver(req.user.id);

        let subtotal = 0;
        let discount = 0;

        for (const item of items) {

            const product = products.find(
                p => p._id.toString() ===
                    item.productId.toString()
            );

            if (!product.isAvailable) {
                return res.status(400).json({
                    message: `Product ${product.name} is not available`
                });
            }

            const quantity = Number(item.quantity);

            if (
                !Number.isInteger(quantity) ||
                quantity < 1
            ) {
                return res.status(400).json({
                    message: "Product quantity must be at least 1"
                });
            }

            // Postres: se ignora cualquier personalización enviada.
            const { customization, error } =
                resolveCustomization(product, item.customization);

            if (error) {
                return res.status(400).json({ message: error });
            }

            const extra = customizationPrice(customization);

            const itemSubtotal =
                (product.price + extra) * quantity;

            const applied =
                resolveDiscount(product._id, product.price);

            const discountPerUnit =
                applied ? applied.discountPerUnit : 0;

            const itemDiscount = discountPerUnit * quantity;

            subtotal += itemSubtotal;
            discount += itemDiscount;

            orderItems.push({
                productId: product._id,
                name: product.name,
                image: product.images?.[0] || "",
                price: product.price,
                customizationPrice: extra,
                customization,
                quantity,
                discountPerUnit,
                discount: itemDiscount,
                promotionId: applied ? applied.promotion._id : null,
                promotionName: applied ? applied.promotion.name : "",
                subtotal: itemSubtotal
            });
        }

        // ===================================
        // TOTALS (calculados por el servidor)
        // ===================================
        // Se ignora cualquier shippingCost/discount que mande el
        // cliente. El descuento es la suma de las promociones
        // vigentes sobre los productos del pedido.

        const shippingCost =
            deliveryType === "DELIVERY" ? DELIVERY_FEE : 0;

        // ===================================
        // COUPON (recompensas)
        // ===================================
        // Se aplica sobre los productos YA con promociones (no sobre
        // el envío) y vale para cualquier producto. El servidor
        // valida dueño, estado, vencimiento y compra mínima, y lo
        // marca como usado de forma atómica.

        const orderId = new mongoose.Types.ObjectId();

        let usedCoupon = null;
        let couponDiscount = 0;

        if (couponId) {

            if (!mongoose.isValidObjectId(couponId)) {
                return res.status(400).json({
                    message: "Invalid coupon id"
                });
            }

            const claim = await claimUserCoupon({
                userCouponId: couponId,
                userId: req.user.id,
                merchandiseTotal: subtotal - discount,
                orderId
            });

            if (claim.error) {
                return res.status(400).json({
                    message: claim.error,
                    ...(claim.minimumPurchase !== undefined && {
                        minimumPurchase: claim.minimumPurchase
                    })
                });
            }

            usedCoupon = claim.userCoupon;
            couponDiscount = claim.discount;
        }

        const total = Math.max(
            0,
            subtotal + shippingCost - discount - couponDiscount
        );

        // ===================================
        // CREATE ORDER
        // ===================================

        let order;

        try {

            order = await Order.create({
                _id: orderId,
                userId: req.user.id,
                addressId: address ? address._id : null,
                addressSnapshot: address
                    ? {
                        label: address.label,
                        recipientName: address.recipientName,
                        phone: address.phone,
                        address: address.address,
                        city: address.city,
                        neighborhood: address.neighborhood,
                        additionalInfo: address.additionalInfo
                    }
                    : undefined,
                deliveryType,
                recipientName: name,
                recipientPhone: phone,
                items: orderItems,
                subtotal,
                shippingCost,
                discount,
                couponId: usedCoupon ? usedCoupon._id : null,
                couponName: usedCoupon ? usedCoupon.name : "",
                couponDiscount,
                total,
                paymentMethod,
                notes: orderNotes,
                status: "PENDING",
                // Efectivo se cobra al entregar; transferencia espera el
                // comprobante que sube el cliente.
                paymentStatus:
                    paymentMethod === "TRANSFER"
                        ? "AWAITING_PROOF"
                        : "PENDING"
            });

        } catch (createError) {

            // Si el pedido no se pudo crear, el cupón vuelve a
            // quedar disponible para el cliente.
            if (usedCoupon) {
                await releaseCouponForOrder(orderId);
            }

            throw createError;

        }

        // El carrito se vacía solo si el pedido se creó bien (si
        // Order.create hubiera fallado, nunca llegamos aquí).
        try {
            await Cart.updateOne(
                { userId: req.user.id },
                { $set: { items: [] } }
            );
        } catch (cartError) {
            console.error("Clear cart after order error:", cartError);
        }

        // Avisa a los administradores (push + notificaciones). Sin
        // await: no retrasa la respuesta al cliente.
        notifyAllAdmins({
            title: "Nuevo pedido",
            message:
                `Pedido #${shortId(order)} de ${name}: ` +
                `${deliveryType === "DELIVERY" ? "a domicilio" : "para recoger"}, ` +
                `${paymentMethod === "TRANSFER" ? "transferencia" : "efectivo"}, ` +
                `total ${formatMoney(total)}.`,
            type: "ORDER",
            relatedId: order._id
        });

        return res.status(201).json({
            message: "Order created successfully",
            order
        });

    } catch (error) {

        console.error("Create order error:", error);

        return res.status(500).json({
            message: "Error creating order",
            error: error.message
        });

    }

};

// ===================================
// GET ALL ORDERS - ADMIN
// ===================================
export const getAllOrders = async (req, res) => {

    try {

        const filter = {};

        if (req.query.status) {

            if (!ORDER_STATUSES.includes(req.query.status)) {
                return res.status(400).json({
                    message: "Invalid order status"
                });
            }

            filter.status = req.query.status;
        }

        const orders =
            await Order.find(filter)
                .populate(
                    "userId",
                    "name lastName email phone"
                )
                .populate("addressId")
                .sort({ createdAt: -1 });

        return res.status(200).json({
            message: "All orders retrieved successfully",
            orders
        });

    } catch (error) {

        console.error("Get all orders error:", error);

        return res.status(500).json({
            message: "Error retrieving orders",
            error: error.message
        });

    }

};

// ===================================
// UPDATE ORDER STATUS - ADMIN
// ===================================
export const updateOrderStatus = async (req, res) => {

    try {

        const { status } = req.body;

        if (!ORDER_STATUSES.includes(status)) {
            return res.status(400).json({
                message: "Invalid order status"
            });
        }

        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({
                message: "Invalid order id"
            });
        }

        const order = await Order.findById(req.params.id);

        if (!order) {
            return res.status(404).json({
                message: "Order not found"
            });
        }

        const allowed = allowedNextStatuses(order);

        if (!allowed.includes(status)) {
            return res.status(400).json({
                message:
                    `Cannot change order from ${order.status} to ${status}`,
                allowedStatuses: allowed
            });
        }

        // Un pedido por transferencia no se prepara ni se entrega
        // hasta que el admin valide el comprobante (cancelar sí se
        // puede siempre).
        if (
            status !== "CANCELLED" &&
            order.paymentMethod === "TRANSFER" &&
            order.paymentStatus !== "VALIDATED"
        ) {
            return res.status(400).json({
                message:
                    "The transfer payment must be validated before moving this order forward"
            });
        }

        const update = { status };

        if (status === "DELIVERED") {
            update.deliveredAt = new Date();
        }

        if (status === "CANCELLED") {
            update.cancelledAt = new Date();
        }

        // Condicionado al estado leído: si el cliente canceló (o
        // alguien más lo cambió) entre medio, no se pisa.
        const updated = await Order.findOneAndUpdate(
            { _id: order._id, status: order.status },
            { $set: update },
            { new: true }
        );

        if (!updated) {
            return res.status(409).json({
                message:
                    "The order status changed in the meantime. Reload and try again."
            });
        }

        await runStatusSideEffects(updated, status);

        return res.status(200).json({
            message: "Order status updated successfully",
            order: updated
        });

    } catch (error) {

        console.error("Update order status error:", error);

        return res.status(500).json({
            message: "Error updating order status",
            error: error.message
        });

    }

};

// ===================================
// CANCEL USER ORDER
// ===================================
// Reglas (todas verificadas aquí, no en Flutter):
//  - el pedido es del usuario
//  - estado cancelable (PENDING o CONFIRMED, como ya existía)
//  - sin comprobante de pago enviado (si ya pagó, solo el admin cancela)
//  - dentro de los CANCEL_WINDOW_MINUTES desde su creación
export const cancelOrder = async (req, res) => {

    try {

        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({
                message: "Invalid order id"
            });
        }

        const order = await Order.findById(req.params.id);

        if (!order) {
            return res.status(404).json({
                message: "Order not found"
            });
        }

        if (
            order.userId.toString() !==
            req.user.id.toString()
        ) {
            return res.status(403).json({
                message: "You are not authorized to cancel this order"
            });
        }

        if (!USER_CANCELLABLE_STATUSES.includes(order.status)) {
            return res.status(400).json({
                message: "This order can no longer be cancelled"
            });
        }

        if (
            !USER_CANCELLABLE_PAYMENT_STATUSES.includes(
                order.paymentStatus
            )
        ) {
            return res.status(400).json({
                message:
                    "This order can no longer be cancelled because its payment is already in review"
            });
        }

        const now = new Date();

        const windowStart = new Date(
            now.getTime() -
            CANCEL_WINDOW_MINUTES * 60 * 1000
        );

        // Cancelación atómica: el estado y la ventana se comprueban
        // en la misma operación que escribe CANCELLED, así un cambio
        // de estado del admin en ese instante no se pisa.
        const cancelled = await Order.findOneAndUpdate(
            {
                _id: order._id,
                userId: req.user.id,
                status: { $in: USER_CANCELLABLE_STATUSES },
                paymentStatus: {
                    $in: USER_CANCELLABLE_PAYMENT_STATUSES
                },
                createdAt: { $gte: windowStart }
            },
            {
                $set: {
                    status: "CANCELLED",
                    cancelledAt: now
                }
            },
            { new: true }
        );

        if (!cancelled) {

            // Si el estado sigue siendo cancelable, lo que falló es
            // el tiempo.
            const fresh = await Order.findById(order._id);

            if (
                fresh &&
                USER_CANCELLABLE_STATUSES.includes(fresh.status)
            ) {
                return res.status(400).json({
                    message:
                        `The ${CANCEL_WINDOW_MINUTES}-minute cancellation window has expired`
                });
            }

            return res.status(400).json({
                message: "This order can no longer be cancelled"
            });
        }

        // El cupón que se usó en este pedido vuelve al cliente.
        await releaseCouponForOrder(cancelled._id);

        return res.status(200).json({
            message: "Order cancelled successfully",
            order: cancelled
        });

    } catch (error) {

        console.error("Cancel order error:", error);

        return res.status(500).json({
            message: "Error cancelling order",
            error: error.message
        });

    }

};

// ===================================
// DELETE ORDER - ADMIN
// ===================================
// Solo se pueden eliminar pedidos CANCELLED. Un pedido entregado es
// historial de ventas y de puntos, no se borra.
export const deleteOrder = async (req, res) => {

    try {

        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({
                message: "Invalid order id"
            });
        }

        const order = await Order.findById(req.params.id);

        if (!order) {
            return res.status(404).json({
                message: "Order not found"
            });
        }

        if (order.status !== "CANCELLED") {
            return res.status(400).json({
                message: "Only cancelled orders can be deleted"
            });
        }

        // El comprobante es un archivo en Cloudinary: se borra junto
        // con el pedido para no dejar huérfanos.
        if (order.paymentProof?.url) {
            await deleteCloudinaryImage(order.paymentProof.url);
        }

        await order.deleteOne();

        return res.status(200).json({
            message: "Order deleted successfully"
        });

    } catch (error) {

        console.error("Delete order error:", error);

        return res.status(500).json({
            message: "Error deleting order",
            error: error.message
        });

    }

};
