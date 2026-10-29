// ===================================
// CHAT PLANNER (comprensión de lenguaje natural + acciones)
// ===================================
// Módulo PURO (sin base de datos ni red): recibe el catálogo ya leído
// y devuelve qué debe hacer el chat. Así se puede probar a fondo.
//
// Principio de seguridad: todo lo que toca dinero o el carrito se
// decide AQUÍ y en el servidor, nunca por texto libre del modelo de IA.
//   - Los productos, precios, ingredientes y promociones salen del
//     catálogo recibido; nada se inventa.
//   - Agregar al carrito siempre pasa por una PROPUESTA que el cliente
//     debe confirmar. El planificador solo propone; quien ejecuta es el
//     controlador, con las mismas validaciones del carrito.
//   - El chat nunca paga ni crea pedidos.
//
// Si el mensaje no encaja en ninguna intención conocida, devuelve
// { handled: false } y el controlador consulta al modelo de IA solo
// para conversar (con el mismo catálogo como fuente).

import {
    SIZE_PRICES,
    TYPE_OPTIONS,
    isCustomizableProduct,
    resolveCustomization
} from "./customization.js";

import {
    customizationBreakdown,
    clampDiscount
} from "./pricing.js";

export const MAX_QUANTITY_PER_LINE = 10;
export const MAX_CARDS = 4;
export const PENDING_TTL_MS = 10 * 60 * 1000;

// ===================================
// TEXTO
// ===================================

export const normalizeText = (value) =>
    String(value ?? "")
        .toLowerCase()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .replace(/[^a-z0-9ñ\s]/g, " ")
        .replace(/\s+/g, " ")
        .trim();

const tokenize = (value) =>
    normalizeText(value).split(" ").filter(Boolean);

// "lattes" -> ["lattes","latte","latt"]: se compara por variantes para
// tolerar plurales sin un lematizador completo.
const variantsOf = (token) => {
    const out = [token];
    if (token.length > 3 && token.endsWith("s")) out.push(token.slice(0, -1));
    if (token.length > 4 && token.endsWith("es")) out.push(token.slice(0, -2));
    return out;
};

const editDistanceAtMostOne = (a, b) => {
    if (a === b) return true;
    if (Math.abs(a.length - b.length) > 1) return false;
    let i = 0;
    let j = 0;
    let edits = 0;
    while (i < a.length && j < b.length) {
        if (a[i] === b[j]) { i++; j++; continue; }
        edits++;
        if (edits > 1) return false;
        if (a.length > b.length) i++;
        else if (a.length < b.length) j++;
        else { i++; j++; }
    }
    return edits + (a.length - i) + (b.length - j) <= 1;
};

const sameWord = (a, b) => {
    const va = variantsOf(a);
    const vb = variantsOf(b);
    if (va.some(x => vb.includes(x))) return true;
    // Tolera una letra de diferencia ("capuccino") en palabras largas.
    return va.some(x => x.length >= 6 && vb.some(y => y.length >= 6 && editDistanceAtMostOne(x, y)));
};

const hasWord = (tokens, word) => tokens.some(t => sameWord(t, word));

const hasAnyWord = (tokens, words) => words.some(w => hasWord(tokens, w));

// ===================================
// CANTIDADES Y ATRIBUTOS
// ===================================

const NUMBER_WORDS = {
    un: 1, uno: 1, una: 1,
    dos: 2, tres: 3, cuatro: 4, cinco: 5,
    seis: 6, siete: 7, ocho: 8, nueve: 9, diez: 10,
    once: 11, doce: 12
};

export const parseQuantity = (text) => {
    const tokens = tokenize(text);

    for (const token of tokens) {
        if (/^\d{1,3}$/.test(token)) return Number(token);
        if (Object.prototype.hasOwnProperty.call(NUMBER_WORDS, token)) {
            return NUMBER_WORDS[token];
        }
    }

    return null;
};

const COLD_WORDS = ["frio", "fria", "helado", "helada", "iced", "cold", "fresco", "refrescante"];
const HOT_WORDS = ["caliente", "tibio", "calientico"];
const SWEET_WORDS = ["dulce", "dulzon", "azucarado"];

const SIZE_WORDS = {
    "Pequeño": ["pequeno", "pequena", "chico", "chica", "small"],
    "Mediano": ["mediano", "mediana", "medio", "regular", "normal"],
    "Grande": ["grande", "large", "gigante"]
};

export const parseSlots = (text) => {
    const tokens = tokenize(text);
    const slots = {};

    for (const [size, words] of Object.entries(SIZE_WORDS)) {
        if (hasAnyWord(tokens, words)) slots.size = size;
    }

    if (hasAnyWord(tokens, COLD_WORDS)) slots.type = "Frío";
    else if (hasAnyWord(tokens, HOT_WORDS)) slots.type = "Caliente";

    return slots;
};

// Palabras de bebida que por sí solas indican frío en el catálogo.
const COLD_CATALOG_WORDS = [
    "frio", "helado", "iced", "cold", "frappe", "smoothie",
    "malteada", "limonada", "jugo", "granizado", "batido", "cold brew"
];

const SWEET_CATALOG_WORDS = [
    "dulce", "caramelo", "vainilla", "chocolate", "moca", "mocha", "miel",
    "avellana", "arequipe", "dulce de leche", "azucar", "crema", "cocada"
];

// ===================================
// PRODUCTOS
// ===================================

const STOP = new Set([
    "quiero", "quisiera", "quieres", "gustaria", "agrega", "agregame", "agregar", "agregue",
    "anade", "anademe", "anadir", "pon", "ponme", "poner", "dame", "deme", "pideme", "pedir",
    "pido", "compra", "comprar", "necesito", "ordena", "ordenar", "me", "un", "una", "uno",
    "unos", "unas", "el", "la", "los", "las", "de", "del", "al", "con", "sin", "por", "favor",
    "para", "mi", "mis", "carrito", "y", "o", "que", "qu", "tienen", "hay", "tiene", "este",
    "esta", "ese", "esa", "algo", "mas", "otro", "otra", "podrias", "puedes", "tu", "su", "es",
    "en", "lo", "si", "no", "a", "e", "ya", "tambien", "cuanto", "cuesta", "vale", "precio",
    "cual", "cuales", "como", "son", "seria", "sabe", "sabor", "tamano", "tamanos", "ingrediente",
    "ingredientes", "lleva", "dime", "muestrame", "muestra", "ver", "dos", "tres", "cuatro",
    "cinco", "seis", "siete", "ocho", "nueve", "diez", "once", "doce",
    ...COLD_WORDS, ...HOT_WORDS, ...SWEET_WORDS,
    ...Object.values(SIZE_WORDS).flat()
]);

const contentTokens = (text) =>
    tokenize(text).filter(t => !STOP.has(t) && !/^\d+$/.test(t));

const productTokens = (product) => contentTokens(product.name);

const categoryNameOf = (product) =>
    product?.categoryId?.name || product?.category || "";

// Busca productos del catálogo mencionados en el texto.
//   exact     -> un único producto claramente nombrado
//   ambiguous -> varios podrían ser (p. ej. "latte" con 3 lattes)
//   none      -> ninguno
export const findProducts = (text, catalog) => {

    const wanted = contentTokens(text);

    if (wanted.length === 0) return { kind: "none", products: [] };

    const scored = [];

    for (const product of catalog) {

        const nameTokens = productTokens(product);

        if (nameTokens.length === 0) continue;

        const matched = nameTokens.filter(nt => wanted.some(w => sameWord(w, nt)));

        if (matched.length === 0) continue;

        scored.push({
            product,
            matched: matched.length,
            total: nameTokens.length,
            full: matched.length === nameTokens.length
        });
    }

    if (scored.length === 0) return { kind: "none", products: [] };

    // Un producto cuyo nombre completo (y solo ese) coincide con lo
    // que se pidió: es el elegido, aunque otros compartan una palabra.
    const exactNames = scored.filter(s =>
        s.full &&
        wanted.length === s.total &&
        wanted.every(w => productTokens(s.product).some(nt => sameWord(w, nt)))
    );

    if (exactNames.length === 1) {
        return { kind: "exact", products: [exactNames[0].product] };
    }

    // Si el texto contiene el nombre completo de un único producto y
    // ningún otro lo contiene entero con más palabras, también es claro.
    const fulls = scored.filter(s => s.full);

    if (fulls.length > 0) {
        const maxTokens = Math.max(...fulls.map(s => s.total));
        const best = fulls.filter(s => s.total === maxTokens);

        if (best.length === 1 && fulls.every(s => s.total < maxTokens || s === best[0])) {
            // Solo si el resto de coincidencias completas son sub-nombres
            // del elegido (p. ej. "Latte" dentro de "Latte vainilla").
            const chosenTokens = productTokens(best[0].product);
            const othersAreSubsets = fulls
                .filter(s => s !== best[0])
                .every(s => productTokens(s.product).every(t =>
                    chosenTokens.some(ct => sameWord(ct, t))));

            if (othersAreSubsets && wanted.length >= maxTokens) {
                return { kind: "exact", products: [best[0].product] };
            }
        }
    }

    scored.sort((a, b) =>
        (b.matched / b.total) - (a.matched / a.total) ||
        b.matched - a.matched ||
        (b.product.reviewCount || 0) - (a.product.reviewCount || 0)
    );

    const list = scored.map(s => s.product);

    if (list.length === 1) {
        return { kind: "exact", products: list };
    }

    return { kind: "ambiguous", products: list };
};

// Categorías mencionadas ("postres", "bebidas frías"...).
const findCategories = (text, categories) => {
    const tokens = contentTokens(text);

    return categories.filter(category => {
        const catTokens = contentTokens(category.name);
        return catTokens.length > 0 &&
            catTokens.every(ct => tokens.some(t => sameWord(t, ct)));
    });
};

const productSearchText = (product) =>
    normalizeText([
        product.name,
        categoryNameOf(product),
        product.description,
        ...(product.ingredients || [])
    ].join(" "));

const matchesAny = (haystack, words) =>
    words.some(w => haystack.includes(w));

const isDrink = (product) => isCustomizableProduct(product);

// ===================================
// PRECIOS (mismo cálculo que el carrito)
// ===================================

export const formatCOP = (value) =>
    `$${Number(value || 0).toLocaleString("es-CO")}`;

export const priceLine = (product, customization, quantity, resolver) => {

    const breakdown = customizationBreakdown(customization, product.price);
    const originalUnitPrice = product.price + breakdown.customizationPrice;
    const applied = resolver ? resolver(product._id, product.price) : null;
    const discountPerUnit = clampDiscount(
        applied ? applied.discountPerUnit : 0,
        originalUnitPrice
    );
    const unitPrice = originalUnitPrice - discountPerUnit;

    return {
        originalUnitPrice,
        discountPerUnit,
        unitPrice,
        lineTotal: unitPrice * quantity,
        promotionName: applied ? applied.promotion?.name || "" : ""
    };
};

const describeOptions = (customization, product) => {
    if (!isCustomizableProduct(product)) return [];
    const out = [customization.size, customization.type, `Leche ${customization.milk.toLowerCase()}`];
    return out;
};

const sizePriceList = (product, resolver) =>
    Object.keys(SIZE_PRICES).map(size => {
        const { customization } = resolveCustomization(product, { size, type: "Caliente" });
        const { unitPrice } = priceLine(product, customization, 1, resolver);
        return { size, unitPrice };
    });

const pid = (product) => String(product._id);

// ===================================
// INTENCIONES
// ===================================

const ADD_VERBS = [
    "agrega", "agregame", "agregar", "anade", "anademe", "anadir", "pon", "ponme",
    "dame", "deme", "pideme", "pedir", "pido", "compra", "comprar", "ordena", "ordenar",
    "quiero", "quisiera", "necesito", "llevo", "llevar"
];

const matchYes = (norm) =>
    /^(si|sii+|dale|claro|confirmo|confirmar|ok|okay|vale|listo|de una|correcto|perfecto|adelante|hagale|exacto|agregalo|agregalos)\b/.test(norm);

const matchNo = (norm) =>
    /^(no|nop|cancela|cancelar|cancelalo|mejor no|olvidalo|nada|dejalo)\b/.test(norm);

export const detectIntent = (text) => {

    const norm = normalizeText(text);
    const tokens = norm.split(" ").filter(Boolean);

    if (!norm) return "EMPTY";

    if (/\b(vacia|vaciar|vacies|borra|borrar|limpia|limpiar|elimina|eliminar|quita todo)\b.*\bcarrito\b|\bcarrito\b.*\b(vacio|limpio)\b/.test(norm)) {
        return "CLEAR_CART";
    }

    if (/\b(pagar|pago|paga|pagarlo|finalizar|finaliza|confirmar el pedido|confirma el pedido|hacer el pedido|realizar el pedido|realizar la compra|checkout|terminar la compra|cerrar el pedido)\b/.test(norm)) {
        return "CHECKOUT";
    }

    if (/\b(ver|mostrar|muestrame|abre|abrir|ir)\b.*\bcarrito\b|\bque tengo en (mi )?carrito\b|\bmi carrito\b$/.test(norm)) {
        return "OPEN_CART";
    }

    if (/\b(promo|promocion|promociones|descuento|descuentos|oferta|ofertas|cupon|cupones|rebaja)\b/.test(norm)) {
        return "PROMOTIONS";
    }

    if (/\b(compara|comparar|comparame|comparacion|diferencia|diferencias|versus|vs)\b/.test(norm)) {
        return "COMPARE";
    }

    if (/\b(ingrediente|ingredientes|lleva|llevan|contiene|hecho|hecha|sabor|sabores|sabe|tamano|tamanos|precio|cuesta|cuanto|vale|calorias|alergeno|descripcion|detalle|detalles|info|informacion)\b/.test(norm)) {
        return "DETAILS";
    }

    if (hasAnyWord(tokens, ADD_VERBS) && !/\b(algo|recomiend\w*|sugier\w*)\b/.test(norm)) {
        return "ADD";
    }

    if (/\b(recomienda|recomiendame|recomendar|recomendacion|recomendaciones|sugiere|sugiereme|sugerencia|sugerencias|que me recomiendas|que me sugieres|algo)\b/.test(norm)) {
        return "RECOMMEND";
    }

    if (/\b(categoria|categorias)\b/.test(norm)) {
        return "CATEGORIES";
    }

    if (/\b(menu|carta|que hay|que tienen|que ofrecen|muestrame|ver|opciones|disponibles|disponible)\b/.test(norm)) {
        return "LIST";
    }

    return "OTHER";
};

// ===================================
// RESPUESTAS
// ===================================

const result = (reply, extra = {}) => ({
    handled: true,
    reply,
    productIds: [],
    quickReplies: [],
    actions: [],
    ...extra
});

const cardsOf = (products) => products.slice(0, MAX_CARDS).map(pid);

const emptyState = () => ({
    productId: null,
    quantity: null,
    size: null,
    type: null,
    awaiting: null,
    candidateIds: []
});

export const normalizeState = (state) => ({ ...emptyState(), ...(state || {}) });

const formatDateCO = (date) =>
    new Date(date).toLocaleDateString("es-CO", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
        timeZone: "America/Bogota"
    });

const promoBenefit = (promotion) =>
    promotion.discountType === "percentage"
        ? `${promotion.discountValue}% de descuento`
        : `${formatCOP(promotion.discountValue)} de descuento`;

const askWhichProduct = (candidates, state, verbHint) => {
    const shown = candidates.slice(0, MAX_CARDS);
    return result(
        `Tengo varias opciones, ¿cuál ${verbHint}? Elige una de las tarjetas.`,
        {
            productIds: cardsOf(shown),
            state: {
                ...state,
                awaiting: "product",
                candidateIds: shown.map(pid)
            },
            quickReplies: []
        }
    );
};

const suggestCategories = (categories) =>
    categories.slice(0, 4).map(c => ({ label: c.name, text: `Muéstrame ${c.name}` }));

// ===================================
// PLANIFICADOR
// ===================================
// input:
//   text         mensaje del cliente
//   catalog      productos DISPONIBLES (con categoryId poblado)
//   unavailable  productos conocidos pero no disponibles (opcional)
//   categories   categorías activas [{ name }]
//   promotions   promociones vigentes con productos (opcional)
//   state        estado de la conversación (normalizeState)
//   resolver     (productId, basePrice) => { discountPerUnit, promotion } | null
//   hasPending   hay una propuesta esperando confirmación
//   isLoggedIn   el cliente tiene sesión
//   selectProductId  id elegido desde una tarjeta (opcional)
//
// Devuelve { handled:false } si debe responder el modelo de IA; si no:
//   { handled:true, reply, productIds, quickReplies, actions, state,
//     proposal?, execute?: "confirm"|"cancel" , needsLogin? }

export const planTurn = ({
    text,
    catalog = [],
    unavailable = [],
    categories = [],
    promotions = [],
    state: rawState,
    resolver = null,
    hasPending = false,
    isLoggedIn = false,
    selectProductId = null
}) => {

    const state = normalizeState(rawState);
    const norm = normalizeText(text);
    const byId = new Map(catalog.map(p => [pid(p), p]));

    // 1. Respuesta a una propuesta pendiente.
    if (hasPending) {
        if (matchYes(norm)) return { handled: true, execute: "confirm", state };
        if (matchNo(norm)) return { handled: true, execute: "cancel", state };
    }

    // 2. Elección directa desde una tarjeta.
    let intent = detectIntent(text);
    let picked = null;

    if (selectProductId) {
        picked = byId.get(String(selectProductId)) || null;

        if (!picked) {
            return result("Ese producto ya no está disponible. ¿Quieres ver otras opciones? ☕", {
                state: emptyState(),
                quickReplies: suggestCategories(categories)
            });
        }

        intent = "ADD";
    }

    const slots = parseSlots(text);
    const quantity = parseQuantity(text);

    // 3. Mientras se espera tamaño/temperatura, esas respuestas
    //    continúan la compra sin repetir el producto.
    if (
        !picked &&
        state.productId &&
        (state.awaiting === "size" || state.awaiting === "type") &&
        (slots.size || slots.type) &&
        (intent === "OTHER" || intent === "ADD")
    ) {
        picked = byId.get(state.productId) || null;
        intent = "ADD";
    }

    // 4. Elegir entre candidatos escribiendo el nombre.
    if (!picked && state.awaiting === "product" && state.candidateIds.length && intent !== "DETAILS") {
        const pool = state.candidateIds.map(id => byId.get(id)).filter(Boolean);
        const found = findProducts(text, pool);

        if (found.kind === "exact") {
            picked = found.products[0];
            intent = "ADD";
        }
    }

    switch (intent) {

        case "EMPTY":
            return { handled: false };

        case "CLEAR_CART":
            if (!isLoggedIn) {
                return result("Inicia sesión para que pueda ayudarte con tu carrito ☕", { needsLogin: true, state });
            }
            return result("¿Seguro que quieres vaciar tu carrito? Esta acción quita todos los productos.", {
                state,
                proposal: { type: "CLEAR_CART", items: [], total: 0 },
                quickReplies: [
                    { label: "Sí, vaciar", text: "sí" },
                    { label: "No, cancelar", text: "no" }
                ]
            });

        case "CHECKOUT":
            return result(
                "Yo puedo dejarte el pedido listo en el carrito, pero el pago y la confirmación final los haces tú desde la pantalla del carrito, para que tengas el control ☕",
                { state, actions: [{ type: "open_cart" }], quickReplies: [{ label: "Ver mi carrito", text: "Ver mi carrito" }] }
            );

        case "OPEN_CART":
            return result("Aquí tienes tu carrito.", { state, actions: [{ type: "open_cart" }] });

        case "CATEGORIES": {
            if (categories.length === 0) {
                return result("Por ahora no tengo categorías activas para mostrarte.", { state });
            }
            return result(
                `Estas son nuestras categorías: ${categories.map(c => c.name).join(", ")}. ¿Cuál te interesa?`,
                { state, quickReplies: suggestCategories(categories) }
            );
        }

        case "PROMOTIONS": {
            const promoted = catalog.filter(p => resolver && resolver(p._id, p.price));
            if (promotions.length === 0 && promoted.length === 0) {
                return result("Por ahora no hay promociones vigentes. Escríbeme más tarde o mira Inicio, que ahí aparecen primero ☕", { state });
            }
            const lines = promotions.slice(0, 4).map(p =>
                `${p.name}: ${promoBenefit(p)}${p.endDate ? ` (hasta el ${formatDateCO(p.endDate)})` : ""}`
            );
            const reply = lines.length
                ? `Estas son las promociones vigentes:\n${lines.join("\n")}`
                : "Estos productos tienen descuento ahora mismo:";
            return result(promoted.length ? `${reply}${promoted.length ? "\nMira los productos con descuento:" : ""}` : reply, {
                state,
                productIds: cardsOf(promoted)
            });
        }

        case "COMPARE": {
            const parts = String(text).split(/\s+(?:y|vs|versus|con|contra|o)\s+|\bentre\b/i);
            const found = [];

            for (const part of parts) {
                const r = findProducts(part, catalog);
                if (r.kind === "exact" && !found.includes(r.products[0])) found.push(r.products[0]);
            }

            if (found.length < 2) {
                return result("¿Qué dos productos quieres comparar? Por ejemplo: «compara el latte con el capuchino».", { state });
            }

            const [a, b] = found;
            const line = (p) => {
                const ing = (p.ingredients || []).join(", ") || "ingredientes no especificados";
                return `${p.name} (${categoryNameOf(p) || "sin categoría"}): ${formatCOP(p.price)} · ${ing}`;
            };
            const cheaper = a.price === b.price
                ? "Cuestan lo mismo."
                : `${a.price < b.price ? a.name : b.name} es más económico por ${formatCOP(Math.abs(a.price - b.price))}.`;

            return result(`${line(a)}\n${line(b)}\n${cheaper}`, {
                state: { ...state, productId: null },
                productIds: [pid(a), pid(b)]
            });
        }

        case "DETAILS": {
            let target = null;
            const found = findProducts(text, catalog);

            if (found.kind === "exact") target = found.products[0];
            else if (found.kind === "ambiguous") return askWhichProduct(found.products, state, "te interesa");
            else if (state.productId) target = byId.get(state.productId) || null;

            if (!target) {
                const gone = findProducts(text, unavailable);
                if (gone.kind === "exact") {
                    return unavailableReply(gone.products[0], catalog, state);
                }
                return result("¿De qué producto quieres saber? Dime el nombre y te cuento ingredientes, tamaños y precio ☕", {
                    state,
                    quickReplies: suggestCategories(categories)
                });
            }

            const applied = resolver ? resolver(target._id, target.price) : null;
            const parts = [`${target.name} — ${categoryNameOf(target) || "sin categoría"}.`];
            parts.push(applied
                ? `Precio: ${formatCOP(target.price - applied.discountPerUnit)} (antes ${formatCOP(target.price)}, ${applied.promotion?.name || "promoción vigente"}).`
                : `Precio: ${formatCOP(target.price)}.`);
            parts.push(target.description ? `Descripción: ${target.description}` : "No tengo una descripción registrada.");
            parts.push((target.ingredients || []).length
                ? `Ingredientes: ${target.ingredients.join(", ")}.`
                : "No tengo los ingredientes registrados para este producto.");

            if (isDrink(target)) {
                parts.push(`Tamaños: ${sizePriceList(target, resolver).map(s => `${s.size} ${formatCOP(s.unitPrice)}`).join(", ")}.`);
            }

            return result(parts.join("\n"), {
                state: { ...state, productId: pid(target), awaiting: null },
                productIds: [pid(target)],
                quickReplies: [{ label: "Agregar al carrito", text: `Agrégame ${target.name}` }]
            });
        }

        case "ADD":
            return planAdd({ text, picked, slots, quantity, catalog, unavailable, categories, state, resolver, isLoggedIn, byId });

        case "RECOMMEND":
        case "LIST": {
            const wantsCold = hasAnyWord(tokenize(text), COLD_WORDS);
            const wantsHot = hasAnyWord(tokenize(text), HOT_WORDS);
            const wantsSweet = hasAnyWord(tokenize(text), SWEET_WORDS);

            const cats = findCategories(text, categories);
            const byName = findProducts(text, catalog);

            let pool = catalog;
            let scope = "";

            if (cats.length) {
                const names = cats.map(c => normalizeText(c.name));
                pool = catalog.filter(p => names.includes(normalizeText(categoryNameOf(p))));
                scope = cats[0].name;
            } else if (byName.kind !== "none") {
                pool = byName.products;
                scope = byName.products.length === 1 ? byName.products[0].name : "esa búsqueda";
            } else if (wantsCold || wantsHot || wantsSweet) {
                pool = catalog.filter(isDrink);
            }

            if (pool.length === 0) {
                return result("No encontré productos para esa búsqueda. ¿Quieres ver las categorías disponibles? ☕", {
                    state,
                    quickReplies: suggestCategories(categories)
                });
            }

            let note = "";
            let filtered = pool;

            if (wantsCold) {
                const cold = filtered.filter(p => matchesAny(productSearchText(p), COLD_CATALOG_WORDS));
                if (cold.length) filtered = cold;
                else note = "Ninguna está marcada como fría, pero cualquier bebida se puede pedir Fría al agregarla. ";
            }

            if (wantsSweet) {
                const sweet = filtered.filter(p => matchesAny(productSearchText(p), SWEET_CATALOG_WORDS));
                if (sweet.length) filtered = sweet;
                else note += "No tengo ninguna marcada como dulce por sus ingredientes, estas son las disponibles. ";
            }

            filtered = [...filtered].sort((a, b) =>
                (b.rating || 0) - (a.rating || 0) ||
                (b.reviewCount || 0) - (a.reviewCount || 0)
            );

            const head = scope
                ? `Esto tenemos en ${scope}:`
                : "Te sugiero estas opciones:";

            return result(`${note}${head}`, {
                state: { ...state, awaiting: filtered.length > 1 ? "product" : null, candidateIds: filtered.slice(0, MAX_CARDS).map(pid) },
                productIds: cardsOf(filtered),
                quickReplies: wantsCold && !note ? [] : []
            });
        }

        default:
            // Respuesta suelta con producto ya elegido ("el grande").
            if (state.productId && (slots.size || slots.type || quantity)) {
                return planAdd({
                    text, picked: byId.get(state.productId) || null, slots, quantity,
                    catalog, unavailable, categories, state, resolver, isLoggedIn, byId
                });
            }
            return { handled: false, state };
    }
};

const unavailableReply = (product, catalog, state) => {
    const sameCategory = catalog
        .filter(p => normalizeText(categoryNameOf(p)) === normalizeText(categoryNameOf(product)))
        .slice(0, MAX_CARDS);
    const alternatives = sameCategory.length ? sameCategory : catalog.slice(0, MAX_CARDS);

    return result(
        `${product.name} no está disponible por ahora. Te dejo opciones parecidas:`,
        { state: { ...state, productId: null }, productIds: cardsOf(alternatives) }
    );
};

const planAdd = ({ text, picked, slots, quantity, catalog, unavailable, categories, state, resolver, isLoggedIn, byId }) => {

    let product = picked;

    if (!product) {
        const found = findProducts(text, catalog);

        if (found.kind === "exact") {
            product = found.products[0];
        } else if (found.kind === "ambiguous") {
            return askWhichProduct(
                found.products,
                { ...state, quantity: quantity || state.quantity, size: slots.size || state.size, type: slots.type || state.type },
                "quieres"
            );
        } else {
            const gone = findProducts(text, unavailable);
            if (gone.kind === "exact") return unavailableReply(gone.products[0], catalog, state);

            // «agrégame dos» con un producto ya elegido en la charla.
            if (state.productId && byId.get(state.productId)) {
                product = byId.get(state.productId);
            } else {
                const cats = findCategories(text, categories);
                if (cats.length) {
                    const names = cats.map(c => normalizeText(c.name));
                    const pool = catalog.filter(p => names.includes(normalizeText(categoryNameOf(p))));
                    if (pool.length) {
                        return askWhichProduct(pool, { ...state, quantity: quantity || state.quantity }, "quieres");
                    }
                }
                return result(
                    "No encontré ese producto en nuestro catálogo. Dime otro nombre o elige una categoría y te muestro lo disponible ☕",
                    { state: emptyState(), quickReplies: suggestCategories(categories) }
                );
            }
        }
    }

    if (!isLoggedIn) {
        return result(
            `Para agregar ${product.name} al carrito necesitas iniciar sesión. Mientras tanto te muestro el producto:`,
            { needsLogin: true, state, productIds: [pid(product)] }
        );
    }

    // Si cambió el producto, no arrastramos opciones del anterior.
    const sameProduct = state.productId === pid(product);

    const qty = quantity || (sameProduct ? state.quantity : null) || 1;

    if (qty > MAX_QUANTITY_PER_LINE) {
        return result(
            `Por pedido puedo agregar hasta ${MAX_QUANTITY_PER_LINE} unidades de un mismo producto. ¿Cuántas quieres?`,
            { state: { ...state, productId: pid(product), quantity: null }, productIds: [pid(product)] }
        );
    }

    if (qty < 1) {
        return result("La cantidad debe ser de al menos una unidad. ¿Cuántas quieres?", {
            state: { ...state, productId: pid(product) }
        });
    }

    const next = {
        productId: pid(product),
        quantity: qty,
        size: slots.size || (sameProduct ? state.size : null),
        type: slots.type || (sameProduct ? state.type : null),
        awaiting: null,
        candidateIds: []
    };

    let customization;

    if (isCustomizableProduct(product)) {

        // Algunas bebidas ya dicen su temperatura en el nombre.
        const nameText = normalizeText(`${product.name} ${categoryNameOf(product)}`);
        if (!next.type && matchesAny(nameText, ["helado", "frio", "iced", "frappe", "cold brew"])) next.type = "Frío";
        if (!next.type && matchesAny(nameText, ["caliente"])) next.type = "Caliente";

        if (!next.size) {
            const prices = sizePriceList(product, resolver);
            return result(
                `¿De qué tamaño quieres ${qty > 1 ? `tus ${qty} ${product.name}` : `tu ${product.name}`}?`,
                {
                    state: { ...next, awaiting: "size" },
                    productIds: [pid(product)],
                    quickReplies: prices.map(s => ({ label: `${s.size} ${formatCOP(s.unitPrice)}`, text: s.size }))
                }
            );
        }

        if (!next.type) {
            return result(
                `¿Lo quieres ${TYPE_OPTIONS.join(" o ").toLowerCase()}?`,
                {
                    state: { ...next, awaiting: "type" },
                    productIds: [pid(product)],
                    quickReplies: TYPE_OPTIONS.map(t => ({ label: t, text: t }))
                }
            );
        }

        const resolved = resolveCustomization(product, { size: next.size, type: next.type });

        if (resolved.error) {
            return result(`No pude preparar esa combinación: ${resolved.error}.`, { state: { ...next, awaiting: null } });
        }

        customization = resolved.customization;

    } else {
        customization = resolveCustomization(product, {}).customization;
    }

    const price = priceLine(product, customization, qty, resolver);
    const options = describeOptions(customization, product);

    const item = {
        productId: pid(product),
        name: product.name,
        quantity: qty,
        customization,
        options,
        originalUnitPrice: price.originalUnitPrice,
        discountPerUnit: price.discountPerUnit,
        unitPrice: price.unitPrice,
        lineTotal: price.lineTotal,
        promotionName: price.promotionName
    };

    return result(
        `Voy a agregar ${qty} × ${product.name}${options.length ? ` (${options.join(", ")})` : ""} por ${formatCOP(price.lineTotal)}. ¿Confirmas?`,
        {
            state: { ...next, awaiting: "confirm" },
            productIds: [pid(product)],
            proposal: { type: "ADD_TO_CART", items: [item], total: price.lineTotal },
            quickReplies: [
                { label: "Sí, agregar", text: "sí" },
                { label: "Cancelar", text: "no" }
            ]
        }
    );
};
