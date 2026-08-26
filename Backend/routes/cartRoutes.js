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

// UPDATE PRODUCT QUANTITY

router.put(
    "/items/:productId",
    verifyToken,
    updateCartItem
);

// REMOVE PRODUCT

router.delete(
    "/items/:productId",
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