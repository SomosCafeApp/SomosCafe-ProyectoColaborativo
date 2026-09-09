import express from "express";

import {
    registerUser
} from "../controllers/userController.js";

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
// LOGIN WITH GOOGLE
// ===================================

router.post(
    "/login-google",
    loginWithGoogle
);

export default router;
