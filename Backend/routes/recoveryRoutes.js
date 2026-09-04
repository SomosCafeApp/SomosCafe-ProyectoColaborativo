import express from "express";

import {
    requestRecoveryCode,
    changePassword
} from "../controllers/recoveryController.js";

const router = express.Router();

<<<<<<< HEAD
// ===================================
// REQUEST RECOVERY CODE
// ===================================
=======
>>>>>>> main
router.post(
    "/request",
    requestRecoveryCode
);

<<<<<<< HEAD
// ===================================
// CHANGE PASSWORD
// ===================================
=======
>>>>>>> main
router.post(
    "/change-password",
    changePassword
);

export default router;