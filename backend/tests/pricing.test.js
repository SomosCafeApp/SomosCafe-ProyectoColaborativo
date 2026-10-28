import test from "node:test";
import assert from "node:assert/strict";

import {
    SIZE_PRICES,
    EXTRA_SHOT_PRICE,
    MAX_EXTRA_SHOTS,
    TOPPING_PRICES,
    MAX_TOPPING_QUANTITY,
    getCustomizationOptions,
    normalizeCustomization
} from "../utils/customization.js";

import {
    MIN_PRICE_AFTER_SIZE,
    sizeAdjustment,
    customizationBreakdown,
    customizationPriceFor,
    clampDiscount
} from "../utils/pricing.js";

const norm = (raw) => {
    const { customization, error } = normalizeCustomization(raw);
    assert.equal(error, undefined, error);
    return customization;
};

// Mismos casos que frontend/test/drink_studio_test.dart (sizeAdjustment):
// la app y el servidor deben coincidir al centavo.
test("piso del tamaño Pequeño: mismos valores que la app", () => {
    assert.equal(sizeAdjustment("Pequeño", 3500), -2500);
    assert.equal(sizeAdjustment("Pequeño", 1000), 0);
    assert.equal(sizeAdjustment("Pequeño", 500), 0);
    assert.equal(sizeAdjustment("Pequeño", 8000), -3000);
    assert.equal(sizeAdjustment("Grande", 500), 5000);
    assert.equal(sizeAdjustment("Mediano", 500), 0);
    assert.equal(sizeAdjustment("Pequeño", 10000), -3000);
});

test("las opciones publican el piso para que la app lo use", () => {
    assert.equal(getCustomizationOptions().sizeRules.minPriceAfterSize, MIN_PRICE_AFTER_SIZE);
    assert.equal(MIN_PRICE_AFTER_SIZE, 1000);
});

test("el Pequeño nunca deja un producto por debajo del piso (ni en negativo)", () => {
    for (const base of [1000, 1500, 2000, 2500, 3000, 3500, 4000, 8000]) {
        const unit = base + customizationPriceFor(norm({ size: "Pequeño" }), base);
        assert.ok(unit >= MIN_PRICE_AFTER_SIZE, `base ${base} -> ${unit}`);
        assert.ok(unit <= base, `base ${base} -> ${unit}`);
    }
    // Un producto más barato que el piso no se encarece al hacerlo Pequeño.
    assert.equal(500 + customizationPriceFor(norm({ size: "Pequeño" }), 500), 500);
});

test("tres tamaños: Pequeño <= Mediano < Grande para cualquier precio base", () => {
    for (const base of [500, 1000, 2500, 3500, 6000, 9500, 15000]) {
        const price = (size, extra = {}) =>
            base + customizationPriceFor(norm({ size, ...extra }), base);
        for (const extra of [{}, { milk: "Soya", extraShots: 2 }, { toppings: { Canela: 3 } }]) {
            assert.ok(price("Pequeño", extra) <= price("Mediano", extra));
            assert.ok(price("Mediano", extra) < price("Grande", extra));
            assert.equal(price("Grande", extra) - price("Mediano", extra), SIZE_PRICES["Grande"]);
        }
    }
});

test("shots extra: de 0 a 6 cobran $3.000 c/u y más de 6 se rechaza", () => {
    for (let shots = 0; shots <= MAX_EXTRA_SHOTS; shots++) {
        const c = norm({ extraShots: shots });
        assert.equal(customizationPriceFor(c, 9000), shots * EXTRA_SHOT_PRICE);
    }
    assert.ok(normalizeCustomization({ extraShots: MAX_EXTRA_SHOTS + 1 }).error);
    assert.ok(normalizeCustomization({ extraShots: -1 }).error);
    assert.ok(normalizeCustomization({ extraShots: 1.5 }).error);
});

test("toppings: primera porción al precio de lista, +$300 por cada extra", () => {
    for (const [name, price] of Object.entries(TOPPING_PRICES)) {
        for (let q = 1; q <= MAX_TOPPING_QUANTITY; q++) {
            const c = norm({ toppings: { [name]: q } });
            assert.equal(customizationPriceFor(c, 9000), price + (q - 1) * 300, `${name} x${q}`);
        }
    }
});

test("total final: base + tamaño + leche + shots + toppings en varios productos", () => {
    const cases = [
        // base, opciones, total esperado por unidad
        [9500, { size: "Grande", milk: "Avena", extraShots: 2, toppings: { "Crema batida": 1, Canela: 2 } },
            9500 + 5000 + 1000 + 6000 + 2000 + (1000 + 300)],
        [9500, { size: "Pequeño", milk: "Soya", extraShots: 1 }, 9500 - 3000 + 2000 + 3000],
        [3500, { size: "Pequeño", toppings: { Caramelo: 1 } }, 1000 + 1500],
        [2000, { size: "Pequeño", extraShots: 1 }, 1000 + 3000],
        [12000, {}, 12000],
        [800, { size: "Grande" }, 800 + 5000]
    ];
    for (const [base, raw, expected] of cases) {
        const c = norm(raw);
        assert.equal(base + customizationPriceFor(c, base), expected, JSON.stringify(raw));
    }
});

test("desglose: etiquetas y suma iguales a las de la app", () => {
    const c = norm({
        size: "Grande", milk: "Avena", extraShots: 2,
        toppings: { Canela: 3, "Crema batida": 1 }, sweeteners: ["Miel"]
    });
    const b = customizationBreakdown(c, 9500);
    assert.equal(b.sizeAdjustment, 5000);
    assert.deepEqual(b.lines.map(l => l.label), [
        "Leche Avena", "Shots extra × 2", "Canela × 3", "Crema batida"
    ]);
    assert.equal(b.lines.find(l => l.label === "Canela × 3").detail, "2 extra × $300");
    assert.equal(b.extrasTotal, b.lines.reduce((s, l) => s + l.amount, 0));
    assert.equal(b.customizationPrice, b.sizeAdjustment + b.extrasTotal);
    // La leche entera y los endulzantes gratis no generan línea.
    assert.equal(customizationBreakdown(norm({}), 9500).lines.length, 0);
});

test("la promoción nunca deja la unidad por debajo de $0", () => {
    assert.equal(clampDiscount(1750, 1000), 1000);
    assert.equal(clampDiscount(500, 1000), 500);
    assert.equal(clampDiscount(0, 1000), 0);
    assert.equal(clampDiscount(-5, 1000), 0);
    assert.equal(clampDiscount(900, -200), 0);
    assert.equal(clampDiscount(undefined, 1000), 0);
});

test("pedido: base 3.500 con 50% de promo en Pequeño no queda en negativo", () => {
    const base = 3500;
    const extra = customizationPriceFor(norm({ size: "Pequeño" }), base);
    const original = base + extra; // 1.000
    const discount = clampDiscount(base * 0.5, original);
    assert.equal(original - discount, 0);
    assert.ok(original - discount >= 0);
});
