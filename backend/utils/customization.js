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
    // OJO: el precio de la deslactosada es una suposición (igual al de
    // las leches vegetales). Confírmalo con el negocio.
    "Deslactosada": 1000,
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

// Jarabes y endulzantes: hoy NO existen en la base de datos ni en el
// menú, así que los catálogos arrancan vacíos a propósito (no se
// inventan sabores ni precios). Cuando el negocio defina los suyos,
// basta con agregarlos aquí, ej.  "Vainilla": 1500  — el minijuego,
// el carrito y los pedidos los validan y cobran sin más cambios.
export const SYRUP_PRICES = {};
export const SWEETENER_PRICES = {};
export const MAX_SYRUPS = 3;
export const MAX_SWEETENERS = 2;

// Latte art: solo tres diseños predefinidos (decoración, no cuesta).
export const LATTE_ART_DESIGNS = ["Corazón", "Hoja", "Cisne"];

// Onzas de cada tamaño. OJO: el menú no guarda onzas; estos valores
// son los típicos de cafetería y deben confirmarse con el negocio.
// Solo afectan el tamaño visual del vaso en el estudio de bebidas.
export const SIZE_OUNCES = {
    "Pequeño": 8,
    "Mediano": 12,
    "Grande": 16
};

// Bebidas con espuma de leche donde tiene sentido dibujar latte art.
export const LATTE_ART_KEYWORDS = [
    "latte", "capuch", "cappuc", "moca", "mocha",
    "macchiato", "flat white", "cortado", "con leche"
];

// Bebidas a base de café (habilitan la etapa de shots).
export const COFFEE_KEYWORDS = [
    "café", "cafe", "coffee", "espresso", "americano",
    ...LATTE_ART_KEYWORDS
];

export const DEFAULT_CUSTOMIZATION = {
    size: "Mediano",
    type: "Caliente",
    milk: "Entera",
    extraShots: 0,
    toppings: [],
    syrups: [],
    sweeteners: [],
    latteArt: ""
};

// Lista de nombres que deben existir en un catálogo de precios.
// Devuelve { list } (sin duplicados, ordenada) o { error }.
const normalizeNamedList = (raw, catalog, max, label) => {

    if (raw === undefined || raw === null) return { list: [] };

    if (!Array.isArray(raw)) {
        return { error: `La lista de ${label}s no es válida` };
    }

    for (const name of raw) {
        if (
            typeof name !== "string" ||
            !Object.prototype.hasOwnProperty.call(catalog, name)
        ) {
            return { error: `${label} no disponible: ${String(name)}` };
        }
    }

    const list = [...new Set(raw)].sort();

    if (list.length > max) {
        return { error: `Máximo ${max} ${label}s por bebida` };
    }

    return { list };
};

// Valida el diseño de latte art. Devuelve { design } ("" = ninguno).
const normalizeLatteArt = (raw) => {

    if (raw === undefined || raw === null || raw === "") {
        return { design: "" };
    }

    if (typeof raw !== "string" || !LATTE_ART_DESIGNS.includes(raw)) {
        return { error: `Diseño de latte art no disponible: ${String(raw)}` };
    }

    return { design: raw };
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

    const syrupsResult = normalizeNamedList(
        input.syrups, SYRUP_PRICES, MAX_SYRUPS, "jarabe"
    );
    if (syrupsResult.error) return { error: syrupsResult.error };

    const sweetenersResult = normalizeNamedList(
        input.sweeteners, SWEETENER_PRICES, MAX_SWEETENERS, "endulzante"
    );
    if (sweetenersResult.error) return { error: sweetenersResult.error };

    const artResult = normalizeLatteArt(input.latteArt);
    if (artResult.error) return { error: artResult.error };

    return {
        customization: {
            size,
            type,
            milk,
            extraShots,
            toppings: uniqueToppings,
            syrups: syrupsResult.list,
            sweeteners: sweetenersResult.list,
            latteArt: artResult.design
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

    for (const syrup of (c.syrups || [])) {
        extra += SYRUP_PRICES[syrup] || 0;
    }

    for (const sweetener of (c.sweeteners || [])) {
        extra += SWEETENER_PRICES[sweetener] || 0;
    }

    return extra;
};

// Identifica una combinación producto + personalización. Dos líneas
// del carrito son "la misma" si tienen igual productId y esta clave.
export const customizationKey = (customization) => {

    const c = customization || DEFAULT_CUSTOMIZATION;

    const parts = [
        c.size,
        c.type,
        c.milk,
        c.extraShots || 0,
        (c.toppings || []).join(",")
    ];

    // Los campos nuevos solo se agregan cuando traen algo: así las
    // líneas de carritos anteriores siguen teniendo la misma clave.
    if ((c.syrups || []).length) {
        parts.push(`s:${c.syrups.join(",")}`);
    }

    if ((c.sweeteners || []).length) {
        parts.push(`w:${c.sweeteners.join(",")}`);
    }

    if (c.latteArt) {
        parts.push(`a:${c.latteArt}`);
    }

    return parts.join("|");
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

// Texto (nombre + categoría) usado para saber qué tipo de bebida es.
const productText = (product) =>
    `${product?.name || ""} ${product?.categoryId?.name || ""}`
        .toLowerCase();

// El latte art solo aplica a bebidas calientes con espuma de leche.
export const supportsLatteArt = (product) => {

    const text = productText(product);

    return LATTE_ART_KEYWORDS.some(k => text.includes(k));
};

// Igual que normalizeCustomization, pero para productos no
// personalizables ignora lo que mande el cliente y deja los valores
// por defecto (sin extras de precio).
export const resolveCustomization = (product, raw) => {

    if (!isCustomizableProduct(product)) {
        return {
            customization: {
                ...DEFAULT_CUSTOMIZATION,
                toppings: [],
                syrups: [],
                sweeteners: [],
                latteArt: ""
            }
        };
    }

    const result = normalizeCustomization(raw);

    if (result.error) return result;

    const { customization } = result;

    if (
        customization.latteArt !== "" &&
        (customization.type !== "Caliente" || !supportsLatteArt(product))
    ) {
        return {
            error: "Este producto no admite latte art"
        };
    }

    return result;

};

// Opciones reales que el cliente puede mostrar (GET /customization/options).
// Es la misma fuente que usa la validación: nada se inventa en la app.
export const getCustomizationOptions = () => ({
    sizes: { ...SIZE_PRICES },
    types: [...TYPE_OPTIONS],
    milks: { ...MILK_PRICES },
    extraShot: { price: EXTRA_SHOT_PRICE, max: MAX_EXTRA_SHOTS },
    toppings: { ...TOPPING_PRICES },
    syrups: { prices: { ...SYRUP_PRICES }, max: MAX_SYRUPS },
    sweeteners: { prices: { ...SWEETENER_PRICES }, max: MAX_SWEETENERS },
    sizeOunces: { ...SIZE_OUNCES },
    latteArt: {
        keywords: [...LATTE_ART_KEYWORDS],
        designs: [...LATTE_ART_DESIGNS]
    },
    coffeeKeywords: [...COFFEE_KEYWORDS],
    defaults: {
        size: DEFAULT_CUSTOMIZATION.size,
        type: DEFAULT_CUSTOMIZATION.type,
        milk: DEFAULT_CUSTOMIZATION.milk
    }
});
