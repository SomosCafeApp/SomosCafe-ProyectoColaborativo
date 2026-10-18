import mongoose from "mongoose";

// ===================================
// COUPON (catálogo de recompensas)
// ===================================
// Lo crea el administrador. El cliente lo canjea con puntos y recibe
// un UserCoupon (ver userCouponModel.js) que luego usa en un pedido.
//
// Límite por persona: SIEMPRE 1 por "ciclo". El ciclo sube (cycle++)
// cuando el administrador reactiva el cupón: ahí el contador de
// canjes vuelve a 0 y quienes ya lo canjearon pueden canjearlo otra
// vez (ver setCouponStatus en couponController.js).

export const COUPON_DISCOUNT_TYPES = ["percentage", "fixed"];

// REWARD   = se canjea con puntos (catálogo de recompensas)
// WELCOME  = regalo automático al registrarse
// BIRTHDAY = regalo automático el día del cumpleaños (1 por año)
// Los de regalo no cuestan puntos ni aparecen en el catálogo, y solo
// puede haber UNO habilitado de cada tipo.
export const COUPON_KINDS = ["REWARD", "WELCOME", "BIRTHDAY"];
export const AUTO_COUPON_KINDS = ["WELCOME", "BIRTHDAY"];

const couponSchema = new mongoose.Schema(
    {
        kind: {
            type: String,
            enum: COUPON_KINDS,
            default: "REWARD"
        },

        name: {
            type: String,
            required: true,
            trim: true,
            maxlength: 60
        },

        description: {
            type: String,
            trim: true,
            default: "",
            maxlength: 140
        },

        // "percentage" = % sobre el pedido · "fixed" = valor en pesos.
        // Aplica a cualquier producto del pedido (no al envío).
        discountType: {
            type: String,
            enum: COUPON_DISCOUNT_TYPES,
            required: true
        },

        discountValue: {
            type: Number,
            required: true,
            min: 0
        },

        // Tope del descuento en pesos (solo tiene sentido en %).
        maximumDiscount: {
            type: Number,
            default: null,
            min: 0
        },

        // Compra mínima (en productos, ya con promociones) para usarlo.
        minimumPurchase: {
            type: Number,
            default: 0,
            min: 0
        },

        // Puntos que cuesta canjearlo (0 en los cupones de regalo).
        pointsCost: {
            type: Number,
            required: true,
            min: 0
        },

        // Cuántos cupones se pueden canjear EN TOTAL en el ciclo
        // actual (null = sin límite).
        redeemLimit: {
            type: Number,
            default: null,
            min: 1
        },

        // Canjes del ciclo actual.
        redeemedCount: {
            type: Number,
            default: 0,
            min: 0
        },

        // Días que tiene el cliente para usarlo después de canjearlo
        // (null = no vence).
        validDays: {
            type: Number,
            default: null,
            min: 1
        },

        isActive: {
            type: Boolean,
            default: true
        },

        cycle: {
            type: Number,
            default: 1,
            min: 1
        }
    },
    {
        timestamps: true,
        collection: "coupons"
    }
);

const Coupon = mongoose.model("Coupon", couponSchema);

export default Coupon;
