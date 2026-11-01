// ===================================
// DRINKSTUDIO → PEDIDO REAL
// ===================================
// Convierte la bebida armada en el minijuego en algo que el negocio
// pueda vender: un producto REAL del menú (el latte) + una
// personalización validada con las mismas reglas que el carrito y los
// pedidos (utils/customization.js) y un precio calculado SOLO aquí
// (utils/pricing.js). La app nunca decide el importe.
//
// Este archivo es lógica pura (sin base de datos) para poder probarla
// sin conexión; el controlador se encarga de leer productos y promos.

import {
    resolveCustomization,
    customizationKey,
    isCustomizableProduct,
    supportsLatteArt
} from "./customization.js";

import {
    customizationBreakdown,
    clampDiscount
} from "./pricing.js";

// Cantidad máxima de bebidas iguales por envío (misma cota que la app).
export const MAX_STUDIO_QUANTITY = 20;

// Cuánta leche se vertió es solo visual (0..1): no cambia el precio.
export const clampMilkLevel = (value) => {

    const n = Number(value);

    if (!Number.isFinite(n)) return 0.55;

    return Math.min(1, Math.max(0, n));
};

const normalize = (text) =>
    String(text || "")
        .toLowerCase()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .trim();

// Puntuación de qué tan "el latte" es un producto. 0 = no sirve.
const latteScore = (product) => {

    if (!product || product.isAvailable === false) return 0;

    const name = normalize(product.name);

    if (!name.includes("latte")) return 0;

    // Un latte "de postre" o un producto no personalizable no sirve.
    if (!isCustomizableProduct(product)) return 0;

    // Un latte con espuma de leche es lo que permite el arte latte.
    if (!supportsLatteArt(product)) return 0;

    if (name === "latte") return 100;

    if (name.startsWith("latte")) return 80;

    return 50;
};

// Elige el latte del menú: disponible, personalizable y con nombre más
// cercano a "Latte". En empate gana el más barato (el "clásico").
export const pickLatteProduct = (products = []) => {

    let best = null;
    let bestScore = 0;

    for (const product of products) {

        const score = latteScore(product);

        if (score === 0) continue;

        if (
            !best ||
            score > bestScore ||
            (score === bestScore && product.price < best.price)
        ) {
            best = product;
            bestScore = score;
        }
    }

    return best;
};

// Forma pública del producto para la app.
export const studioProductView = (product, resolver) => {

    const applied = resolver
        ? resolver(product._id, product.price)
        : null;

    const discountPerUnit = applied ? applied.discountPerUnit : 0;

    return {
        id: String(product._id),
        name: product.name,
        description: product.description || "",
        price: product.price,
        image: product.images?.[0] || null,
        images: product.images || [],
        isAvailable: product.isAvailable !== false,
        categoryName: product.categoryId?.name || null,
        discountPerUnit,
        effectivePrice: product.price - discountPerUnit,
        promotionName: applied ? applied.promotion.name : null
    };
};

// Entero positivo y acotado, o null.
const parseQuantity = (raw) => {

    const quantity = raw === undefined || raw === null ? 1 : Number(raw);

    if (
        !Number.isInteger(quantity) ||
        quantity < 1 ||
        quantity > MAX_STUDIO_QUANTITY
    ) {
        return null;
    }

    return quantity;
};

// Valida la bebida y calcula su precio. NO guarda nada.
//   product:       producto del menú (con categoryId poblada) o null
//   raw:           { customization, quantity, milkLevel }
//   discountOf:    (productId, basePrice) => { discountPerUnit, promotion } | null
// Devuelve { ok: true, ...detalle } o { ok: false, status, code, message }.
export const buildStudioQuote = ({ product, raw = {}, discountOf = null }) => {

    if (!product) {
        return {
            ok: false,
            status: 404,
            code: "PRODUCT_NOT_FOUND",
            message: "No encontramos el latte en el menú"
        };
    }

    if (product.isAvailable === false) {
        return {
            ok: false,
            status: 409,
            code: "PRODUCT_UNAVAILABLE",
            message: "El latte no está disponible por el momento"
        };
    }

    if (!isCustomizableProduct(product)) {
        return {
            ok: false,
            status: 400,
            code: "NOT_CUSTOMIZABLE",
            message: "Este producto no admite personalización"
        };
    }

    const quantity = parseQuantity(raw.quantity);

    if (quantity === null) {
        return {
            ok: false,
            status: 400,
            code: "INVALID_QUANTITY",
            message: `La cantidad debe ser un entero entre 1 y ${MAX_STUDIO_QUANTITY}`
        };
    }

    const { customization, error } =
        resolveCustomization(product, raw.customization);

    if (error) {
        return {
            ok: false,
            status: 400,
            code: "INVALID_CONFIGURATION",
            message: error
        };
    }

    const breakdown = customizationBreakdown(customization, product.price);

    const originalUnitPrice = product.price + breakdown.customizationPrice;

    const applied = discountOf
        ? discountOf(product._id, product.price)
        : null;

    const discountPerUnit = clampDiscount(
        applied ? applied.discountPerUnit : 0,
        originalUnitPrice
    );

    const unitPrice = originalUnitPrice - discountPerUnit;

    return {
        ok: true,
        productId: String(product._id),
        quantity,
        customization,
        milkLevel: clampMilkLevel(raw.milkLevel),
        key: customizationKey(customization),
        basePrice: product.price,
        sizeAdjustment: breakdown.sizeAdjustment,
        lines: breakdown.lines,
        customizationPrice: breakdown.customizationPrice,
        originalUnitPrice,
        discountPerUnit,
        promotionName: applied ? applied.promotion.name : null,
        unitPrice,
        lineTotal: unitPrice * quantity
    };
};

// ¿El importe que mostró la app coincide con el del servidor? Se
// tolera medio peso por redondeos. Sin importe esperado no hay nada
// que comparar.
export const priceMatches = (expected, actual) => {

    if (expected === undefined || expected === null) return true;

    const n = Number(expected);

    if (!Number.isFinite(n)) return false;

    return Math.abs(n - actual) < 0.5;
};
