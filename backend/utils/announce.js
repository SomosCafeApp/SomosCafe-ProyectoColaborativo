// ===================================
// ANUNCIOS AUTOMÁTICOS (productos, promociones, cupones, eventos)
// ===================================
// Crean la notificación (pantalla de notificaciones + push FCM, vía el
// hook del modelo) SOLO cuando la novedad ya está guardada y vigente.
// Reglas comunes:
//   - Nunca lanzan error ni retrasan la respuesta de quien las llama.
//   - Una misma novedad se avisa una sola vez por usuario (dedupeKey).
//   - Respetan las preferencias del usuario y la segmentación
//     (promociones dirigidas a usuarios concretos).
//   - Cada notificación lleva type + relatedId: al tocarla la app abre
//     el producto, promoción, cupón o evento correspondiente.

import Product from "../models/productModel.js";
import Category from "../models/categoryModel.js";
import Promotion from "../models/promotionModel.js";

import {
    notifyUsers,
    notifyAllCustomers,
    formatMoney,
    formatDate
} from "./notify.js";

import { dedupeKeyFor } from "./notifyPlan.js";
import { couponDiscountText } from "./coupons.js";

// ---------- Productos ----------
// Un producto es "nuevo" solo la primera vez que queda disponible en
// el menú. Ocultarlo y volver a mostrarlo no repite el aviso.
export const announceProduct = async (product) => {

    try {

        if (!product || !product.isAvailable || product.launchNotifiedAt) {
            return false;
        }

        // Solo es "nuevo" si se creó hace poco: al reactivar un producto
        // antiguo (de antes de existir este aviso) no se anuncia como novedad.
        const NEW_PRODUCT_WINDOW_MS = 30 * 24 * 60 * 60 * 1000;

        if (
            product.createdAt &&
            Date.now() - new Date(product.createdAt).getTime() > NEW_PRODUCT_WINDOW_MS
        ) {
            return false;
        }

        // Si su categoría está desactivada no aparece en el menú.
        const categoryId = product.categoryId?._id || product.categoryId;

        if (categoryId) {
            const category = await Category.findById(categoryId)
                .select("isActive").lean();

            if (category && category.isActive === false) return false;
        }

        // Se marca ANTES de enviar: dos guardados seguidos no avisan dos veces.
        const claimed = await Product.updateOne(
            { _id: product._id, launchNotifiedAt: null },
            { $set: { launchNotifiedAt: new Date() } }
        );

        if (claimed.modifiedCount === 0) return false;

        const created = await notifyAllCustomers({
            title: "Nuevo en el menú",
            message: `${product.name} ya está disponible por ${formatMoney(product.price)}. ¡Pruébalo!`,
            type: "PRODUCT",
            relatedId: product._id
        }, {
            dedupeKey: dedupeKeyFor("PRODUCT_NEW", product._id)
        });

        return created > 0;

    } catch (error) {

        console.error("Announce product error:", error);
        return false;

    }
};

// ---------- Promociones ----------
// Solo avisa si está activa, ya empezó y no ha vencido. Si empieza más
// adelante, la tarea programada (jobs/newsJobs.js) la anuncia ese día.
export const announcePromotion = async (promotion) => {

    try {

        const now = new Date();

        if (
            !promotion ||
            !promotion.isActive ||
            promotion.endDate <= now ||
            promotion.startDate > now
        ) {
            return false;
        }

        const benefit =
            promotion.discountType === "percentage"
                ? `${promotion.discountValue}% de descuento`
                : `${formatMoney(promotion.discountValue)} de descuento`;

        const minimum =
            promotion.minimumPurchase > 0
                ? ` En compras desde ${formatMoney(promotion.minimumPurchase)}.`
                : "";

        const payload = {
            title: "Nueva promoción",
            message:
                `${promotion.name}: ${benefit}.${minimum} ` +
                `Vigente hasta el ${formatDate(promotion.endDate)}.`,
            type: "PROMOTION",
            relatedId: promotion._id
        };

        const options = {
            dedupeKey: dedupeKeyFor(
                "PROMO",
                promotion._id,
                promotion.startDate,
                promotion.endDate
            )
        };

        // Dirigida a usuarios concretos: solo a ellos.
        const created = promotion.userIds?.length > 0
            ? await notifyUsers(promotion.userIds, payload, options)
            : await notifyAllCustomers(payload, options);

        await Promotion.updateOne(
            { _id: promotion._id },
            { $set: { launchNotifiedAt: now } }
        );

        return created > 0;

    } catch (error) {

        console.error("Announce promotion error:", error);
        return false;

    }
};

// ---------- Cupones ----------
// Solo los cupones públicos canjeables con puntos se anuncian; los de
// regalo (bienvenida/cumpleaños) se entregan solos a quien corresponde.
export const announceCoupon = async (coupon, { reactivated = false } = {}) => {

    try {

        if (
            !coupon ||
            !coupon.isActive ||
            coupon.kind !== "REWARD" ||
            (coupon.redeemLimit !== null &&
                coupon.redeemLimit !== undefined &&
                coupon.redeemedCount >= coupon.redeemLimit)
        ) {
            return false;
        }

        const day = new Date().toISOString().slice(0, 10);

        const created = await notifyAllCustomers({
            title: reactivated ? "¡Volvió un cupón!" : "Nuevo cupón disponible",
            message:
                `${coupon.name}: ${couponDiscountText(coupon)}. ` +
                `Canjéalo por ${coupon.pointsCost} puntos.`,
            type: "REWARD",
            relatedId: coupon._id
        }, {
            dedupeKey: reactivated
                ? dedupeKeyFor("COUPON_BACK", coupon._id, day)
                : dedupeKeyFor("COUPON_NEW", coupon._id)
        });

        return created > 0;

    } catch (error) {

        console.error("Announce coupon error:", error);
        return false;

    }
};

// ---------- Eventos ----------
export const announceEvent = async (event, title = "Nuevo evento") => {

    try {

        if (
            !event ||
            !event.isActive ||
            new Date(event.endDate) < new Date()
        ) {
            return false;
        }

        const where = event.location ? ` en ${event.location}` : "";

        const created = await notifyAllCustomers({
            title,
            message:
                `${event.name}${where} ` +
                `(${formatDate(event.startDate)}). ¡Te esperamos!`,
            type: "EVENT",
            relatedId: event._id
        }, {
            dedupeKey: dedupeKeyFor(
                "EVENT",
                event._id,
                event.startDate,
                event.endDate
            )
        });

        return created > 0;

    } catch (error) {

        console.error("Announce event error:", error);
        return false;

    }
};
