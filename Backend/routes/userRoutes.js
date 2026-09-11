import express from "express";

import {
    registerUser
} from "../controllers/userController.js";

import {
    requestEmailVerification,
    verifyEmail,
    resendVerificationCode
} from "../controllers/emailVerificationController.js";

import {
    loginWithGoogle
} from "../controllers/googleController.js";

const router =
    express.Router();

// ===================================
// REGISTER USER
// ===================================

router.post(
    "/register",
    registerUser
);

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
// RESEND EMAIL VERIFICATION
// ===================================

router.post(
    "/resend-email-verification",
    resendVerificationCode
);

// ===================================
// LOGIN WITH GOOGLE
// ===================================

router.post(
    "/login-google",
    loginWithGoogle
);

export default router;