// ===================================
// SOPORTE POR WHATSAPP
// ===================================
// El número NO está en el código: se define en el .env del backend.
//   SUPPORT_WHATSAPP               -> número con indicativo del país
//                                     (ej. 573001234567 o +57 300 123 4567)
//   SUPPORT_WHATSAPP_MESSAGE       -> mensaje inicial opcional
//   SUPPORT_WHATSAPP_COUNTRY_CODE  -> indicativo por defecto (57) para
//                                     números nacionales de 10 dígitos
// Si no está configurado, la app muestra un aviso en vez de abrir
// un enlace roto.

const DEFAULT_MESSAGE = "Hola Somos Café, necesito ayuda con mi pedido.";

// Indicativo por defecto (Colombia). Se puede cambiar con
// SUPPORT_WHATSAPP_COUNTRY_CODE si el negocio usa otro país.
const DEFAULT_COUNTRY_CODE = "57";

// wa.me exige el número en formato internacional (E.164), sin "+",
// espacios ni ceros iniciales: entre 8 y 15 dígitos.
const MIN_DIGITS = 8;
const MAX_DIGITS = 15;

// Devuelve el número listo para wa.me, o null si no es válido.
//   "+57 300 123 4567" -> "573001234567"
//   "3001234567"       -> "573001234567"  (móvil colombiano sin indicativo)
//   "00573001234567"   -> "573001234567"
export const normalizeWhatsAppNumber = (
    raw,
    countryCode = process.env.SUPPORT_WHATSAPP_COUNTRY_CODE || DEFAULT_COUNTRY_CODE
) => {

    let digits = String(raw || "").replace(/\D/g, "");
    const code = String(countryCode || "").replace(/\D/g, "") || DEFAULT_COUNTRY_CODE;

    // Prefijo de llamada internacional "00".
    if (digits.startsWith("00")) {
        digits = digits.slice(2);
    }

    // Número nacional de 10 dígitos sin indicativo (ej. 3001234567):
    // se le antepone el indicativo del país.
    if (digits.length === 10 && !digits.startsWith(code)) {
        digits = `${code}${digits}`;
    }

    if (digits.length < MIN_DIGITS || digits.length > MAX_DIGITS) {
        return null;
    }

    return digits;
};

export const getSupportContact = () => {

    const raw = String(process.env.SUPPORT_WHATSAPP || "").trim();
    const number = normalizeWhatsAppNumber(raw);

    if (!number) {
        return {
            whatsapp: {
                available: false,
                // "not_configured": falta SUPPORT_WHATSAPP; "invalid_number":
                // existe pero no tiene un formato internacional válido.
                reason: raw ? "invalid_number" : "not_configured"
            }
        };
    }

    const message =
        String(process.env.SUPPORT_WHATSAPP_MESSAGE || "").trim() || DEFAULT_MESSAGE;

    return {
        whatsapp: {
            available: true,
            number,
            message,
            url: `https://wa.me/${number}?text=${encodeURIComponent(message)}`
        }
    };
};

// ¿El cliente pide hablar con una persona / por WhatsApp?
const HUMAN_HELP = [
    /whats\s?app/i,
    /\bwasap\b/i,
    /\bwsp\b/i,
    /(hablar|comunicar|contactar|escribir|chatear).{0,25}(asesor|humano|persona|agente|alguien|encargad|soporte|ustedes)/i,
    /(asesor|agente|soporte)\s+(humano|real)/i,
    /\b(atenci[oó]n|servicio)\s+(al\s+cliente|humana)/i,
    /\bn[uú]mero\s+(de\s+)?(contacto|tel[eé]fono|celular)/i
];

export const wantsHumanHelp = (text) =>
    HUMAN_HELP.some(rule => rule.test(String(text || "")));
