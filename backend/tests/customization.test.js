import test from "node:test";
import assert from "node:assert/strict";

import {
    normalizeCustomization,
    resolveCustomization,
    customizationPrice,
    customizationKey,
    supportsLatteArt,
    getCustomizationOptions,
    DEFAULT_CUSTOMIZATION
} from "../utils/customization.js";

const latte = { name: "Latte", categoryId: { name: "Cafés calientes" } };
const tea = { name: "Té chai", categoryId: { name: "Bebidas calientes" } };
const cake = { name: "Torta", categoryId: { name: "Postres" } };

test("sin datos usa los valores por defecto y no cobra extra", () => {
    const { customization, error } = normalizeCustomization(undefined);
    assert.equal(error, undefined);
    assert.equal(customization.size, "Mediano");
    assert.deepEqual(customization.syrups, []);
    assert.equal(customization.latteArt, "");
    assert.equal(customizationPrice(customization), 0);
});

test("el precio suma tamaño, leche, shots y toppings", () => {
    const { customization } = normalizeCustomization({
        size: "Grande", milk: "Avena", extraShots: 2,
        toppings: ["Canela", "Caramelo"]
    });
    assert.equal(customizationPrice(customization), 5000 + 1000 + 6000 + 1000 + 1500);
});

test("rechaza jarabes y endulzantes que no existen en el catálogo", () => {
    assert.ok(normalizeCustomization({ syrups: ["Vainilla"] }).error);
    assert.ok(normalizeCustomization({ sweeteners: ["Stevia"] }).error);
    assert.ok(normalizeCustomization({ syrups: "Vainilla" }).error);
});

test("rechaza opciones inválidas existentes", () => {
    assert.ok(normalizeCustomization({ size: "Gigante" }).error);
    assert.ok(normalizeCustomization({ milk: "Coco" }).error);
    assert.ok(normalizeCustomization({ extraShots: 99 }).error);
    assert.ok(normalizeCustomization({ toppings: ["Fresas"] }).error);
});

test("la clave no cambia para líneas sin los campos nuevos", () => {
    assert.equal(
        customizationKey(DEFAULT_CUSTOMIZATION),
        "Mediano|Caliente|Entera|0|"
    );
    assert.equal(
        customizationKey({ size: "Grande", type: "Frío", milk: "Soya", extraShots: 1, toppings: ["Canela"] }),
        "Grande|Frío|Soya|1|Canela"
    );
});

test("latte art acepta solo los tres diseños y cambia la clave", () => {
    for (const design of ["Corazón", "Hoja", "Cisne"]) {
        const { customization, error } = normalizeCustomization({ latteArt: design });
        assert.equal(error, undefined);
        assert.equal(customization.latteArt, design);
        assert.ok(customizationKey(customization).endsWith(`|a:${design}`));
        assert.equal(customizationPrice(customization), 0);
    }
    assert.equal(normalizeCustomization({}).customization.latteArt, "");
    assert.ok(normalizeCustomization({ latteArt: "Mariposa" }).error);
    assert.ok(normalizeCustomization({ latteArt: [[1, 2, 3, 4]] }).error);
});

test("latte art solo en bebidas con espuma y calientes", () => {
    assert.equal(supportsLatteArt(latte), true);
    assert.equal(supportsLatteArt(tea), false);
    assert.equal(resolveCustomization(latte, { latteArt: "Hoja" }).error, undefined);
    assert.ok(resolveCustomization(tea, { latteArt: "Hoja" }).error);
    assert.ok(resolveCustomization(latte, { type: "Frío", latteArt: "Hoja" }).error);
});

test("los postres ignoran cualquier personalización", () => {
    const { customization } = resolveCustomization(cake, {
        size: "Grande", latteArt: "Cisne"
    });
    assert.equal(customization.size, "Mediano");
    assert.equal(customization.latteArt, "");
});

test("el endpoint de opciones expone los mismos valores que valida", () => {
    const o = getCustomizationOptions();
    assert.deepEqual(Object.keys(o.sizes), ["Pequeño", "Mediano", "Grande"]);
    assert.deepEqual(Object.keys(o.sizeOunces), Object.keys(o.sizes));
    assert.equal(o.extraShot.max, 6);
    assert.deepEqual(o.syrups.prices, {});
    assert.deepEqual(o.latteArt.designs, ["Corazón", "Hoja", "Cisne"]);
});

test("la leche deslactosada está disponible y se cobra", () => {
    const { customization, error } = normalizeCustomization({ milk: "Deslactosada" });
    assert.equal(error, undefined);
    assert.equal(customization.milk, "Deslactosada");
    assert.equal(customizationPrice(customization), 1000);
    assert.ok("Deslactosada" in getCustomizationOptions().milks);
});
