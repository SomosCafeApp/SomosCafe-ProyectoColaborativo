import { getCustomizationOptions } from "../utils/customization.js";

// ===================================
// GET CUSTOMIZATION OPTIONS
// ===================================
// Devuelve las opciones y precios reales de personalización (las
// mismas que usan el carrito y los pedidos para validar). El
// minijuego de bebidas arma sus etapas a partir de esto.

export const getOptions = (req, res) => {

    try {

        return res.status(200).json({
            options: getCustomizationOptions()
        });

    } catch (error) {

        console.error("Get customization options error:", error);

        return res.status(500).json({
            message: "Error al obtener las opciones de personalización",
            error: error.message
        });

    }

};
