import test from "node:test";
import assert from "node:assert/strict";

import {
    getSupportContact,
    normalizeWhatsAppNumber,
    wantsHumanHelp
} from "../utils/support.js";

const resetEnv = () => {
    delete process.env.SUPPORT_WHATSAPP;
    delete process.env.SUPPORT_WHATSAPP_MESSAGE;
    delete process.env.SUPPORT_WHATSAPP_COUNTRY_CODE;
};

test("sin número configurado WhatsApp no está disponible", () => {
    resetEnv();
    const { whatsapp } = getSupportContact();
    assert.equal(whatsapp.available, false);
    assert.equal(whatsapp.reason, "not_configured");
});

test("con número arma el enlace wa.me solo con dígitos", () => {
    resetEnv();
    process.env.SUPPORT_WHATSAPP = "+57 300 123 4567";
    const { whatsapp } = getSupportContact();
    assert.equal(whatsapp.available, true);
    assert.equal(whatsapp.number, "573001234567");
    assert.ok(whatsapp.url.startsWith("https://wa.me/573001234567?text="));
    resetEnv();
});

test("agrega el indicativo del país a un móvil de 10 dígitos", () => {
    resetEnv();
    assert.equal(normalizeWhatsAppNumber("3001234567"), "573001234567");
    assert.equal(normalizeWhatsAppNumber("300-123-4567"), "573001234567");
    assert.equal(normalizeWhatsAppNumber("573001234567"), "573001234567");
    assert.equal(normalizeWhatsAppNumber("00573001234567"), "573001234567");
});

test("respeta un indicativo de país distinto", () => {
    resetEnv();
    process.env.SUPPORT_WHATSAPP_COUNTRY_CODE = "52";
    process.env.SUPPORT_WHATSAPP = "5512345678";
    assert.equal(getSupportContact().whatsapp.number, "525512345678");
    resetEnv();
});

test("rechaza números demasiado cortos o largos", () => {
    resetEnv();
    assert.equal(normalizeWhatsAppNumber("12345"), null);
    assert.equal(normalizeWhatsAppNumber("1234567890123456"), null);
    assert.equal(normalizeWhatsAppNumber(""), null);

    process.env.SUPPORT_WHATSAPP = "abc123";
    const { whatsapp } = getSupportContact();
    assert.equal(whatsapp.available, false);
    assert.equal(whatsapp.reason, "invalid_number");
    resetEnv();
});

test("el mensaje inicial viene precargado y codificado en la URL", () => {
    resetEnv();
    process.env.SUPPORT_WHATSAPP = "573001234567";

    // Mensaje por defecto.
    let { whatsapp } = getSupportContact();
    assert.ok(whatsapp.message.length > 0);
    assert.ok(whatsapp.url.includes(encodeURIComponent(whatsapp.message)));

    // Mensaje personalizado.
    process.env.SUPPORT_WHATSAPP_MESSAGE = "Hola, ¿tienen mesa para 4?";
    ({ whatsapp } = getSupportContact());
    assert.equal(whatsapp.message, "Hola, ¿tienen mesa para 4?");
    assert.ok(whatsapp.url.endsWith(encodeURIComponent("Hola, ¿tienen mesa para 4?")));
    resetEnv();
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
