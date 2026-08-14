import express from "express";

import {
    registerUser
} from "../controllers/userController.js";

const router = express.Router();

// ===================================
// REGISTER USER
// ===================================
router.post(
    "/register",
    registerUser
);

export default router;