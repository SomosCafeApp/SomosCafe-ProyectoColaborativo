import Promotion from "../models/promotionModel.js";

// ===================================
// PRODUCT DISCOUNTS FROM PROMOTIONS
// ===================================
// Una promoción con productos asignados (productIds) descuenta
// automáticamente el precio BASE de esos productos mientras esté:
//   - habilitada (isActive)
//   - dentro de su rango de fechas
//   - disponible para el usuario (userIds vacío = para todos)
// El extra de la personalización NO se descuenta.
//
// Si un producto tiene varias promociones vigentes, gana la que deja
// el precio más bajo (no se acumulan).
// Las promociones SIN productos asignados no descuentan nada aquí:
// siguen funcionando solo como código (POST /promotions/validate).

export const loadActivePromotions = async ({ userId = null } = {}) => {

    const now = new Date();

    const promotions = await Promotion.find({
        isActive: true,
        startDate: { $lte: now },
        endDate: { $gte: now },
        "productIds.0": { $exists: true }
    });

    return promotions.filter(promotion => {

        if (promotion.userIds.length === 0) return true;

        if (!userId) return false;

        return promotion.userIds.some(
            id => id.toString() === userId.toString()
        );

    });

};

// Descuento por unidad (en pesos enteros) que aplica una promoción a
// un precio base. Nunca supera el precio ni el tope maximumDiscount.
export const unitDiscountFor = (promotion, basePrice) => {

    let discount =
        promotion.discountType === "percentage"
            ? basePrice * (promotion.discountValue / 100)
            : promotion.discountValue;

    if (
        promotion.maximumDiscount !== null &&
        promotion.maximumDiscount !== undefined
    ) {
        discount = Math.min(discount, promotion.maximumDiscount);
    }

    discount = Math.min(discount, basePrice);

    return Math.max(0, Math.round(discount));

};

// Devuelve una función (productId, basePrice) => { discountPerUnit,
// promotion } o null si ese producto no tiene promoción vigente.
export const buildDiscountResolver = (promotions) => {

    const byProduct = new Map();

    for (const promotion of promotions) {
        for (const productId of promotion.productIds) {
            const key = productId.toString();
            if (!byProduct.has(key)) byProduct.set(key, []);
            byProduct.get(key).push(promotion);
        }
    }

    return (productId, basePrice) => {

        const candidates = byProduct.get(productId.toString());

        if (!candidates) return null;

        let best = null;

        for (const promotion of candidates) {

            const discountPerUnit =
                unitDiscountFor(promotion, basePrice);

            if (
                discountPerUnit > 0 &&
                (!best || discountPerUnit > best.discountPerUnit)
            ) {
                best = { discountPerUnit, promotion };
            }
        }

        return best;

    };

};

export const getDiscountResolver = async (userId = null) =>
    buildDiscountResolver(
        await loadActivePromotions({ userId })
    );

// Resumen liviano de la promoción para enviar al cliente.
export const promotionSummary = (promotion) => ({
    id: promotion._id,
    name: promotion.name,
    discountType: promotion.discountType,
    discountValue: promotion.discountValue
});

// Agrega a un producto (documento o objeto) los campos de precio con
// descuento: discountedPrice, discountPerUnit y activePromotion.
export const decorateProduct = (product, resolver) => {

    if (!product) return product;

    const plain =
        typeof product.toObject === "function"
            ? product.toObject()
            : { ...product };

    const applied = resolver(plain._id, plain.price);

    if (!applied) return plain;

    return {
        ...plain,
        discountPerUnit: applied.discountPerUnit,
        discountedPrice: plain.price - applied.discountPerUnit,
        activePromotion: promotionSummary(applied.promotion)
    };

};
