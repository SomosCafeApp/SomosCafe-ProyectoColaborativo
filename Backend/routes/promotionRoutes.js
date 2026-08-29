import express from "express";

import {
    verifyToken,
    adminOnly
} from "../middlewares/auth.middleware.js";

import {
    getPromotions,
    getPromotionById,
    createPromotion,
    updatePromotion,
    deletePromotion,
    validatePromotion
} from "../controllers/promotionController.js";

const router = express.Router();

// ===================================
// PUBLIC / AUTHENTICATED ROUTES
// ===================================

// VALIDATE PROMOTION
router.post(
    "/validate",
    verifyToken,
    validatePromotion
);

// ===================================
// ADMIN ROUTES
// ===================================

// GET ALL PROMOTIONS
router.get(
    "/",
    verifyToken,
    adminOnly,
    getPromotions
);

// GET PROMOTION BY ID
router.get(
    "/:id",
    verifyToken,
    adminOnly,
    getPromotionById
);

// CREATE PROMOTION
router.post(
    "/",
    verifyToken,
    adminOnly,
    createPromotion
);

// UPDATE PROMOTION
router.put(
    "/:id",
    verifyToken,
    adminOnly,
    updatePromotion
);

// DELETE PROMOTION
router.delete(
    "/:id",
    verifyToken,
    adminOnly,
    deletePromotion
);

export default router;