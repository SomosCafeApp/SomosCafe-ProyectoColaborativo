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
    validatePromotion,
    getPromoOfTheDay,
    getAvailablePromotion,
    setPromoOfTheDay
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

// PROMO OF THE DAY (home, sin login)
// Debe ir ANTES de "/:id", si no Express lo tomaría como un id.
router.get(
    "/promo-of-the-day",
    getPromoOfTheDay
);

// PROMOCIÓN VIGENTE PARA EL CLIENTE (al tocar su notificación)
router.get(
    "/available/:id",
    verifyToken,
    getAvailablePromotion
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

// MARK / UNMARK AS PROMO OF THE DAY
router.patch(
    "/:id/promo-of-the-day",
    verifyToken,
    adminOnly,
    setPromoOfTheDay
);

// DELETE PROMOTION
router.delete(
    "/:id",
    verifyToken,
    adminOnly,
    deletePromotion
);

export default router;