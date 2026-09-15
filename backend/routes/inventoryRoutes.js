import { Router } from "express";

import {
    verifyToken,
    adminOnly
} from "../middlewares/auth.middleware.js";

import {
    getInventory,
    getInventoryByProduct,
    createInventory,
    updateInventory,
    updateStock,
    deleteInventory
} from "../controllers/inventoryController.js";

const router = Router();

// ===================================
// PROTECTED ADMIN ROUTES
// ===================================

// GET ALL INVENTORY

router.get(
    "/",
    verifyToken,
    adminOnly,
    getInventory
);

// GET INVENTORY BY PRODUCT

router.get(
    "/:productId",
    verifyToken,
    adminOnly,
    getInventoryByProduct
);

// CREATE INVENTORY

router.post(
    "/",
    verifyToken,
    adminOnly,
    createInventory
);

// UPDATE INVENTORY

router.put(
    "/:productId",
    verifyToken,
    adminOnly,
    updateInventory
);

// UPDATE STOCK

router.patch(
    "/:productId/stock",
    verifyToken,
    adminOnly,
    updateStock
);

// DELETE INVENTORY

router.delete(
    "/:productId",
    verifyToken,
    adminOnly,
    deleteInventory
);

export default router;