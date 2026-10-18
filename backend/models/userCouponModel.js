import mongoose from "mongoose";

// ===================================
// USER COUPON (cupón ya canjeado por un cliente)
// ===================================
// Guarda una "foto" de las condiciones del cupón al momento del
// canje: si el admin edita o borra el cupón después, el cliente
// conserva exactamente lo que canjeó.

export const USER_COUPON_STATUSES = ["AVAILABLE", "USED"];

const userCouponSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true
        },

        couponId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Coupon",
            required: true
        },

        // Ciclo del cupón en el que se canjeó (ver couponModel.js).
        cycle: {
            type: Number,
            required: true,
            min: 1
        },

        // Código corto para identificarlo (ej. CP-3FA9C1D2).
        code: {
            type: String,
            required: true,
            unique: true
        },

        // ---- Foto del cupón ----
        name: { type: String, required: true },
        description: { type: String, default: "" },
        discountType: {
            type: String,
            enum: ["percentage", "fixed"],
            required: true
        },
        discountValue: { type: Number, required: true, min: 0 },
        maximumDiscount: { type: Number, default: null },
        minimumPurchase: { type: Number, default: 0 },

        // De dónde salió: canje con puntos o regalo automático.
        source: {
            type: String,
            enum: ["REDEEM", "WELCOME", "BIRTHDAY"],
            default: "REDEEM"
        },

        // Evita regalar dos veces lo mismo: "WELCOME" (una vez en la
        // vida) o el año del cumpleaños, ej. "2026".
        periodKey: {
            type: String,
            default: null
        },

        // Cuándo se avisó que está por vencer (null = aún no).
        reminderSentAt: {
            type: Date,
            default: null
        },

        pointsSpent: {
            type: Number,
            required: true,
            min: 0
        },

        status: {
            type: String,
            enum: USER_COUPON_STATUSES,
            default: "AVAILABLE"
        },

        // null = no vence. Pasada esta fecha ya no se puede usar.
        expiresAt: {
            type: Date,
            default: null
        },

        usedAt: {
            type: Date,
            default: null
        },

        // Pedido en el que se usó.
        orderId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Order",
            default: null
        }
    },
    {
        timestamps: true,
        collection: "userCoupons"
    }
);

// Una persona solo puede canjear un cupón UNA vez por ciclo.
// Es la garantía real contra canjes dobles (dos toques seguidos,
// dos teléfonos, etc.).
userCouponSchema.index(
    { userId: 1, couponId: 1, cycle: 1 },
    { unique: true }
);

userCouponSchema.index({ userId: 1, createdAt: -1 });

// Para devolver el cupón rápido cuando se cancela un pedido.
userCouponSchema.index({ orderId: 1 });

// Para el recordatorio de cupones por vencer.
userCouponSchema.index({ status: 1, expiresAt: 1, reminderSentAt: 1 });

// Para saber si ya se le regaló el de bienvenida / cumpleaños.
userCouponSchema.index({ userId: 1, source: 1, periodKey: 1 });

const UserCoupon = mongoose.model("UserCoupon", userCouponSchema);

export default UserCoupon;
