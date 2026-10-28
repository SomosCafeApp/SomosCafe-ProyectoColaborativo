import { Router } from "express";

import {
    verifyToken,
    adminOnly
} from "../middlewares/auth.middleware.js";

import {
    getProducts,
    getAllProductsAdmin,
    getProductById,
    createProduct,
    updateProduct,
    deleteProduct
} from "../controllers/productController.js";

import {
    uploadProductImage
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

// GET ALL PRODUCTS INCLUDING HIDDEN (ADMIN)
// Debe ir ANTES de "/:id", si no Express lo tomaría como un id.
router.get(
    "/admin/all",
    verifyToken,
    adminOnly,
    getAllProductsAdmin
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
    uploadProductImage,
    createProduct
);

// UPDATE PRODUCT

router.put(
    "/:id",
    verifyToken,
    adminOnly,
    uploadProductImage,
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
