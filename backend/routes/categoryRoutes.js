import { Router } from "express";

import {
    verifyToken,
    adminOnly
} from "../middlewares/auth.middleware.js";

import {
    getCategories,
    getCategoryById,
    createCategory,
    updateCategory,
    deleteCategory
} from "../controllers/categoryController.js";

const router = Router();

// ===================================
// PUBLIC ROUTES
// ===================================

// GET ALL CATEGORIES
router.get(
    "/",
    getCategories
);

// GET CATEGORY BY ID
router.get(
    "/:id",
    getCategoryById
);

// ===================================
// PROTECTED ADMIN ROUTES
// ===================================

// CREATE CATEGORY
router.post(
    "/",
    verifyToken,
    adminOnly,
    createCategory
);

// UPDATE CATEGORY
router.put(
    "/:id",
    verifyToken,
    adminOnly,
    updateCategory
);

// DELETE CATEGORY
router.delete(
    "/:id",
    verifyToken,
    adminOnly,
    deleteCategory
);

export default router;