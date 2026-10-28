import test from "node:test";
import assert from "node:assert/strict";

import {
    normalizeCustomization,
    resolveCustomization,
    customizationPrice,
    customizationKey,
    supportsLatteArt,
    getCustomizationOptions,
    DEFAULT_CUSTOMIZATION,
    SIZE_PRICES,
    TOPPING_EXTRA_PORTION_PRICE,
    MAX_TOPPING_QUANTITY,
    TOPPING_PRICES,
    SWEETENER_PRICES,
    isToppingCompatible
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

test("latte art acepta solo los diseños conocidos y cambia la clave", () => {
    for (const design of ["Corazón", "Hoja", "Cisne", "Tulipán", "Rosetta", "Estrella"]) {
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
    assert.deepEqual(o.latteArt.designs, ["Corazón", "Hoja", "Cisne", "Tulipán", "Rosetta", "Estrella"]);
});

test("la leche deslactosada está disponible y se cobra", () => {
    const { customization, error } = normalizeCustomization({ milk: "Deslactosada" });
    assert.equal(error, undefined);
    assert.equal(customization.milk, "Deslactosada");
    assert.equal(customizationPrice(customization), 1000);
    assert.ok("Deslactosada" in getCustomizationOptions().milks);
});

test("regla de tamaños: pequeño -3000, mediano 0, grande +5000", () => {
    assert.deepEqual(SIZE_PRICES, { "Pequeño": -3000, "Mediano": 0, "Grande": 5000 });
    const price = (size) =>
        customizationPrice(normalizeCustomization({ size }).customization);
    const base = 10000;
    assert.equal(base + price("Pequeño"), 7000);
    assert.equal(base + price("Mediano"), 10000);
    assert.equal(base + price("Grande"), 15000);
});

test("el pequeño nunca es más caro que el mediano ni el grande más barato", () => {
    const price = (size, extra = {}) =>
        customizationPrice(normalizeCustomization({ size, ...extra }).customization);
    for (const extra of [{}, { milk: "Soya", extraShots: 2 }, { toppings: { Canela: 3 } }]) {
        assert.ok(price("Pequeño", extra) < price("Mediano", extra));
        assert.ok(price("Mediano", extra) < price("Grande", extra));
    }
});

test("el tamaño no se suma dos veces ni cambia con otras opciones", () => {
    const small = normalizeCustomization({ size: "Pequeño", milk: "Avena" }).customization;
    assert.equal(customizationPrice(small), -3000 + 1000);
});

test("toppings: lista antigua = una porción cada uno", () => {
    const { customization } = normalizeCustomization({ toppings: ["Canela", "Caramelo"] });
    assert.deepEqual(customization.toppingQuantities, { Canela: 1, Caramelo: 1 });
    assert.equal(customizationPrice(customization), 1000 + 1500);
});

test("toppings: cada porción extra suma $300", () => {
    const { customization, error } = normalizeCustomization({
        toppings: { Canela: 3, Chispas: 1 }
    });
    assert.equal(error, undefined);
    assert.equal(TOPPING_EXTRA_PORTION_PRICE, 300);
    assert.equal(customizationPrice(customization), (1000 + 2 * 300) + 2500);
});

test("toppings: cantidad 0 lo retira y no se cobra", () => {
    const { customization } = normalizeCustomization({ toppings: { Canela: 0, Chispas: 2 } });
    assert.deepEqual(customization.toppings, ["Chispas"]);
    assert.equal(customizationPrice(customization), 2500 + 300);
});

test("toppings: valida cantidades y nombres", () => {
    assert.ok(normalizeCustomization({ toppings: { Canela: MAX_TOPPING_QUANTITY + 1 } }).error);
    assert.ok(normalizeCustomization({ toppings: { Canela: -1 } }).error);
    assert.ok(normalizeCustomization({ toppings: { Canela: 1.5 } }).error);
    assert.ok(normalizeCustomization({ toppings: { Fresas: 1 } }).error);
    assert.ok(normalizeCustomization({ toppings: "Canela" }).error);
});

test("toppings: el formato guardado (lista + toppingQuantities) conserva las porciones", () => {
    const stored = { toppings: ["Canela"], toppingQuantities: { Canela: 2 } };
    const { customization } = normalizeCustomization(stored);
    assert.equal(customizationPrice(customization), 1000 + 300);
    const again = normalizeCustomization(customization).customization;
    assert.equal(customizationKey(again), customizationKey(customization));
});

test("la clave distingue cantidades de toppings", () => {
    const k1 = customizationKey(normalizeCustomization({ toppings: { Canela: 1 } }).customization);
    const k2 = customizationKey(normalizeCustomization({ toppings: { Canela: 2 } }).customization);
    assert.notEqual(k1, k2);
    assert.equal(k1, "Mediano|Caliente|Entera|0|Canela");
});

test("las opciones exponen las reglas de toppings", () => {
    const o = getCustomizationOptions();
    assert.equal(o.toppingRules.extraPortionPrice, 300);
    assert.equal(o.toppingRules.maxQuantity, MAX_TOPPING_QUANTITY);
    assert.equal(o.sizes["Pequeño"], -3000);
});

const mocha = { name: "Moca", categoryId: { name: "Cafés calientes" } };
const chocolate = { name: "Chocolate caliente", categoryId: { name: "Bebidas calientes" } };
const lemonade = { name: "Limonada de coco", categoryId: { name: "Bebidas frías" } };

test("nuevos toppings: cacao, virutas de chocolate y malvaviscos", () => {
    for (const name of ["Cacao en polvo", "Virutas de chocolate", "Malvaviscos"]) {
        assert.ok(name in TOPPING_PRICES, name);
    }
    const { customization, error } = normalizeCustomization({
        toppings: { "Cacao en polvo": 2, "Malvaviscos": 3 }
    });
    assert.equal(error, undefined);
    assert.equal(
        customizationPrice(customization),
        (1000 + 300) + (1800 + 2 * 300)
    );
});

test("cada porción extra de cualquier topping suma exactamente $300", () => {
    for (const name of Object.keys(TOPPING_PRICES)) {
        const one = customizationPrice(normalizeCustomization({ toppings: { [name]: 1 } }).customization);
        for (let q = 2; q <= MAX_TOPPING_QUANTITY; q++) {
            const many = customizationPrice(normalizeCustomization({ toppings: { [name]: q } }).customization);
            assert.equal(many - one, (q - 1) * 300, `${name} x${q}`);
        }
    }
});

test("endulzantes: blanca, morena, estevia y otros se aceptan y no cuestan extra", () => {
    for (const name of ["Azúcar blanca", "Azúcar morena", "Estevia"]) {
        assert.ok(name in SWEETENER_PRICES, name);
    }
    const { customization, error } = normalizeCustomization({
        sweeteners: ["Estevia", "Azúcar morena"]
    });
    assert.equal(error, undefined);
    assert.deepEqual(customization.sweeteners, ["Azúcar morena", "Estevia"]);
    assert.equal(customizationPrice(customization), 0);
    assert.ok(customizationKey(customization).includes("|w:Azúcar morena,Estevia"));
    assert.ok(normalizeCustomization({ sweeteners: ["Azúcar blanca", "Azúcar morena", "Estevia", "Miel"] }).error);
    assert.deepEqual(getCustomizationOptions().sweeteners.max, 3);
});

test("compatibilidad: malvaviscos solo en caliente y bebidas de chocolate o con espuma", () => {
    assert.equal(isToppingCompatible("Malvaviscos", chocolate, "Caliente"), true);
    assert.equal(isToppingCompatible("Malvaviscos", chocolate, "Frío"), false);
    assert.equal(isToppingCompatible("Malvaviscos", lemonade, "Caliente"), false);
    assert.equal(isToppingCompatible("Cacao en polvo", latte, "Caliente"), true);
    assert.equal(isToppingCompatible("Cacao en polvo", tea, "Caliente"), false);
    assert.equal(isToppingCompatible("Canela", tea, "Caliente"), true);
    assert.equal(isToppingCompatible("Chispas", lemonade, "Frío"), true);
    assert.equal(isToppingCompatible("Cacao en polvo", lemonade, "Frío"), false);
    assert.equal(isToppingCompatible("Virutas de chocolate", mocha, "Frío"), true);
});

test("el servidor rechaza un topping que no va con la bebida", () => {
    assert.ok(resolveCustomization(lemonade, { toppings: ["Malvaviscos"] }).error);
    assert.ok(resolveCustomization(latte, { type: "Frío", toppings: ["Malvaviscos"] }).error);
    assert.equal(resolveCustomization(chocolate, { toppings: ["Malvaviscos"] }).error, undefined);
    assert.equal(resolveCustomization(latte, { toppings: ["Cacao en polvo", "Canela"] }).error, undefined);
});

test("las opciones exponen la compatibilidad de toppings", () => {
    const rules = getCustomizationOptions().toppingRules.compatibility;
    assert.deepEqual(rules["Malvaviscos"].types, ["Caliente"]);
    assert.ok(Array.isArray(rules["Cacao en polvo"].keywords));
});
