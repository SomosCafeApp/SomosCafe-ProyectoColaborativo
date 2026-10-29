import test from "node:test";
import assert from "node:assert/strict";

import { createRateLimiter } from "../utils/rateLimit.js";

test("permite hasta el máximo y luego bloquea", () => {
    let t = 0;
    const limiter = createRateLimiter({ windowMs: 1000, max: 3, now: () => t });
    assert.equal(limiter.check("u").allowed, true);
    assert.equal(limiter.check("u").allowed, true);
    assert.equal(limiter.check("u").allowed, true);
    const blocked = limiter.check("u");
    assert.equal(blocked.allowed, false);
    assert.ok(blocked.retryAfterMs > 0);
});

test("la ventana se libera con el tiempo", () => {
    let t = 0;
    const limiter = createRateLimiter({ windowMs: 1000, max: 1, now: () => t });
    assert.equal(limiter.check("u").allowed, true);
    assert.equal(limiter.check("u").allowed, false);
    t = 1001;
    assert.equal(limiter.check("u").allowed, true);
});

test("cada clave tiene su propio cupo", () => {
    const limiter = createRateLimiter({ windowMs: 1000, max: 1, now: () => 0 });
    assert.equal(limiter.check("a").allowed, true);
    assert.equal(limiter.check("b").allowed, true);
    assert.equal(limiter.check("a").allowed, false);
});
