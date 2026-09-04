import express from "express";

import {
    requestRecoveryCode,
    changePassword
} from "../controllers/recoveryController.js";

const router = express.Router();

router.post(
    "/request",
    requestRecoveryCode
);

router.post(
    "/change-password",
    changePassword
);

export default router;