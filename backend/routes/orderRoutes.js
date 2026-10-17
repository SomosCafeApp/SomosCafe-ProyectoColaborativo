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
    cancelOrder,
    deleteOrder
} from "../controllers/orderController.js";

import {
    uploadPaymentProof,
    validatePayment,
    invalidatePayment
} from "../controllers/orderPaymentController.js";

import {
    uploadProofImage
} from "../middlewares/uploadMiddleware.js";

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

// UPLOAD PAYMENT PROOF (captura de la transferencia)
router.post(
    "/:id/payment-proof",
    verifyToken,
    uploadProofImage,
    uploadPaymentProof
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

// VALIDATE PAYMENT (el pedido pasa a CONFIRMED)
router.patch(
    "/:id/payment/validate",
    verifyToken,
    adminOnly,
    validatePayment
);

// INVALIDATE PAYMENT (el pedido se cancela automáticamente)
router.patch(
    "/:id/payment/invalidate",
    verifyToken,
    adminOnly,
    invalidatePayment
);

// DELETE ORDER (solo pedidos CANCELLED)
router.delete(
    "/:id",
    verifyToken,
    adminOnly,
    deleteOrder
);

export default router;