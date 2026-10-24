import test from "node:test";
import assert from "node:assert/strict";

import { getSupportContact, wantsHumanHelp } from "../utils/support.js";

test("sin número configurado WhatsApp no está disponible", () => {
    delete process.env.SUPPORT_WHATSAPP;
    assert.equal(getSupportContact().whatsapp.available, false);
});

test("con número arma el enlace wa.me solo con dígitos", () => {
    process.env.SUPPORT_WHATSAPP = "+57 300 123 4567";
    const { whatsapp } = getSupportContact();
    assert.equal(whatsapp.available, true);
    assert.equal(whatsapp.number, "573001234567");
    assert.ok(whatsapp.url.startsWith("https://wa.me/573001234567?text="));
    delete process.env.SUPPORT_WHATSAPP;
});

test("detecta cuando el cliente pide una persona o WhatsApp", () => {
    for (const text of [
        "quiero hablar con un asesor",
        "me pasas el whatsapp?",
        "necesito soporte humano",
        "quiero comunicarme con una persona",
        "atención al cliente por favor"
    ]) {
        assert.equal(wantsHumanHelp(text), true, text);
    }
    for (const text of ["hola", "qué postres tienen", "recomiéndame un café"]) {
        assert.equal(wantsHumanHelp(text), false, text);
    }
});
