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

import {
    upload
} from "../middlewares/uploadMiddleware.js";

const router = Router();

// ===================================
// PUBLIC ROUTES
// ===================================

// GET ALL PRODUCTS
router.get(
    "/",
    getProducts
);

// GET PRODUCT BY ID
router.get(
    "/:id",
    getProductById
);

// ===================================
// PROTECTED ADMIN ROUTES
// ===================================

// CREATE PRODUCT
router.post(
    "/",
    verifyToken,
    adminOnly,
    upload.single("imagen"),
    createProduct
);

// UPDATE PRODUCT
router.put(
    "/:id",
    verifyToken,
    adminOnly,
    upload.single("imagen"),
    updateProduct
);

// DELETE PRODUCT
router.delete(
    "/:id",
    verifyToken,
    adminOnly,
    deleteProduct
);

export default router;