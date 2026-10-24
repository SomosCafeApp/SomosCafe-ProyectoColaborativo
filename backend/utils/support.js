// ===================================
// SOPORTE POR WHATSAPP
// ===================================
// El número NO está en el código: se define en el .env del backend.
//   SUPPORT_WHATSAPP          -> número con indicativo, solo dígitos
//                                (ej. 573001234567)
//   SUPPORT_WHATSAPP_MESSAGE  -> mensaje inicial opcional
// Si no está configurado, la app muestra un aviso en vez de abrir
// un enlace roto.

const DEFAULT_MESSAGE = "Hola Somos Café, necesito ayuda con mi pedido.";

export const getSupportContact = () => {

    const number = String(process.env.SUPPORT_WHATSAPP || "")
        .replace(/\D/g, "");

    if (number.length < 8) {
        return { whatsapp: { available: false } };
    }

    const message =
        process.env.SUPPORT_WHATSAPP_MESSAGE || DEFAULT_MESSAGE;

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
