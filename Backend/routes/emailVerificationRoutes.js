import express from "express";

import {
    requestEmailVerification,
    verifyEmail,
    resendVerificationCode
} from "../controllers/emailVerificationController.js";

const router = express.Router();

router.post(
    "/request",
    requestEmailVerification
);

router.post(
    "/verify",
    verifyEmail
);

router.post(
    "/resend",
    resendVerificationCode
);

export default router;