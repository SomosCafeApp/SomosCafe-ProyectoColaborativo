import crypto from "crypto";
import mongoose from "mongoose";

import Coupon, {
    COUPON_DISCOUNT_TYPES,
    COUPON_KINDS,
    AUTO_COUPON_KINDS
} from "../models/couponModel.js";
import UserCoupon from "../models/userCouponModel.js";
import User from "../models/userModel.js";
import Point from "../models/pointsModel.js";

import {
    userCouponStatus,
    couponDiscountText
} from "../utils/coupons.js";
import { notifyAllCustomers } from "../utils/notify.js";

const DAY_MS = 24 * 60 * 60 * 1000;

const isExhausted = (coupon) =>
    coupon.redeemLimit !== null &&
    coupon.redeemLimit !== undefined &&
    coupon.redeemedCount >= coupon.redeemLimit;

// ===================================
// NOTIFY NEW COUPON (push + pantalla de notificaciones)
// ===================================
// Avisa a todos los clientes activos cuando se agrega un cupón o
// cuando el admin lo reactiva. No se espera (no retrasa la respuesta)
// y nunca lanza error.
const notifyCoupon = (coupon, { reactivated = false } = {}) => {

    const discountText = couponDiscountText(coupon);

    notifyAllCustomers({
        title: reactivated
            ? "¡Volvió un cupón!"
            : "Nuevo cupón disponible",
        message:
            `${coupon.name}: ${discountText}. ` +
            `Canjéalo por ${coupon.pointsCost} puntos.`,
        type: "REWARD",
        relatedId: coupon._id
    });

};

// ===================================
// VALIDATE BODY (crear y editar)
// ===================================
const toNumberOrNull = (value) =>
    value === undefined || value === null || value === ""
        ? null
        : Number(value);

const parseCouponBody = (body, forcedKind = null) => {

    const kind = forcedKind || body.kind || "REWARD";
    const isAuto = AUTO_COUPON_KINDS.includes(kind);

    const name = (body.name || "").toString().trim();
    const description = (body.description || "").toString().trim();
    const { discountType } = body;

    const discountValue = Number(body.discountValue);
    // Los cupones de regalo no cuestan puntos ni tienen límite.
    const pointsCost = isAuto ? 0 : Number(body.pointsCost);
    const minimumPurchase = toNumberOrNull(body.minimumPurchase) ?? 0;
    const maximumDiscount = toNumberOrNull(body.maximumDiscount);
    const redeemLimit = isAuto ? null : toNumberOrNull(body.redeemLimit);
    const validDays = toNumberOrNull(body.validDays);

    if (!name) {
        return { error: "Name is required" };
    }

    if (name.length > 60) {
        return { error: "Name cannot exceed 60 characters" };
    }

    if (description.length > 140) {
        return { error: "Description cannot exceed 140 characters" };
    }

    if (!COUPON_KINDS.includes(kind)) {
        return { error: "Invalid coupon kind" };
    }

    if (!COUPON_DISCOUNT_TYPES.includes(discountType)) {
        return { error: "Invalid discount type" };
    }

    if (!Number.isFinite(discountValue) || discountValue <= 0) {
        return { error: "Discount value must be greater than zero" };
    }

    if (discountType === "percentage" && discountValue > 100) {
        return { error: "Percentage discount cannot exceed 100" };
    }

    if (!isAuto && (!Number.isInteger(pointsCost) || pointsCost < 1)) {
        return { error: "Points cost must be a whole number greater than zero" };
    }

    if (!Number.isFinite(minimumPurchase) || minimumPurchase < 0) {
        return { error: "Minimum purchase cannot be negative" };
    }

    if (
        maximumDiscount !== null &&
        (!Number.isFinite(maximumDiscount) || maximumDiscount <= 0)
    ) {
        return { error: "Maximum discount must be greater than zero" };
    }

    if (
        redeemLimit !== null &&
        (!Number.isInteger(redeemLimit) || redeemLimit < 1)
    ) {
        return { error: "Redeem limit must be a whole number greater than zero" };
    }

    if (
        validDays !== null &&
        (!Number.isInteger(validDays) || validDays < 1 || validDays > 365)
    ) {
        return { error: "Valid days must be between 1 and 365" };
    }

    return {
        data: {
            kind,
            name,
            description,
            discountType,
            discountValue,
            // El tope solo aplica a descuentos en porcentaje.
            maximumDiscount:
                discountType === "percentage" ? maximumDiscount : null,
            minimumPurchase,
            pointsCost,
            redeemLimit,
            validDays
        }
    };

};

// Lo que ve el cliente del catálogo.
const catalogItem = (coupon, alreadyRedeemed) => ({
    id: coupon._id,
    name: coupon.name,
    description: coupon.description,
    discountType: coupon.discountType,
    discountValue: coupon.discountValue,
    maximumDiscount: coupon.maximumDiscount,
    minimumPurchase: coupon.minimumPurchase,
    pointsCost: coupon.pointsCost,
    validDays: coupon.validDays,
    remaining:
        coupon.redeemLimit === null
            ? null
            : Math.max(0, coupon.redeemLimit - coupon.redeemedCount),
    soldOut: isExhausted(coupon),
    alreadyRedeemed
});

// Lo que ve el cliente de un cupón ya canjeado.
const userCouponItem = (userCoupon) => ({
    id: userCoupon._id,
    couponId: userCoupon.couponId,
    code: userCoupon.code,
    source: userCoupon.source || "REDEEM",
    name: userCoupon.name,
    description: userCoupon.description,
    discountType: userCoupon.discountType,
    discountValue: userCoupon.discountValue,
    maximumDiscount: userCoupon.maximumDiscount,
    minimumPurchase: userCoupon.minimumPurchase,
    pointsSpent: userCoupon.pointsSpent,
    status: userCouponStatus(userCoupon),
    expiresAt: userCoupon.expiresAt,
    usedAt: userCoupon.usedAt,
    createdAt: userCoupon.createdAt
});

// ===================================
// GET CATALOG - USER
// ===================================
// Cupones habilitados. Incluye los agotados (el cliente los ve como
// "Agotado") y marca los que él ya canjeó en el ciclo actual.
export const getCouponCatalog = async (req, res) => {

    try {

        // Los cupones de regalo (bienvenida / cumpleaños) no se canjean.
        const coupons = await Coupon.find({
            isActive: true,
            kind: { $nin: AUTO_COUPON_KINDS }
        }).sort({ pointsCost: 1, createdAt: -1 });

        const redeemed = await UserCoupon.find({
            userId: req.user.id,
            couponId: { $in: coupons.map(c => c._id) }
        }).select("couponId cycle");

        const redeemedKeys = new Set(
            redeemed.map(r => `${r.couponId}:${r.cycle}`)
        );

        return res.status(200).json({
            message: "Coupons retrieved successfully",
            coupons: coupons.map(coupon =>
                catalogItem(
                    coupon,
                    redeemedKeys.has(`${coupon._id}:${coupon.cycle}`)
                )
            )
        });

    } catch (error) {

        console.error("Get coupon catalog error:", error);

        return res.status(500).json({
            message: "Error retrieving coupons",
            error: error.message
        });

    }

};

// ===================================
// GET MY COUPONS - USER
// ===================================
export const getMyCoupons = async (req, res) => {

    try {

        const userCoupons = await UserCoupon.find({
            userId: req.user.id
        }).sort({ createdAt: -1 });

        return res.status(200).json({
            message: "User coupons retrieved successfully",
            coupons: userCoupons.map(userCouponItem)
        });

    } catch (error) {

        console.error("Get my coupons error:", error);

        return res.status(500).json({
            message: "Error retrieving user coupons",
            error: error.message
        });

    }

};

// ===================================
// REDEEM COUPON - USER
// ===================================
// Canjear = gastar puntos + recibir el cupón. Todo se hace con
// operaciones atómicas (sin confiar en lo que mande el cliente):
//   1. se reserva un cupo del límite del cupón
//   2. se descuentan los puntos (solo si alcanzan)
//   3. se crea el cupón del usuario (índice único = 1 por persona
//      por ciclo)
// Si un paso falla, se deshacen los anteriores.
export const redeemCoupon = async (req, res) => {

    try {

        const { id } = req.params;

        if (!mongoose.isValidObjectId(id)) {
            return res.status(400).json({
                message: "Invalid coupon id"
            });
        }

        const userId = req.user.id;

        const coupon = await Coupon.findById(id);

        if (
            !coupon ||
            !coupon.isActive ||
            AUTO_COUPON_KINDS.includes(coupon.kind)
        ) {
            return res.status(404).json({
                message: "Coupon not available"
            });
        }

        const alreadyRedeemed = await UserCoupon.exists({
            userId,
            couponId: coupon._id,
            cycle: coupon.cycle
        });

        if (alreadyRedeemed) {
            return res.status(409).json({
                message: "You already redeemed this coupon"
            });
        }

        const user = await User.findById(userId).select("points");

        if (!user) {
            return res.status(404).json({
                message: "User not found"
            });
        }

        if (user.points < coupon.pointsCost) {
            return res.status(400).json({
                message: "Insufficient points"
            });
        }

        // 1. Reservar un cupo.
        const reserved = await Coupon.findOneAndUpdate(
            {
                _id: coupon._id,
                isActive: true,
                cycle: coupon.cycle,
                $or: [
                    { redeemLimit: null },
                    { $expr: { $lt: ["$redeemedCount", "$redeemLimit"] } }
                ]
            },
            { $inc: { redeemedCount: 1 } },
            { new: true }
        );

        if (!reserved) {
            return res.status(409).json({
                message: "Coupon sold out"
            });
        }

        const releaseSlot = () =>
            Coupon.updateOne(
                { _id: coupon._id, cycle: coupon.cycle },
                { $inc: { redeemedCount: -1 } }
            );

        // 2. Cobrar los puntos (solo si siguen alcanzando).
        const charged = await User.findOneAndUpdate(
            { _id: userId, points: { $gte: coupon.pointsCost } },
            { $inc: { points: -coupon.pointsCost } },
            { new: true }
        );

        if (!charged) {
            await releaseSlot();

            return res.status(400).json({
                message: "Insufficient points"
            });
        }

        // 3. Crear el cupón del usuario.
        let userCoupon;

        try {

            userCoupon = await UserCoupon.create({
                userId,
                couponId: coupon._id,
                cycle: coupon.cycle,
                code:
                    "CP-" +
                    crypto.randomBytes(4).toString("hex").toUpperCase(),
                name: coupon.name,
                description: coupon.description,
                discountType: coupon.discountType,
                discountValue: coupon.discountValue,
                maximumDiscount: coupon.maximumDiscount,
                minimumPurchase: coupon.minimumPurchase,
                pointsSpent: coupon.pointsCost,
                expiresAt: coupon.validDays
                    ? new Date(Date.now() + coupon.validDays * DAY_MS)
                    : null
            });

        } catch (createError) {

            // Deshacer: devolver puntos y cupo.
            await User.updateOne(
                { _id: userId },
                { $inc: { points: coupon.pointsCost } }
            );
            await releaseSlot();

            if (createError.code === 11000) {
                return res.status(409).json({
                    message: "You already redeemed this coupon"
                });
            }

            throw createError;

        }

        // Historial de puntos (si falla no se pierde el canje).
        try {

            await Point.create({
                userId,
                amount: -coupon.pointsCost,
                type: "redeemed",
                description: `Cupón: ${coupon.name}`
            });

        } catch (historyError) {

            console.error(
                "Coupon points history error:",
                historyError
            );

        }

        return res.status(201).json({
            message: "Coupon redeemed successfully",
            currentBalance: charged.points,
            coupon: userCouponItem(userCoupon)
        });

    } catch (error) {

        console.error("Redeem coupon error:", error);

        return res.status(500).json({
            message: "Error redeeming coupon",
            error: error.message
        });

    }

};

// ===================================
// GET ALL COUPONS - ADMIN
// ===================================
export const getAllCoupons = async (req, res) => {

    try {

        const coupons = await Coupon.find().sort({ createdAt: -1 });

        return res.status(200).json({
            message: "Coupons retrieved successfully",
            coupons: coupons.map(coupon => ({
                ...coupon.toObject(),
                soldOut: isExhausted(coupon)
            }))
        });

    } catch (error) {

        console.error("Get all coupons error:", error);

        return res.status(500).json({
            message: "Error retrieving coupons",
            error: error.message
        });

    }

};

// ===================================
// CREATE COUPON - ADMIN
// ===================================
export const createCoupon = async (req, res) => {

    try {

        const { data, error } = parseCouponBody(req.body);

        if (error) {
            return res.status(400).json({ message: error });
        }

        // Solo uno habilitado de cada tipo de regalo.
        if (AUTO_COUPON_KINDS.includes(data.kind)) {

            const existing = await Coupon.exists({
                kind: data.kind,
                isActive: true
            });

            if (existing) {
                return res.status(409).json({
                    message:
                        "There is already an active coupon of this type"
                });
            }

        }

        const coupon = await Coupon.create({
            ...data,
            isActive: true
        });

        // Aviso a todos los clientes (push + notificaciones). Los
        // cupones de regalo no se anuncian: se entregan solos.
        if (!AUTO_COUPON_KINDS.includes(coupon.kind)) {
            notifyCoupon(coupon);
        }

        return res.status(201).json({
            message: "Coupon created successfully",
            coupon
        });

    } catch (error) {

        console.error("Create coupon error:", error);

        return res.status(500).json({
            message: "Error creating coupon",
            error: error.message
        });

    }

};

// ===================================
// UPDATE COUPON - ADMIN
// ===================================
// Editar NO afecta a los cupones ya canjeados (guardan su propia
// foto de las condiciones).
export const updateCoupon = async (req, res) => {

    try {

        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({
                message: "Invalid coupon id"
            });
        }

        const coupon = await Coupon.findById(req.params.id);

        if (!coupon) {
            return res.status(404).json({
                message: "Coupon not found"
            });
        }

        // El tipo no se puede cambiar después de crearlo.
        const { data, error } = parseCouponBody(req.body, coupon.kind);

        if (error) {
            return res.status(400).json({ message: error });
        }

        if (
            data.redeemLimit !== null &&
            data.redeemLimit < coupon.redeemedCount
        ) {
            return res.status(400).json({
                message:
                    "Redeem limit cannot be lower than the number already redeemed"
            });
        }

        coupon.set(data);

        await coupon.save();

        return res.status(200).json({
            message: "Coupon updated successfully",
            coupon
        });

    } catch (error) {

        console.error("Update coupon error:", error);

        return res.status(500).json({
            message: "Error updating coupon",
            error: error.message
        });

    }

};

// ===================================
// ENABLE / DISABLE / REACTIVATE COUPON - ADMIN
// ===================================
// Deshabilitar: deja de verse en el catálogo (los ya canjeados
// siguen siendo válidos).
// Habilitar un cupón deshabilitado o agotado = REACTIVAR: empieza un
// ciclo nuevo (contador de canjes en 0) y quienes ya lo canjearon
// pueden canjearlo otra vez, una vez más. También se notifica.
export const setCouponStatus = async (req, res) => {

    try {

        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({
                message: "Invalid coupon id"
            });
        }

        const { isActive } = req.body;

        if (typeof isActive !== "boolean") {
            return res.status(400).json({
                message: "isActive must be true or false"
            });
        }

        const coupon = await Coupon.findById(req.params.id);

        if (!coupon) {
            return res.status(404).json({
                message: "Coupon not found"
            });
        }

        if (!isActive) {

            coupon.isActive = false;
            await coupon.save();

            return res.status(200).json({
                message: "Coupon disabled successfully",
                coupon
            });

        }

        const isAuto = AUTO_COUPON_KINDS.includes(coupon.kind);

        // Solo uno habilitado de cada tipo de regalo.
        if (isAuto && !coupon.isActive) {

            const other = await Coupon.exists({
                kind: coupon.kind,
                isActive: true,
                _id: { $ne: coupon._id }
            });

            if (other) {
                return res.status(409).json({
                    message:
                        "There is already an active coupon of this type"
                });
            }

        }

        const reactivating =
            !coupon.isActive || isExhausted(coupon);

        if (reactivating) {
            coupon.isActive = true;

            // Los de regalo no tienen rondas: solo se vuelven a habilitar.
            if (!isAuto) {
                coupon.cycle += 1;
                coupon.redeemedCount = 0;
            }

            await coupon.save();

            if (!isAuto) {
                notifyCoupon(coupon, { reactivated: true });
            }
        }

        return res.status(200).json({
            message: reactivating
                ? "Coupon reactivated successfully"
                : "Coupon is already active",
            coupon
        });

    } catch (error) {

        console.error("Set coupon status error:", error);

        return res.status(500).json({
            message: "Error updating coupon status",
            error: error.message
        });

    }

};

// ===================================
// DELETE COUPON - ADMIN
// ===================================
// Los cupones que ya canjearon los clientes siguen funcionando.
export const deleteCoupon = async (req, res) => {

    try {

        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({
                message: "Invalid coupon id"
            });
        }

        const coupon = await Coupon.findByIdAndDelete(req.params.id);

        if (!coupon) {
            return res.status(404).json({
                message: "Coupon not found"
            });
        }

        return res.status(200).json({
            message: "Coupon deleted successfully"
        });

    } catch (error) {

        console.error("Delete coupon error:", error);

        return res.status(500).json({
            message: "Error deleting coupon",
            error: error.message
        });

    }

};
