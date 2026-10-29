import test from "node:test";
import assert from "node:assert/strict";

import {
    planTurn,
    parseQuantity,
    parseSlots,
    detectIntent,
    findProducts,
    normalizeState,
    MAX_QUANTITY_PER_LINE
} from "../utils/chatPlanner.js";

const cat = (name) => ({ name });
const P = (id, name, price, category, extra = {}) => ({
    _id: id,
    name,
    price,
    categoryId: cat(category),
    description: "",
    ingredients: [],
    rating: 0,
    reviewCount: 0,
    isAvailable: true,
    ...extra
});

const catalog = [
    P("a1", "Latte Vainilla", 12000, "Cafés", { ingredients: ["Espresso", "Leche", "Vainilla"], rating: 4.8, reviewCount: 10 }),
    P("a2", "Latte Caramelo", 13000, "Cafés", { ingredients: ["Espresso", "Leche", "Caramelo"], rating: 4.5, reviewCount: 4 }),
    P("a3", "Capuchino", 9000, "Cafés", { ingredients: ["Espresso", "Leche", "Espuma"] }),
    P("a4", "Limonada Cerezada", 8000, "Bebidas frías", { ingredients: ["Limón", "Cereza"] }),
    P("a5", "Brownie", 7000, "Postres", { ingredients: ["Chocolate", "Harina"] }),
    P("a6", "Americano", 6000, "Cafés")
];
const categories = [cat("Cafés"), cat("Bebidas frías"), cat("Postres")];
const unavailable = [P("u1", "Cheesecake", 11000, "Postres", { isAvailable: false })];

const base = { catalog, categories, unavailable, resolver: null, isLoggedIn: true };

test("cantidades en dígitos y palabras", () => {
    assert.equal(parseQuantity("agrégame dos capuchinos"), 2);
    assert.equal(parseQuantity("quiero 3 brownies"), 3);
    assert.equal(parseQuantity("un latte"), 1);
    assert.equal(parseQuantity("quiero un café"), 1);
    assert.equal(parseQuantity("hola"), null);
});

test("tamaño y temperatura desde el texto", () => {
    assert.deepEqual(parseSlots("el grande y frío"), { size: "Grande", type: "Frío" });
    assert.deepEqual(parseSlots("mediano caliente"), { size: "Mediano", type: "Caliente" });
    assert.deepEqual(parseSlots("hola"), {});
});

test("detecta intenciones principales", () => {
    assert.equal(detectIntent("agrégame dos capuchinos"), "ADD");
    assert.equal(detectIntent("quiero algo frío"), "RECOMMEND");
    assert.equal(detectIntent("recomiéndame un latte dulce"), "RECOMMEND");
    assert.equal(detectIntent("¿qué ingredientes tiene este café?"), "DETAILS");
    assert.equal(detectIntent("vacía mi carrito"), "CLEAR_CART");
    assert.equal(detectIntent("quiero pagar"), "CHECKOUT");
    assert.equal(detectIntent("hay promociones?"), "PROMOTIONS");
    assert.equal(detectIntent("compara el latte con el capuchino"), "COMPARE");
    assert.equal(detectIntent("cuéntame un chiste"), "OTHER");
});

test("findProducts: plural, errata y ambigüedad", () => {
    assert.equal(findProducts("dos capuchinos", catalog).kind, "exact");
    assert.equal(findProducts("un capuccino", catalog).products[0]._id, "a3");
    const amb = findProducts("un latte", catalog);
    assert.equal(amb.kind, "ambiguous");
    assert.equal(amb.products.length, 2);
    assert.equal(findProducts("latte caramelo", catalog).products[0]._id, "a2");
    assert.equal(findProducts("pizza hawaiana", catalog).kind, "none");
});

test("latte sin especificar: muestra lista de lattes", () => {
    const r = planTurn({ ...base, text: "quiero un latte", state: null });
    assert.equal(r.handled, true);
    assert.deepEqual(r.productIds.sort(), ["a1", "a2"]);
    assert.equal(r.state.awaiting, "product");
    assert.equal(r.proposal, undefined);
});

test("flujo completo: latte -> elegir -> tamaño -> temperatura -> propuesta", () => {
    let r = planTurn({ ...base, text: "quiero un latte", state: null });
    // elige desde la tarjeta
    r = planTurn({ ...base, text: "Elegir Latte Caramelo", state: r.state, selectProductId: "a2" });
    assert.equal(r.state.awaiting, "size");
    assert.equal(r.quickReplies.length, 3);
    r = planTurn({ ...base, text: "grande", state: r.state });
    assert.equal(r.state.awaiting, "type");
    r = planTurn({ ...base, text: "frío", state: r.state });
    assert.equal(r.proposal.type, "ADD_TO_CART");
    const item = r.proposal.items[0];
    assert.equal(item.productId, "a2");
    assert.equal(item.quantity, 1);
    assert.equal(item.customization.size, "Grande");
    assert.equal(item.customization.type, "Frío");
    // Grande = base + 5.000
    assert.equal(item.unitPrice, 18000);
    assert.equal(r.proposal.total, 18000);
});

test("la cantidad se conserva durante el flujo", () => {
    let r = planTurn({ ...base, text: "agrégame dos capuchinos", state: null });
    assert.equal(r.state.quantity, 2);
    r = planTurn({ ...base, text: "mediano", state: r.state });
    r = planTurn({ ...base, text: "caliente", state: r.state });
    assert.equal(r.proposal.items[0].quantity, 2);
    assert.equal(r.proposal.total, 18000);
});

test("postres no piden tamaño ni temperatura", () => {
    const r = planTurn({ ...base, text: "agrégame un brownie", state: null });
    assert.equal(r.proposal.items[0].productId, "a5");
    assert.deepEqual(r.proposal.items[0].options, []);
    assert.equal(r.proposal.total, 7000);
});

test("el precio de la propuesta aplica la promoción vigente", () => {
    const resolver = (id, price) => id === "a5"
        ? { discountPerUnit: 1000, promotion: { name: "Dulce martes" } }
        : null;
    const r = planTurn({ ...base, resolver, text: "agrégame dos brownies", state: null });
    assert.equal(r.proposal.items[0].unitPrice, 6000);
    assert.equal(r.proposal.total, 12000);
});

test("cantidades abusivas se rechazan antes de proponer", () => {
    const r = planTurn({ ...base, text: "agrégame 50 brownies", state: null });
    assert.equal(r.proposal, undefined);
    assert.match(r.reply, new RegExp(String(MAX_QUANTITY_PER_LINE)));
});

test("sin sesión no propone agregar y pide iniciar sesión", () => {
    const r = planTurn({ ...base, isLoggedIn: false, text: "agrégame un brownie", state: null });
    assert.equal(r.needsLogin, true);
    assert.equal(r.proposal, undefined);
});

test("producto inexistente: no inventa y ofrece categorías", () => {
    const r = planTurn({ ...base, text: "agrégame una pizza", state: null });
    assert.equal(r.proposal, undefined);
    assert.equal(r.productIds.length, 0);
    assert.ok(r.quickReplies.length > 0);
});

test("producto no disponible: avisa y propone alternativas", () => {
    const r = planTurn({ ...base, text: "quiero un cheesecake", state: null });
    assert.match(r.reply, /no está disponible/);
    assert.deepEqual(r.productIds, ["a5"]);
});

test("detalles: usa solo datos reales del catálogo", () => {
    const r = planTurn({ ...base, text: "qué ingredientes tiene el capuchino", state: null });
    assert.match(r.reply, /Espresso, Leche, Espuma/);
    assert.match(r.reply, /\$9\.000/);
    const none = planTurn({ ...base, text: "qué ingredientes tiene el americano", state: null });
    assert.match(none.reply, /No tengo los ingredientes registrados/);
});

test("detalles con 'este café' usa el producto de la conversación", () => {
    const state = normalizeState({ productId: "a3" });
    const r = planTurn({ ...base, text: "¿qué ingredientes tiene este café?", state });
    assert.deepEqual(r.productIds, ["a3"]);
});

test("recomendación fría y dulce sin inventar", () => {
    const cold = planTurn({ ...base, text: "quiero algo frío", state: null });
    assert.deepEqual(cold.productIds, ["a4"]);
    const sweet = planTurn({ ...base, text: "recomiéndame un latte dulce", state: null });
    assert.ok(sweet.productIds.every(id => ["a1", "a2"].includes(id)));
});

test("comparar dos bebidas", () => {
    const r = planTurn({ ...base, text: "compara el capuchino con el americano", state: null });
    assert.deepEqual(r.productIds.sort(), ["a3", "a6"]);
    assert.match(r.reply, /más económico/);
});

test("confirmar y cancelar solo con propuesta pendiente", () => {
    const yes = planTurn({ ...base, text: "sí", state: null, hasPending: true });
    assert.equal(yes.execute, "confirm");
    const no = planTurn({ ...base, text: "no, cancela", state: null, hasPending: true });
    assert.equal(no.execute, "cancel");
    // sin propuesta, un "sí" no ejecuta nada
    const none = planTurn({ ...base, text: "sí", state: null, hasPending: false });
    assert.equal(none.execute, undefined);
});

test("vaciar el carrito exige confirmación", () => {
    const r = planTurn({ ...base, text: "vacía mi carrito", state: null });
    assert.equal(r.proposal.type, "CLEAR_CART");
    assert.equal(r.execute, undefined);
});

test("el chat nunca paga ni cierra el pedido", () => {
    const r = planTurn({ ...base, text: "quiero pagar mi pedido", state: null });
    assert.deepEqual(r.actions, [{ type: "open_cart" }]);
    assert.equal(r.proposal, undefined);
});

test("temas ajenos pasan al modelo de IA", () => {
    const r = planTurn({ ...base, text: "cuéntame un chiste", state: null });
    assert.equal(r.handled, false);
});

test("tarjeta de un producto retirado no se puede elegir", () => {
    const r = planTurn({ ...base, text: "Elegir", state: null, selectProductId: "zzz" });
    assert.equal(r.proposal, undefined);
    assert.match(r.reply, /ya no está disponible/);
});
