import express from "express";

import {
    verifyToken
} from "../middlewares/auth.middleware.js";

import {
    getPaymentMethods,
    getPaymentMethodById,
    createPaymentMethod,
    updatePaymentMethod,
    deletePaymentMethod,
    setDefaultPaymentMethod
} from "../controllers/paymentMethodController.js";

const router = express.Router();

// ===================================
// PROTECTED USER ROUTES
// ===================================

// GET ALL USER PAYMENT METHODS
router.get(
    "/",
    verifyToken,
    getPaymentMethods
);

// GET PAYMENT METHOD BY ID
router.get(
    "/:id",
    verifyToken,
    getPaymentMethodById
);

// CREATE PAYMENT METHOD
router.post(
    "/",
    verifyToken,
    createPaymentMethod
);

// UPDATE PAYMENT METHOD
router.put(
    "/:id",
    verifyToken,
    updatePaymentMethod
);

// DELETE PAYMENT METHOD
router.delete(
    "/:id",
    verifyToken,
    deletePaymentMethod
);

// SET DEFAULT PAYMENT METHOD
router.patch(
    "/:id/default",
    verifyToken,
    setDefaultPaymentMethod
);

export default router;