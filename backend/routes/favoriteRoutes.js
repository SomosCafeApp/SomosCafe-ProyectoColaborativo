import { Router } from "express";

import {
    verifyToken
} from "../middlewares/auth.middleware.js";

import {
    getFavorites,
    addFavorite,
    removeFavorite
} from "../controllers/favoriteController.js";

const router = Router();

// ===================================
// PROTECTED FAVORITE ROUTES
// ===================================

// GET USER FAVORITES
router.get(
    "/",
    verifyToken,
    getFavorites
);

// ADD FAVORITE
router.post(
    "/",
    verifyToken,
    addFavorite
);

// REMOVE FAVORITE
router.delete(
    "/:productId",
    verifyToken,
    removeFavorite
);

export default router;