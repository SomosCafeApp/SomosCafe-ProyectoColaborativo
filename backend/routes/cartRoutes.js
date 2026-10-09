import express from "express";

import {
    verifyToken
} from "../middlewares/auth.middleware.js";

import {
    getCart,
    addToCart,
    updateCartItem,
    removeFromCart,
    clearCart
} from "../controllers/cartController.js";

const router = express.Router();

// ===================================
// PROTECTED CART ROUTES
// ===================================

// GET CART

router.get(
    "/",
    verifyToken,
    getCart
);

// ADD PRODUCT

router.post(
    "/items",
    verifyToken,
    addToCart
);

// UPDATE LINE QUANTITY (itemId = _id de la línea)

router.put(
    "/items/:itemId",
    verifyToken,
    updateCartItem
);

// REMOVE LINE (itemId = _id de la línea)

router.delete(
    "/items/:itemId",
    verifyToken,
    removeFromCart
);

// CLEAR CART

router.delete(
    "/",
    verifyToken,
    clearCart
);

export default router;