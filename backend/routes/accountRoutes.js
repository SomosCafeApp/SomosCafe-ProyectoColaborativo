import express from "express";

import { verifyToken } from "../middlewares/auth.middleware.js";

import {
    updateProfile,
    changePasswordWithCurrent,
    requestOwnPasswordCode,
    changePasswordWithCode,
    deleteAccount,
    updateProfileImage,
    deleteProfileImage
} from "../controllers/accountController.js";

import { uploadAvatarImage } from "../middlewares/uploadMiddleware.js";

const router = express.Router();

// Todas son para el usuario del token (cualquier rol).

// DATOS PERSONALES
router.patch("/profile", verifyToken, updateProfile);

// FOTO DE PERFIL (cambiar / eliminar). verifyToken va antes de la
// subida para que nadie sin sesión pueda subir archivos.
router.put("/profile-image", verifyToken, uploadAvatarImage, updateProfileImage);
router.delete("/profile-image", verifyToken, deleteProfileImage);

// CONTRASEÑA - método 1: contraseña actual + nueva
router.post("/password", verifyToken, changePasswordWithCurrent);

// CONTRASEÑA - método 2: "¿Olvidaste tu contraseña?" (código al correo
// de la cuenta logueada, sin pedir el correo)
router.post("/password/code", verifyToken, requestOwnPasswordCode);
router.post("/password/reset", verifyToken, changePasswordWithCode);

// ELIMINAR CUENTA (anonimiza; requiere ELIMINAR + contraseña si la tiene)
router.post("/delete", verifyToken, deleteAccount);

export default router;
