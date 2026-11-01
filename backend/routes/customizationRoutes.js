import { Router } from "express";

import {
    getOptions
} from "../controllers/customizationController.js";

import {
    getStudioProduct,
    quoteStudioDrink
} from "../controllers/drinkStudioController.js";

import { optionalAuth } from "../middlewares/auth.middleware.js";

const router = Router();

// ===================================
// PUBLIC ROUTES
// ===================================

// GET CUSTOMIZATION OPTIONS
router.get(
    "/options",
    getOptions
);

// DRINKSTUDIO: el latte real del menú y la cotización verificada de la
// bebida armada en el minijuego. optionalAuth: el precio incluye las
// promociones del usuario si hay sesión; sin sesión se cotiza igual.
router.get(
    "/drinkstudio/product",
    optionalAuth,
    getStudioProduct
);

router.post(
    "/drinkstudio/quote",
    optionalAuth,
    quoteStudioDrink
);

export default router;
