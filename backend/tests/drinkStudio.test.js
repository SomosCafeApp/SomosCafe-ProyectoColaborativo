import test from "node:test";
import assert from "node:assert/strict";

import {
    pickLatteProduct,
    buildStudioQuote,
    priceMatches,
    studioProductView,
    clampMilkLevel,
    MAX_STUDIO_QUANTITY
} from "../utils/drinkStudio.js";

import { customizationPrice } from "../utils/customization.js";

const cat = (name) => ({ name });

const latte = {
    _id: "p-latte",
    name: "Latte",
    price: 8000,
    isAvailable: true,
    categoryId: cat("Cafés calientes")
};
const vanilla = { ...latte, _id: "p-vanilla", name: "Latte vainilla", price: 9000 };
const mocha = { ...latte, _id: "p-mocha", name: "Moca", price: 9500 };
const tea = { ...latte, _id: "p-tea", name: "Té chai", price: 6000 };
const cake = { ...latte, _id: "p-cake", name: "Latte cake", categoryId: cat("Postres") };
const hidden = { ...latte, _id: "p-hidden", isAvailable: false };

const studio = (customization, extra = {}, product = latte, discountOf = null) =>
    buildStudioQuote({ product, raw: { customization, ...extra }, discountOf });

// ───────────── Producto ─────────────

test("elige el latte exacto entre varios candidatos", () => {
    assert.equal(pickLatteProduct([vanilla, latte, mocha])._id, "p-latte");
});

test("sin 'Latte' exacto usa el que empieza por Latte", () => {
    assert.equal(pickLatteProduct([mocha, vanilla])._id, "p-vanilla");
});

test("ignora productos ocultos, postres y bebidas sin latte", () => {
    assert.equal(pickLatteProduct([hidden, cake, tea, mocha]), null);
    assert.equal(pickLatteProduct([]), null);
});

test("la vista pública incluye el descuento vigente", () => {
    const view = studioProductView(latte, () => ({
        discountPerUnit: 800,
        promotion: { name: "Martes de latte" }
    }));
    assert.equal(view.effectivePrice, 7200);
    assert.equal(view.promotionName, "Martes de latte");
    assert.equal(view.id, "p-latte");
});

// ───────────── Cotización ─────────────

test("latte por defecto: precio base sin extras", () => {
    const q = studio({});
    assert.equal(q.ok, true);
    assert.equal(q.unitPrice, 8000);
    assert.equal(q.lineTotal, 8000);
    assert.equal(q.customization.latteArt, "");
});

test("el precio suma tamaño, leche, shots, toppings y el arte NO cuesta", () => {
    const q = studio({
        size: "Grande",
        milk: "Avena",
        extraShots: 1,
        toppings: ["Canela", "Crema batida"],
        latteArt: "Corazón"
    }, { quantity: 2 });
    assert.equal(q.ok, true);
    // 5000 grande + 1000 avena + 3000 shot + 1000 canela + 2000 crema
    assert.equal(q.customizationPrice, 12000);
    assert.equal(q.unitPrice, 20000);
    assert.equal(q.lineTotal, 40000);
    assert.equal(q.unitPrice, 8000 + customizationPrice(q.customization));
});

test("las porciones extra de un topping se cobran por porción", () => {
    const q = studio({ toppings: { Canela: 3 } });
    assert.equal(q.ok, true);
    assert.equal(q.customization.toppingQuantities.Canela, 3);
    assert.equal(q.customizationPrice, 1000 + 2 * 300);
});

test("el precio que manda la interfaz se ignora: solo cuenta lo que se elige", () => {
    const q = studio({ size: "Mediano", unitPrice: 1, price: 1, extraPrice: -5000 });
    assert.equal(q.unitPrice, 8000);
});

test("la promoción descuenta el precio base, nunca el extra", () => {
    const q = studio(
        { size: "Grande" },
        {},
        latte,
        () => ({ discountPerUnit: 1000, promotion: { name: "Promo" } })
    );
    assert.equal(q.originalUnitPrice, 13000);
    assert.equal(q.discountPerUnit, 1000);
    assert.equal(q.unitPrice, 12000);
    assert.equal(q.promotionName, "Promo");
});

test("el tamaño pequeño respeta el piso de precio", () => {
    const cheap = { ...latte, price: 3500 };
    const q = studio({ size: "Pequeño" }, {}, cheap);
    assert.equal(q.sizeAdjustment, -2500);
    assert.equal(q.unitPrice, 1000);
});

// ───────────── Compatibilidad ─────────────

test("rechaza latte art en bebida fría", () => {
    const q = studio({ type: "Frío", latteArt: "Corazón" });
    assert.equal(q.ok, false);
    assert.equal(q.status, 400);
    assert.equal(q.code, "INVALID_CONFIGURATION");
});

test("rechaza latte art en una bebida sin espuma de leche", () => {
    const q = studio({ latteArt: "Corazón" }, {}, { ...latte, name: "Latte" , categoryId: cat("Cafés") });
    assert.equal(q.ok, true);
    const noFoam = studio({ latteArt: "Corazón" }, {}, { ...tea });
    assert.equal(noFoam.ok, false);
});

test("rechaza malvaviscos en frío y toppings o leches inexistentes", () => {
    assert.equal(studio({ type: "Frío", toppings: ["Malvaviscos"] }).ok, false);
    assert.equal(studio({ toppings: ["Fresas"] }).ok, false);
    assert.equal(studio({ milk: "Coco" }).ok, false);
    assert.equal(studio({ size: "Gigante" }).ok, false);
    assert.equal(studio({ extraShots: 99 }).ok, false);
    assert.equal(studio({ toppings: { Canela: 9 } }).ok, false);
});

test("acepta el mismo latte en frío con toppings válidos", () => {
    const q = studio({ type: "Frío", toppings: ["Caramelo", "Crema batida"], milk: "Almendra" });
    assert.equal(q.ok, true);
    assert.equal(q.customization.type, "Frío");
    assert.equal(q.customizationPrice, 1000 + 1500 + 2000);
});

// ───────────── Producto no disponible / cantidades ─────────────

test("producto inexistente, oculto o no personalizable", () => {
    assert.equal(studio({}, {}, null).status, 404);
    const gone = studio({}, {}, hidden);
    assert.equal(gone.status, 409);
    assert.equal(gone.code, "PRODUCT_UNAVAILABLE");
    assert.equal(studio({}, {}, { ...latte, categoryId: cat("Postres") }).ok, false);
});

test("la cantidad debe ser un entero razonable", () => {
    assert.equal(studio({}, { quantity: 0 }).code, "INVALID_QUANTITY");
    assert.equal(studio({}, { quantity: 1.5 }).code, "INVALID_QUANTITY");
    assert.equal(studio({}, { quantity: MAX_STUDIO_QUANTITY + 1 }).code, "INVALID_QUANTITY");
    assert.equal(studio({}, { quantity: MAX_STUDIO_QUANTITY }).ok, true);
});

test("el nivel de leche es solo visual y siempre queda entre 0 y 1", () => {
    assert.equal(clampMilkLevel(2), 1);
    assert.equal(clampMilkLevel(-1), 0);
    assert.equal(clampMilkLevel("x"), 0.55);
    assert.equal(studio({}, { milkLevel: 0.3 }).unitPrice, studio({}, { milkLevel: 0.9 }).unitPrice);
});

test("priceMatches tolera medio peso y exige coincidencia", () => {
    assert.equal(priceMatches(undefined, 8000), true);
    assert.equal(priceMatches(8000, 8000), true);
    assert.equal(priceMatches(8000.4, 8000), true);
    assert.equal(priceMatches(7999, 8000), false);
    assert.equal(priceMatches("abc", 8000), false);
});
