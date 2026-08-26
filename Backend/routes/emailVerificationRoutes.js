import express from "express";

import {
    requestEmailVerification,
    verifyEmail,
    resendVerificationCode
} from "../controllers/emailVerificationController.js";

const router = express.Router();

// ===================================
// REQUEST EMAIL VERIFICATION
// ===================================

router.post(
    "/request",
    requestEmailVerification
);

// ===================================
// VERIFY EMAIL
// ===================================

router.post(
    "/verify",
    verifyEmail
);

// ===================================
// RESEND VERIFICATION CODE
// ===================================

router.post(
    "/resend",
    resendVerificationCode
);

export default router;