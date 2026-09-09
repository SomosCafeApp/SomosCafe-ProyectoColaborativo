import express from "express";

import {
    verifyToken,
    adminOnly
} from "../middlewares/auth.middleware.js";

import {
    getUserPoints,
    getPointHistory,
    addPoints,
    redeemPoints,
    adjustPoints
} from "../controllers/pointsController.js";

const router = express.Router();

// ===================================
// GET USER POINT BALANCE
// ===================================
router.get(
    "/user/:userId",
    verifyToken,
    getUserPoints
);

// ===================================
// GET USER POINT HISTORY
// ===================================
router.get(
    "/user/:userId/history",
    verifyToken,
    getPointHistory
);

// ===================================
// ADD POINTS
// ===================================
router.post(
    "/add",
    verifyToken,
    adminOnly,
    addPoints
);

// ===================================
// REDEEM POINTS
// ===================================
router.post(
    "/redeem",
    verifyToken,
    redeemPoints
);

// ===================================
// ADJUST POINTS
// ===================================
router.put(
    "/adjust",
    verifyToken,
    adminOnly,
    adjustPoints
);

export default router;