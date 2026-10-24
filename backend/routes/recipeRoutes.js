import express from "express";

import { verifyToken } from "../middlewares/auth.middleware.js";

import {
    getRecipes,
    getLastRecipe,
    upsertRecipe,
    updateRecipe,
    deleteRecipe
} from "../controllers/recipeController.js";

const router = express.Router();

// ===================================
// PROTECTED RECIPE ROUTES
// ===================================

router.get("/", verifyToken, getRecipes);

// Antes de "/:id" para que "last" no se confunda con un ID.
router.get("/last/:productId", verifyToken, getLastRecipe);

router.post("/", verifyToken, upsertRecipe);

router.patch("/:id", verifyToken, updateRecipe);

router.delete("/:id", verifyToken, deleteRecipe);

export default router;
