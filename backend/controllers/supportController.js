import { getSupportContact } from "../utils/support.js";

// ===================================
// GET SUPPORT CONTACT
// ===================================
// Datos de contacto de soporte (WhatsApp). Público: también lo usa
// el chat para invitados.

export const getContact = (req, res) => {

    try {
        return res.status(200).json(getSupportContact());
    } catch (error) {
        console.error("Get support contact error:", error);
        return res.status(500).json({
            message: "Error al obtener el contacto de soporte"
        });
    }

};
