import express from "express";

import {
    registerUser
} from "../controllers/userController.js";

import {
    requestEmailVerification,
    verifyEmail
} from "../controllers/emailVerificationController.js";

const router = express.Router();

// ===================================
// REQUEST EMAIL VERIFICATION
// ===================================

router.post(
    "/request-email-verification",
    requestEmailVerification
);

// ===================================
// VERIFY EMAIL
// ===================================

router.post(
    "/verify-email",
    verifyEmail
);

// ===================================
// REGISTER USER
// ===================================

router.post(
    "/register",
    registerUser
);

export default router;