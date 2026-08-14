import { Router } from "express";

import {
    verifyToken,
    adminOnly
} from "../middlewares/auth.middleware.js";

import {
    getProducts,
    getProductById,
    createProduct,
    updateProduct,
    deleteProduct
} from "../controllers/productController.js";

const router = Router();

// ===================================
// PUBLIC ROUTES
// ===================================

router.get(
    "/",
    getProducts
);

router.get(
    "/:id",
    getProductById
);

// ===================================
// PROTECTED ADMIN ROUTES
// ===================================

router.post(
    "/",
    verifyToken,
    adminOnly,
    createProduct
);

router.put(
    "/:id",
    verifyToken,
    adminOnly,
    updateProduct
);

router.delete(
    "/:id",
    verifyToken,
    adminOnly,
    deleteProduct
);

export default router;