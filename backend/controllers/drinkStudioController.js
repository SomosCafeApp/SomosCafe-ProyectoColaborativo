import mongoose from "mongoose";

import Product from "../models/productModel.js";
import { getDiscountResolver } from "../utils/promotions.js";
import {
    pickLatteProduct,
    studioProductView,
    buildStudioQuote
} from "../utils/drinkStudio.js";

// ===================================
// DRINKSTUDIO: PRODUCTO REAL Y COTIZACIÓN
// ===================================
// El minijuego arma la bebida; aquí se decide qué producto del menú es
// y cuánto cuesta. Nada se guarda: agregar al carrito sigue siendo
// POST /api/cart/items (mismo flujo, mismas validaciones).

// ===================================
// GET /customization/drinkstudio/product
// ===================================
// El latte que DrinkStudio puede vender (null si el menú no tiene uno
// disponible: la app deja jugar pero avisa que no se puede comprar).

export const getStudioProduct = async (req, res) => {

    try {

        const products = await Product
            .find({ isAvailable: true, name: /latte/i })
            .populate("categoryId", "name")
            .lean();

        const latte = pickLatteProduct(products);

        if (!latte) {
            return res.status(200).json({ product: null });
        }

        const resolver = await getDiscountResolver(req.user?.id ?? null);

        return res.status(200).json({
            product: studioProductView(latte, resolver)
        });

    } catch (error) {

        console.error("DrinkStudio product error:", error);

        return res.status(500).json({
            message: "Error al buscar el latte del menú",
            error: error.message
        });
    }
};

// ===================================
// POST /customization/drinkstudio/quote
// ===================================
// Body: { productId, quantity, customization, milkLevel }
// Responde la configuración NORMALIZADA y el precio oficial. Si la
// configuración no es compatible (p. ej. latte art en frío) responde
// 400 con el motivo; si el producto ya no está disponible, 409.

export const quoteStudioDrink = async (req, res) => {

    try {

        const { productId } = req.body || {};

        if (!productId || !mongoose.isValidObjectId(productId)) {
            return res.status(400).json({
                code: "INVALID_PRODUCT",
                message: "El ID del producto no es válido"
            });
        }

        const product = await Product
            .findById(productId)
            .populate("categoryId", "name")
            .lean();

        const resolver = await getDiscountResolver(req.user?.id ?? null);

        const quote = buildStudioQuote({
            product,
            raw: req.body,
            discountOf: resolver
        });

        if (!quote.ok) {
            return res.status(quote.status).json({
                code: quote.code,
                message: quote.message
            });
        }

        return res.status(200).json({
            quote: {
                productId: quote.productId,
                quantity: quote.quantity,
                customization: quote.customization,
                milkLevel: quote.milkLevel,
                customizationKey: quote.key,
                basePrice: quote.basePrice,
                sizeAdjustment: quote.sizeAdjustment,
                lines: quote.lines,
                customizationPrice: quote.customizationPrice,
                originalUnitPrice: quote.originalUnitPrice,
                discountPerUnit: quote.discountPerUnit,
                promotionName: quote.promotionName,
                unitPrice: quote.unitPrice,
                lineTotal: quote.lineTotal
            }
        });

    } catch (error) {

        console.error("DrinkStudio quote error:", error);

        return res.status(500).json({
            message: "Error al calcular el precio de tu bebida",
            error: error.message
        });
    }
};
