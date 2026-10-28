// ===================================
// PRICING (precio de UNA unidad)
// ===================================
// Única fuente de verdad del cálculo de precios con personalización.
// La app (ProductCustomization.quote) replica exactamente estas reglas
// para mostrar el total antes de comprar; lo que se cobra es siempre
// lo que se calcula aquí.
//
//   originalUnitPrice = base + ajuste de tamaño + adicionales
//   unitPrice         = originalUnitPrice - descuento (nunca < 0)

import {
    SIZE_PRICES,
    MILK_PRICES,
    EXTRA_SHOT_PRICE,
    TOPPING_PRICES,
    TOPPING_EXTRA_PORTION_PRICE,
    SYRUP_PRICES,
    SWEETENER_PRICES,
    DEFAULT_CUSTOMIZATION,
    MIN_PRICE_AFTER_SIZE,
    toppingLinePrice
} from "./customization.js";

// El tamaño Pequeño nunca deja la bebida por debajo de MIN_PRICE_AFTER_SIZE
// (si no, un producto barato quedaría gratis o en negativo).
export { MIN_PRICE_AFTER_SIZE };

// Ajuste real del tamaño para un producto de precio base [basePrice]
// (precio de lista, no el promocional). Grande/Mediano no cambian;
// Pequeño resta hasta dejar el producto en MIN_PRICE_AFTER_SIZE.
export const sizeAdjustment = (size, basePrice) => {

    const raw = SIZE_PRICES[size] || 0;

    if (raw >= 0 || typeof basePrice !== "number") return raw;

    const room = basePrice - MIN_PRICE_AFTER_SIZE;

    if (room <= 0) return 0;

    return -Math.min(-raw, room);
};

// Adicionales con precio (sin el tamaño), con las mismas etiquetas
// que muestra la app en el desglose.
export const extraLines = (customization) => {

    const c = customization || DEFAULT_CUSTOMIZATION;
    const lines = [];

    const milkExtra = MILK_PRICES[c.milk] || 0;
    if (milkExtra !== 0) {
        lines.push({ label: `Leche ${c.milk}`, amount: milkExtra });
    }

    if ((c.extraShots || 0) > 0) {
        lines.push({
            label: `Shots extra × ${c.extraShots}`,
            amount: c.extraShots * EXTRA_SHOT_PRICE,
            detail: `$${EXTRA_SHOT_PRICE} c/u`
        });
    }

    for (const t of [...(c.toppings || [])].sort()) {
        const q = c.toppingQuantities?.[t] ?? 1;
        lines.push({
            label: q > 1 ? `${t} × ${q}` : t,
            amount: toppingLinePrice(t, q),
            ...(q > 1
                ? { detail: `${q - 1} extra × $${TOPPING_EXTRA_PORTION_PRICE}` }
                : {})
        });
    }

    for (const y of [...(c.syrups || [])].sort()) {
        lines.push({ label: `Jarabe ${y}`, amount: SYRUP_PRICES[y] || 0 });
    }

    for (const w of [...(c.sweeteners || [])].sort()) {
        const price = SWEETENER_PRICES[w] || 0;
        if (price !== 0) lines.push({ label: w, amount: price });
    }

    return lines;
};

// Desglose completo de lo que suma la personalización por unidad.
export const customizationBreakdown = (customization, basePrice) => {

    const c = customization || DEFAULT_CUSTOMIZATION;
    const size = sizeAdjustment(c.size, basePrice);
    const lines = extraLines(c);
    const extrasTotal = lines.reduce((sum, l) => sum + l.amount, 0);

    return {
        size: c.size,
        sizeAdjustment: size,
        lines,
        extrasTotal,
        customizationPrice: size + extrasTotal
    };
};

// Extra por unidad (tamaño + adicionales) para un producto de precio
// base [basePrice]. Es lo que se guarda como customizationPrice.
export const customizationPriceFor = (customization, basePrice) =>
    customizationBreakdown(customization, basePrice).customizationPrice;

// El descuento por promoción se calcula sobre el precio base, pero nunca
// puede superar el precio de la unidad (con tamaño y adicionales).
export const clampDiscount = (discountPerUnit, originalUnitPrice) => {

    const discount = Number(discountPerUnit) || 0;

    if (discount <= 0) return 0;

    return Math.min(discount, Math.max(originalUnitPrice, 0));
};
