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

// Ajuste de precio por tamaño respecto al precio base del producto
// (el base corresponde al tamaño Mediano). Puede ser NEGATIVO:
//   Pequeño = base - 3.000 · Mediano = base · Grande = base + 5.000
// Piso del tamaño Pequeño (ver utils/pricing.js: sizeAdjustment).
export const MIN_PRICE_AFTER_SIZE = 1000;

export const SIZE_PRICES = {
    "Pequeño": -3000,
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
    "Caramelo": 1500,
    "Cacao en polvo": 1000,
    "Virutas de chocolate": 2000,
    "Malvaviscos": 1800
};

// Compatibilidad de cada topping con la bebida. Un topping sin regla
// va con cualquier bebida. Claves de cada regla:
//   types:    solo con esas temperaturas ("Caliente" / "Frío").
//   keywords: el nombre o la categoría de la bebida debe contener
//             alguna de estas palabras.
//   exclude:  no va si el nombre o la categoría contiene alguna.
// OJO: las reglas son criterio de cafetería (p. ej. los malvaviscos se
// derriten en frío); confírmalas con el negocio.
const CHOCOLATE_KEYWORDS = [
    "chocolate", "moca", "mocha", "cacao"
];

const MILK_COFFEE_KEYWORDS = [
    "latte", "capuch", "cappuc", "moca", "mocha", "macchiato",
    "flat white", "cortado", "con leche", "frappe", "frappé",
    "malteada", "batido", "chocolate"
];

// Los cuatro toppings originales (Crema batida, Canela, Chispas y
// Caramelo) no tienen regla a propósito: ya se pueden pedir con
// cualquier bebida desde el detalle del producto y no se debe romper
// ese flujo. Solo los toppings nuevos se restringen.
export const TOPPING_RULES = {
    "Cacao en polvo": { keywords: MILK_COFFEE_KEYWORDS },
    "Virutas de chocolate": {
        keywords: [...MILK_COFFEE_KEYWORDS, ...CHOCOLATE_KEYWORDS]
    },
    "Malvaviscos": {
        types: ["Caliente"],
        keywords: [...CHOCOLATE_KEYWORDS, "latte"]
    }
};

// Jarabes y endulzantes: hoy NO existen en la base de datos ni en el
// menú, así que los catálogos arrancan vacíos a propósito (no se
// inventan sabores ni precios). Cuando el negocio defina los suyos,
// basta con agregarlos aquí, ej.  "Vainilla": 1500  — el minijuego,
// el carrito y los pedidos los validan y cobran sin más cambios.
// Cantidades de toppings: la primera porción se cobra al precio del
// catálogo (TOPPING_PRICES) y cada porción adicional del MISMO topping
// suma TOPPING_EXTRA_PORTION_PRICE. Máximo MAX_TOPPING_QUANTITY por topping.
export const TOPPING_EXTRA_PORTION_PRICE = 300;
export const MAX_TOPPING_QUANTITY = 5;

export const SYRUP_PRICES = {};

// Endulzantes: se entregan en un sobre individual junto a la bebida.
// Todos van incluidos en el precio (0). OJO: el negocio aún no definió
// si alguno se cobra; si es así, basta con cambiar el valor aquí.
export const SWEETENER_PRICES = {
    "Azúcar blanca": 0,
    "Azúcar morena": 0,
    "Estevia": 0,
    "Panela": 0,
    "Miel": 0
};
export const MAX_SYRUPS = 3;
export const MAX_SWEETENERS = 3;

// Latte art: solo tres diseños predefinidos (decoración, no cuesta).
export const LATTE_ART_DESIGNS = ["Corazón", "Hoja", "Cisne", "Tulipán", "Rosetta", "Estrella"];

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
    toppingQuantities: {},
    syrups: [],
    sweeteners: [],
    latteArt: ""
};

// ¿El topping [name] va con esta bebida? [product] puede ser null (se
// asume que sí); [type] es "Caliente" o "Frío".
export const isToppingCompatible = (name, product, type) => {

    const rule = TOPPING_RULES[name];

    if (!rule) return true;

    if (rule.types && type && !rule.types.includes(type)) return false;

    const text = `${product?.name || ""} ${product?.categoryId?.name || ""}`
        .toLowerCase();

    if (!product) return true;

    if (rule.exclude && rule.exclude.some(k => text.includes(k))) {
        return false;
    }

    if (rule.keywords && !rule.keywords.some(k => text.includes(k))) {
        return false;
    }

    return true;
};

// Toppings: acepta la lista antigua ["Canela"] (1 porción cada uno)
// o un mapa { "Canela": 2 }. Devuelve { names, quantities } o { error }.
// Si `raw` es lista y viene `qtyMap` (formato guardado en carrito,
// pedidos y recetas), las porciones salen de ahí (por defecto 1).
const normalizeToppings = (raw, qtyMap) => {

    if (raw === undefined || raw === null) {
        return { names: [], quantities: {} };
    }

    let entries;

    if (Array.isArray(raw)) {
        const map =
            qtyMap && typeof qtyMap === "object" && !Array.isArray(qtyMap)
                ? qtyMap
                : {};
        entries = raw.map(name => [name, map[name] ?? 1]);
    } else if (typeof raw === "object") {
        entries = Object.entries(raw);
    } else {
        return { error: "Toppings must be a list" };
    }

    const quantities = {};

    for (const [name, rawQty] of entries) {

        if (!Object.prototype.hasOwnProperty.call(TOPPING_PRICES, name)) {
            return { error: `Invalid topping: ${String(name)}` };
        }

        const qty = Number(rawQty);

        if (!Number.isInteger(qty) || qty < 0 || qty > MAX_TOPPING_QUANTITY) {
            return {
                error: `La cantidad de ${name} debe ser un entero entre 0 y ${MAX_TOPPING_QUANTITY}`
            };
        }

        // Un nombre repetido en la lista no suma porciones: se queda la última.
        if (qty > 0) quantities[name] = qty;
    }

    const names = Object.keys(quantities).sort();
    const ordered = {};
    for (const n of names) ordered[n] = quantities[n];

    return { names, quantities: ordered };
};

// Precio de un topping según su cantidad (0 porciones = no se cobra).
export const toppingLinePrice = (name, quantity) => {

    const qty = Number(quantity) || 0;

    if (qty <= 0) return 0;

    return (TOPPING_PRICES[name] || 0)
        + (qty - 1) * TOPPING_EXTRA_PORTION_PRICE;
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

    // Orden estable: "Canela+Caramelo" y "Caramelo+Canela" producen la
    // misma clave de línea. `toppingQuantities` guarda las porciones.
    const toppingsResult = normalizeToppings(input.toppings, input.toppingQuantities);
    if (toppingsResult.error) return { error: toppingsResult.error };

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
            toppings: toppingsResult.names,
            toppingQuantities: toppingsResult.quantities,
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
        extra += toppingLinePrice(
            topping,
            c.toppingQuantities?.[topping] ?? 1
        );
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
        (c.toppings || [])
            .map(t => {
                const q = c.toppingQuantities?.[t] ?? 1;
                return q > 1 ? `${t}x${q}` : t;
            })
            .join(",")
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
                toppingQuantities: {},
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

    for (const topping of customization.toppings) {
        if (!isToppingCompatible(topping, product, customization.type)) {
            return {
                error: `${topping} no va con esta bebida`
            };
        }
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
    toppingRules: {
        extraPortionPrice: TOPPING_EXTRA_PORTION_PRICE,
        maxQuantity: MAX_TOPPING_QUANTITY,
        compatibility: JSON.parse(JSON.stringify(TOPPING_RULES))
    },
    syrups: { prices: { ...SYRUP_PRICES }, max: MAX_SYRUPS },
    sweeteners: { prices: { ...SWEETENER_PRICES }, max: MAX_SWEETENERS },
    sizeOunces: { ...SIZE_OUNCES },
    sizeRules: { minPriceAfterSize: MIN_PRICE_AFTER_SIZE },
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
