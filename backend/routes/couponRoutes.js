import express from "express";

import {
    verifyToken,
    adminOnly
} from "../middlewares/auth.middleware.js";

import {
    getCouponCatalog,
    getMyCoupons,
    redeemCoupon,
    getAllCoupons,
    createCoupon,
    updateCoupon,
    setCouponStatus,
    deleteCoupon
} from "../controllers/couponController.js";

const router = express.Router();

// ===================================
// USER ROUTES
// ===================================
// "/mine" y "/admin" deben ir ANTES de "/:id".

// CATALOG (cupones habilitados para canjear)
router.get("/", verifyToken, getCouponCatalog);

// MY COUPONS (los que ya canjeé)
router.get("/mine", verifyToken, getMyCoupons);

// REDEEM
router.post("/:id/redeem", verifyToken, redeemCoupon);

// ===================================
// ADMIN ROUTES
// ===================================

// GET ALL (incluye deshabilitados)
router.get("/admin", verifyToken, adminOnly, getAllCoupons);

// CREATE (notifica a los clientes)
router.post("/", verifyToken, adminOnly, createCoupon);

// UPDATE
router.put("/:id", verifyToken, adminOnly, updateCoupon);

// ENABLE / DISABLE / REACTIVATE
router.patch("/:id/status", verifyToken, adminOnly, setCouponStatus);

// DELETE
router.delete("/:id", verifyToken, adminOnly, deleteCoupon);

export default router;
