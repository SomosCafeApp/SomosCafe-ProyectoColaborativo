import crypto from "crypto";

import Coupon from "../models/couponModel.js";
import UserCoupon from "../models/userCouponModel.js";

import { notifyUsers, formatMoney } from "./notify.js";

const DAY_MS = 24 * 60 * 60 * 1000;

// ===================================
// COUPON HELPERS
// ===================================

// Descuento (en pesos enteros) que da un cupón sobre [base], que es el
// total de PRODUCTOS del pedido ya con las promociones aplicadas
// (el envío nunca se descuenta). Sirve igual con un Coupon o con un
// UserCoupon: ambos guardan los mismos campos de descuento.
export const couponDiscountFor = (coupon, base) => {

    let discount =
        coupon.discountType === "percentage"
            ? base * (coupon.discountValue / 100)
            : coupon.discountValue;

    if (
        coupon.maximumDiscount !== null &&
        coupon.maximumDiscount !== undefined
    ) {
        discount = Math.min(discount, coupon.maximumDiscount);
    }

    discount = Math.min(discount, base);

    return Math.max(0, Math.round(discount));

};

export const isUserCouponExpired = (userCoupon, now = new Date()) =>
    !!userCoupon.expiresAt && userCoupon.expiresAt <= now;

// Estado que ve el cliente: AVAILABLE | USED | EXPIRED.
export const userCouponStatus = (userCoupon, now = new Date()) => {

    if (userCoupon.status === "USED") return "USED";

    return isUserCouponExpired(userCoupon, now)
        ? "EXPIRED"
        : "AVAILABLE";

};

// ===================================
// CLAIM (usar un cupón en un pedido)
// ===================================
// Valida que el cupón sea del usuario, esté disponible, no haya
// vencido y que la compra alcance el mínimo; y lo marca como USADO
// de forma atómica (si dos pedidos intentan usarlo a la vez, solo uno
// lo logra).
//
// Devuelve { userCoupon, discount } o { error, minimumPurchase? }.
// Si el pedido luego no se puede crear, hay que llamar a
// releaseCouponForOrder(orderId) para devolverlo.
export const claimUserCoupon = async ({
    userCouponId,
    userId,
    merchandiseTotal,
    orderId
}) => {

    const found = await UserCoupon.findOne({
        _id: userCouponId,
        userId
    });

    if (!found) {
        return { error: "Coupon not found" };
    }

    if (found.status === "USED") {
        return { error: "Coupon already used" };
    }

    if (isUserCouponExpired(found)) {
        return { error: "Coupon expired" };
    }

    if (merchandiseTotal < found.minimumPurchase) {
        return {
            error: "Minimum purchase not reached",
            minimumPurchase: found.minimumPurchase
        };
    }

    const discount =
        couponDiscountFor(found, merchandiseTotal);

    if (discount <= 0) {
        return { error: "Coupon gives no discount for this order" };
    }

    const now = new Date();

    const claimed = await UserCoupon.findOneAndUpdate(
        {
            _id: found._id,
            userId,
            status: "AVAILABLE",
            $or: [
                { expiresAt: null },
                { expiresAt: { $gt: now } }
            ]
        },
        {
            $set: {
                status: "USED",
                usedAt: now,
                orderId
            }
        },
        { new: true }
    );

    if (!claimed) {
        return { error: "Coupon already used" };
    }

    return { userCoupon: claimed, discount };

};

// Devuelve el cupón al cliente cuando el pedido en el que se usó
// se cancela (por el cliente, por el admin o por pago invalidado).
// Nunca lanza error. Si ya había vencido, el cliente lo ve vencido.
export const releaseCouponForOrder = async (orderId) => {

    try {

        await UserCoupon.findOneAndUpdate(
            { orderId, status: "USED" },
            {
                $set: {
                    status: "AVAILABLE",
                    usedAt: null,
                    orderId: null
                }
            }
        );

    } catch (error) {

        console.error(
            "Release coupon error:",
            error
        );

    }

};

// "30% de descuento" / "$5.000 de descuento".
export const couponDiscountText = (coupon) =>
    coupon.discountType === "percentage"
        ? `${coupon.discountValue}% de descuento`
        : `${formatMoney(coupon.discountValue)} de descuento`;

// ===================================
// CUPONES DE REGALO (bienvenida / cumpleaños)
// ===================================
// Le entregan al cliente un UserCoupon sin cobrar puntos y le avisan.
// Usan el cupón HABILITADO de ese tipo (si el admin no ha creado
// ninguno, no pasa nada). Nunca lanzan error ni regalan dos veces
// lo mismo.
const grantAutoCoupon = async ({
    userId,
    kind,
    periodKey,
    cycle,
    title,
    buildMessage
}) => {

    try {

        const coupon = await Coupon.findOne({
            kind,
            isActive: true
        });

        if (!coupon) return null;

        const alreadyGranted = await UserCoupon.exists({
            userId,
            source: kind,
            periodKey
        });

        if (alreadyGranted) return null;

        let userCoupon;

        try {

            userCoupon = await UserCoupon.create({
                userId,
                couponId: coupon._id,
                cycle: cycle ?? coupon.cycle,
                source: kind,
                periodKey,
                code:
                    "CP-" +
                    crypto.randomBytes(4).toString("hex").toUpperCase(),
                name: coupon.name,
                description: coupon.description,
                discountType: coupon.discountType,
                discountValue: coupon.discountValue,
                maximumDiscount: coupon.maximumDiscount,
                minimumPurchase: coupon.minimumPurchase,
                pointsSpent: 0,
                expiresAt: coupon.validDays
                    ? new Date(Date.now() + coupon.validDays * DAY_MS)
                    : null
            });

        } catch (createError) {

            // Ya lo tenía (carrera entre dos ejecuciones).
            if (createError.code === 11000) return null;

            throw createError;

        }

        await Coupon.updateOne(
            { _id: coupon._id },
            { $inc: { redeemedCount: 1 } }
        );

        // No se espera: el regalo ya está entregado.
        notifyUsers([userId], {
            title,
            message: buildMessage(coupon),
            type: "REWARD",
            relatedId: userCoupon._id
        });

        return userCoupon;

    } catch (error) {

        console.error(
            `Grant ${kind} coupon error:`,
            error
        );

        return null;

    }

};

// Una sola vez en la vida, cuando la cuenta queda verificada.
export const grantWelcomeCoupon = (userId) =>
    grantAutoCoupon({
        userId,
        kind: "WELCOME",
        periodKey: "WELCOME",
        title: "¡Bienvenido a SomosCafe! 🎁",
        buildMessage: (coupon) =>
            `Te regalamos el cupón "${coupon.name}": ` +
            `${couponDiscountText(coupon)}. Úsalo en tu pedido.`
    });

// Uno por año. [year] es el año de la fecha de hoy (Bogotá).
export const grantBirthdayCoupon = (userId, year) =>
    grantAutoCoupon({
        userId,
        kind: "BIRTHDAY",
        periodKey: String(year),
        // El año como ciclo permite repetir el mismo cupón cada año
        // sin chocar con el índice único (userId, couponId, cycle).
        cycle: year,
        title: "¡Feliz cumpleaños! 🎂",
        buildMessage: (coupon) =>
            `Te regalamos el cupón "${coupon.name}": ` +
            `${couponDiscountText(coupon)}. ¡Disfrútalo!`
    });
