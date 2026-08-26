import express from "express";

import {
    requestRecoveryCode,
    changePassword
} from "../controllers/recoveryController.js";

const router = express.Router();

// ===================================
// REQUEST RECOVERY CODE
// ===================================
router.post(
    "/request",
    requestRecoveryCode
);

// ===================================
// CHANGE PASSWORD
// ===================================
router.post(
    "/change-password",
    changePassword
);

export default router;