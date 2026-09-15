import express from "express";

import {
    verifyToken,
    adminOnly
} from "../middlewares/auth.middleware.js";

import {
    getProductReviews,
    getUserReviews,
    createReview,
    updateReview,
    deleteReview,
    toggleReviewVisibility
} from "../controllers/reviewsController.js";

const router = express.Router();

// ===================================
// GET PRODUCT REVIEWS
// ===================================

router.get(
    "/product/:productId",
    getProductReviews
);

// ===================================
// GET USER REVIEWS
// ===================================

router.get(
    "/user/:userId",
    verifyToken,
    getUserReviews
);

// ===================================
// CREATE REVIEW
// ===================================

router.post(
    "/",
    verifyToken,
    createReview
);

// ===================================
// UPDATE REVIEW
// ===================================

router.put(
    "/:id",
    verifyToken,
    updateReview
);

// ===================================
// DELETE REVIEW
// ===================================

router.delete(
    "/:id",
    verifyToken,
    deleteReview
);

// ===================================
// ADMIN TOGGLE VISIBILITY
// ===================================

router.patch(
    "/:id/visibility",
    verifyToken,
    adminOnly,
    toggleReviewVisibility
);

export default router;