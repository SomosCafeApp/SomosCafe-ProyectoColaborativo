import express from "express";

import { verifyToken } from "../middlewares/auth.middleware.js";

import {
    updateProfile,
    changePasswordWithCurrent,
    requestOwnPasswordCode,
    changePasswordWithCode,
    deleteAccount
} from "../controllers/accountController.js";

const router = express.Router();

// Todas son para el usuario del token (cualquier rol).

// DATOS PERSONALES
router.patch("/profile", verifyToken, updateProfile);

// CONTRASEÑA - método 1: contraseña actual + nueva
router.post("/password", verifyToken, changePasswordWithCurrent);

// CONTRASEÑA - método 2: "¿Olvidaste tu contraseña?" (código al correo
// de la cuenta logueada, sin pedir el correo)
router.post("/password/code", verifyToken, requestOwnPasswordCode);
router.post("/password/reset", verifyToken, changePasswordWithCode);

// ELIMINAR CUENTA (anonimiza; requiere ELIMINAR + contraseña si la tiene)
router.post("/delete", verifyToken, deleteAccount);

export default router;
