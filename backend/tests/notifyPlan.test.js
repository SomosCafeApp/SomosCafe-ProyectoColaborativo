import test from "node:test";
import assert from "node:assert/strict";

import {
    categoryForType,
    wantsCategory,
    selectRecipients,
    dedupeKeyFor
} from "../utils/notifyPlan.js";

test("novedades se pueden silenciar, avisos importantes no", () => {
    assert.equal(categoryForType("PROMOTION"), "promotions");
    assert.equal(categoryForType("REWARD"), "promotions");
    assert.equal(categoryForType("EVENT"), "news");
    assert.equal(categoryForType("PRODUCT"), "news");
    assert.equal(categoryForType("ORDER"), null);
    assert.equal(categoryForType("SYSTEM"), null);
    assert.equal(categoryForType("GENERAL"), null);
});

test("sin preferencias guardadas se asume que sí quiere", () => {
    assert.equal(wantsCategory({}, "news"), true);
    assert.equal(wantsCategory({ notificationPrefs: { news: false } }, "news"), false);
    assert.equal(wantsCategory({ notificationPrefs: { news: false } }, "promotions"), true);
    assert.equal(wantsCategory({ notificationPrefs: { news: false } }, null), true);
});

test("destinatarios: sin repetidos, sin opt-out y sin avisados", () => {
    const out = selectRecipients({
        userIds: ["1", "1", "2", "3", "4"],
        optedOutIds: new Set(["2"]),
        alreadyNotifiedIds: new Set(["3"])
    });
    assert.deepEqual(out, ["1", "4"]);
});

test("ObjectId y texto cuentan como el mismo destinatario", () => {
    const oid = { toString: () => "abc" };
    assert.deepEqual(selectRecipients({ userIds: [oid, "abc"] }), ["abc"]);
});

test("clave de novedad: igual vigencia = misma clave; otra vigencia = otra", () => {
    const a = new Date("2026-11-01T00:00:00Z");
    const b = new Date("2026-11-30T00:00:00Z");
    const c = new Date("2026-12-31T00:00:00Z");
    assert.equal(dedupeKeyFor("PROMO", "p1", a, b), dedupeKeyFor("PROMO", "p1", a, b));
    assert.notEqual(dedupeKeyFor("PROMO", "p1", a, b), dedupeKeyFor("PROMO", "p1", a, c));
    assert.notEqual(dedupeKeyFor("PROMO", "p1", a, b), dedupeKeyFor("PROMO", "p2", a, b));
});
