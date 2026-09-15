import express from "express";

import {
    verifyToken,
    adminOnly
} from "../middlewares/auth.middleware.js";

import {
    getUserOrders,
    getOrderById,
    createOrder,
    getAllOrders,
    updateOrderStatus,
    updatePaymentStatus,
    cancelOrder
} from "../controllers/orderController.js";

const router = express.Router();

// ===================================
// PROTECTED USER ROUTES
// ===================================

// GET USER ORDERS
router.get(
    "/my-orders",
    verifyToken,
    getUserOrders
);

// GET ORDER BY ID
router.get(
    "/:id",
    verifyToken,
    getOrderById
);

// CREATE ORDER
router.post(
    "/",
    verifyToken,
    createOrder
);

// CANCEL ORDER
router.patch(
    "/:id/cancel",
    verifyToken,
    cancelOrder
);

// ===================================
// PROTECTED ADMIN ROUTES
// ===================================

// GET ALL ORDERS
router.get(
    "/",
    verifyToken,
    adminOnly,
    getAllOrders
);

// UPDATE ORDER STATUS
router.patch(
    "/:id/status",
    verifyToken,
    adminOnly,
    updateOrderStatus
);

// UPDATE PAYMENT STATUS
router.patch(
    "/:id/payment-status",
    verifyToken,
    adminOnly,
    updatePaymentStatus
);

export default router;