import test from "node:test";
import assert from "node:assert/strict";

import {
    TOPPING_PRICES,
    LATTE_ART_DESIGNS,
    isCustomizableProduct,
    isToppingCompatible,
    resolveCustomization,
    supportsLatteArt,
    DEFAULT_CUSTOMIZATION
} from "../utils/customization.js";

// Menú representativo (las categorías reales están en la base de datos,
// varias en inglés). Se prueba el comportamiento por nombre + categoría.
const p = (name, category) => ({
    name,
    categoryId: category === undefined ? undefined : { name: category }
});

const MENU = {
    latte: p("Latte de vainilla", "Hot Drinks"),
    capuchino: p("Capuchino", "Hot Drinks"),
    moca: p("Mocaccino", "Hot Drinks"),
    macchiato: p("Macchiato", "Hot Drinks"),
    cafeConLeche: p("Café con leche", "Hot Drinks"),
    chocolate: p("Chocolate caliente", "Hot Drinks"),
    americano: p("Americano", "Hot Drinks"),
    espresso: p("Espresso", "Hot Drinks"),
    te: p("Té verde", "Tea"),
    frappe: p("Frappé de caramelo", "Cold Drinks"),
    malteada: p("Malteada de vainilla", "Cold Drinks"),
    limonada: p("Limonada de coco", "Cold Drinks"),
    sinCategoria: p("Café de la casa", undefined)
};

const DESSERTS = [
    p("Cheesecake de fresa", "Desserts"),
    p("Torta de chocolate", "Postres"),
    p("Brownie", "Pastelería de pastel"),
    p("Tarta", "Desserts")
];

const ORIGINALS = ["Crema batida", "Canela", "Chispas", "Caramelo"];
const NEW_TOPPINGS = ["Cacao en polvo", "Virutas de chocolate", "Malvaviscos"];

const ok = (product, raw) => {
    const r = resolveCustomization(product, raw);
    return !r.error;
};

test("los 4 toppings originales van con cualquier bebida, caliente o fría", () => {
    for (const product of Object.values(MENU)) {
        for (const type of ["Caliente", "Frío"]) {
            for (const t of ORIGINALS) {
                assert.ok(ok(product, { type, toppings: { [t]: 1 } }), `${product.name} ${type} ${t}`);
            }
        }
    }
});

test("latte art: solo bebidas calientes con espuma de leche", () => {
    const withArt = ["latte", "capuchino", "moca", "macchiato", "cafeConLeche"];
    const without = ["chocolate", "americano", "espresso", "te", "frappe", "malteada", "limonada"];

    for (const key of withArt) {
        assert.equal(supportsLatteArt(MENU[key]), true, key);
        for (const design of LATTE_ART_DESIGNS) {
            assert.ok(ok(MENU[key], { type: "Caliente", latteArt: design }), `${key} ${design}`);
            // Nunca en frío.
            assert.ok(!ok(MENU[key], { type: "Frío", latteArt: design }), `${key} frío ${design}`);
        }
    }
    for (const key of without) {
        assert.ok(!ok(MENU[key], { type: "Caliente", latteArt: "Corazón" }), key);
    }
});

test("latte art: un diseño desconocido se rechaza incluso en un latte", () => {
    assert.ok(!ok(MENU.latte, { type: "Caliente", latteArt: "Dragón" }));
});

test("cacao y virutas: bebidas con leche o chocolate, no en americano, espresso, té ni limonada", () => {
    const yes = ["latte", "capuchino", "moca", "macchiato", "cafeConLeche", "chocolate", "frappe", "malteada"];
    const no = ["americano", "espresso", "te", "limonada"];
    for (const t of ["Cacao en polvo", "Virutas de chocolate"]) {
        for (const key of yes) assert.ok(ok(MENU[key], { toppings: { [t]: 1 } }), `${key} ${t}`);
        for (const key of no) assert.ok(!ok(MENU[key], { toppings: { [t]: 1 } }), `${key} ${t}`);
    }
});

test("malvaviscos: solo calientes de chocolate o latte", () => {
    const yes = ["latte", "moca", "chocolate"];
    const no = ["capuchino", "americano", "espresso", "te", "frappe", "malteada", "limonada"];
    for (const key of yes) {
        assert.ok(ok(MENU[key], { type: "Caliente", toppings: { Malvaviscos: 1 } }), key);
        assert.ok(!ok(MENU[key], { type: "Frío", toppings: { Malvaviscos: 1 } }), `${key} frío`);
    }
    for (const key of no) {
        assert.ok(!ok(MENU[key], { type: "Caliente", toppings: { Malvaviscos: 1 } }), key);
    }
});

test("una combinación con un topping incompatible se rechaza completa", () => {
    const r = resolveCustomization(MENU.americano, {
        toppings: { Canela: 1, Malvaviscos: 1 }
    });
    assert.match(r.error, /Malvaviscos no va con esta bebida/);
});

test("todo topping del catálogo tiene una regla coherente (o ninguna)", () => {
    for (const name of Object.keys(TOPPING_PRICES)) {
        // Sin producto conocido no se bloquea nada.
        assert.equal(isToppingCompatible(name, null, "Caliente"), true, name);
        if (ORIGINALS.includes(name)) {
            assert.equal(isToppingCompatible(name, MENU.americano, "Frío"), true, name);
        } else {
            assert.ok(NEW_TOPPINGS.includes(name), `topping sin clasificar: ${name}`);
        }
    }
});

test("postres: ignoran cualquier personalización, incluso inválida", () => {
    for (const dessert of DESSERTS) {
        assert.equal(isCustomizableProduct(dessert), false, dessert.name);
        const r = resolveCustomization(dessert, {
            size: "Gigante", milk: "Marciana", extraShots: 99,
            toppings: { Canela: 9 }, latteArt: "Dragón"
        });
        assert.equal(r.error, undefined);
        assert.deepEqual(r.customization, {
            ...DEFAULT_CUSTOMIZATION,
            toppings: [], toppingQuantities: {}, syrups: [], sweeteners: [], latteArt: ""
        });
    }
});

test("producto sin categoría sigue siendo personalizable", () => {
    assert.equal(isCustomizableProduct(MENU.sinCategoria), true);
    assert.ok(ok(MENU.sinCategoria, { size: "Grande", toppings: { Canela: 2 } }));
});

test("sin personalización cualquier producto personalizable queda por defecto", () => {
    for (const product of Object.values(MENU)) {
        const r = resolveCustomization(product, undefined);
        assert.equal(r.error, undefined);
        assert.equal(r.customization.size, "Mediano");
        assert.equal(r.customization.latteArt, "");
        assert.deepEqual(r.customization.toppings, []);
    }
});

test("el mismo pedido dos veces produce la misma línea de carrito (idempotente)", async () => {
    const { customizationKey } = await import("../utils/customization.js");
    const a = resolveCustomization(MENU.latte, { toppings: { Canela: 2, "Crema batida": 1 }, latteArt: "Hoja" });
    const b = resolveCustomization(MENU.latte, { toppings: { "Crema batida": 1, Canela: 2 }, latteArt: "Hoja" });
    assert.equal(customizationKey(a.customization), customizationKey(b.customization));
});
