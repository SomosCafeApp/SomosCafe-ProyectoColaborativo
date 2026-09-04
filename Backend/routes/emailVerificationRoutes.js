import express from "express";

import {
    requestEmailVerification,
    verifyEmail,
    resendVerificationCode
} from "../controllers/emailVerificationController.js";

const router = express.Router();

<<<<<<< HEAD
// ===================================
// REQUEST EMAIL VERIFICATION
// ===================================

=======
>>>>>>> main
router.post(
    "/request",
    requestEmailVerification
);

<<<<<<< HEAD
// ===================================
// VERIFY EMAIL
// ===================================

=======
>>>>>>> main
router.post(
    "/verify",
    verifyEmail
);

<<<<<<< HEAD
// ===================================
// RESEND VERIFICATION CODE
// ===================================

=======
>>>>>>> main
router.post(
    "/resend",
    resendVerificationCode
);

export default router;