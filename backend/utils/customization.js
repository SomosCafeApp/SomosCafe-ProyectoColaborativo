// ===================================
// PRODUCT CUSTOMIZATION
// ===================================
// Única fuente de verdad para precios y valores válidos de la
// personalización. Los nombres y precios replican lo que hoy muestra
// ProductDetailPage (size, type, milk, extraShots, toppings).
//
// El cliente solo envía las opciones elegidas; el precio SIEMPRE se
// calcula aquí. (Paso 4 del plan: estos valores saldrán del hardcode
// hacia la base de datos / panel admin.)

export const SIZE_PRICES = {
    "Pequeño": 3000,
    "Mediano": 0,
    "Grande": 5000
};

export const TYPE_OPTIONS = ["Caliente", "Frío"];

export const MILK_PRICES = {
    "Entera": 0,
    "Almendra": 1000,
    "Avena": 1000,
    "Soya": 2000
};

export const EXTRA_SHOT_PRICE = 3000;
export const MAX_EXTRA_SHOTS = 6;

export const TOPPING_PRICES = {
    "Crema batida": 2000,
    "Canela": 1000,
    "Chispas": 2500,
    "Caramelo": 1500
};

export const DEFAULT_CUSTOMIZATION = {
    size: "Mediano",
    type: "Caliente",
    milk: "Entera",
    extraShots: 0,
    toppings: []
};

// Devuelve { customization } con valores validados y normalizados,
// o { error } si algo no es válido. Si no viene nada, usa los valores
// por defecto (el producto "tal cual").
export const normalizeCustomization = (raw) => {

    const input =
        raw && typeof raw === "object"
            ? raw
            : {};

    const size =
        input.size ?? DEFAULT_CUSTOMIZATION.size;

    const type =
        input.type ?? DEFAULT_CUSTOMIZATION.type;

    const milk =
        input.milk ?? DEFAULT_CUSTOMIZATION.milk;

    const extraShots =
        input.extraShots === undefined || input.extraShots === null
            ? 0
            : Number(input.extraShots);

    const toppings =
        input.toppings === undefined || input.toppings === null
            ? []
            : input.toppings;

    if (!Object.prototype.hasOwnProperty.call(SIZE_PRICES, size)) {
        return { error: `Invalid size: ${size}` };
    }

    if (!TYPE_OPTIONS.includes(type)) {
        return { error: `Invalid type: ${type}` };
    }

    if (!Object.prototype.hasOwnProperty.call(MILK_PRICES, milk)) {
        return { error: `Invalid milk: ${milk}` };
    }

    if (
        !Number.isInteger(extraShots) ||
        extraShots < 0 ||
        extraShots > MAX_EXTRA_SHOTS
    ) {
        return {
            error: `Extra shots must be an integer between 0 and ${MAX_EXTRA_SHOTS}`
        };
    }

    if (!Array.isArray(toppings)) {
        return { error: "Toppings must be a list" };
    }

    for (const topping of toppings) {
        if (!Object.prototype.hasOwnProperty.call(TOPPING_PRICES, topping)) {
            return { error: `Invalid topping: ${topping}` };
        }
    }

    // Sin duplicados y en orden estable: así "Canela+Caramelo" y
    // "Caramelo+Canela" producen la misma clave de línea.
    const uniqueToppings = [...new Set(toppings)].sort();

    return {
        customization: {
            size,
            type,
            milk,
            extraShots,
            toppings: uniqueToppings
        }
    };
};

// Precio extra (por unidad) que suman las opciones elegidas.
export const customizationPrice = (customization) => {

    const c = customization || DEFAULT_CUSTOMIZATION;

    let extra = 0;

    extra += SIZE_PRICES[c.size] || 0;
    extra += MILK_PRICES[c.milk] || 0;
    extra += (c.extraShots || 0) * EXTRA_SHOT_PRICE;

    for (const topping of (c.toppings || [])) {
        extra += TOPPING_PRICES[topping] || 0;
    }

    return extra;
};

// Identifica una combinación producto + personalización. Dos líneas
// del carrito son "la misma" si tienen igual productId y esta clave.
export const customizationKey = (customization) => {

    const c = customization || DEFAULT_CUSTOMIZATION;

    return [
        c.size,
        c.type,
        c.milk,
        c.extraShots || 0,
        (c.toppings || []).join(",")
    ].join("|");
};

// ===================================
// PRODUCTS THAT CANNOT BE CUSTOMIZED
// ===================================
// Los postres (por nombre de categoría) no tienen menú de
// personalización: tamaño, leche, shots y toppings no aplican.
// Flutter oculta el menú; esto lo hace valer en el servidor.
// Requiere el producto con la categoría poblada ({ name }). Sin
// categoría el producto sí es personalizable.
const NON_CUSTOMIZABLE_CATEGORY_KEYWORDS = [
    "postre",
    "dessert",
    "torta",
    "pastel",
    "cheesecake"
];

export const isCustomizableProduct = (product) => {

    const categoryName = product?.categoryId?.name;

    if (typeof categoryName !== "string") return true;

    const lower = categoryName.toLowerCase();

    return !NON_CUSTOMIZABLE_CATEGORY_KEYWORDS.some(
        keyword => lower.includes(keyword)
    );

};

// Igual que normalizeCustomization, pero para productos no
// personalizables ignora lo que mande el cliente y deja los valores
// por defecto (sin extras de precio).
export const resolveCustomization = (product, raw) => {

    if (!isCustomizableProduct(product)) {
        return {
            customization: {
                ...DEFAULT_CUSTOMIZATION,
                toppings: []
            }
        };
    }

    return normalizeCustomization(raw);

};
