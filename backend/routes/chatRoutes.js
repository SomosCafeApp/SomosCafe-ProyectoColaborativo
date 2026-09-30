import { Router } from "express";

import {
  chatWithBarista,
  getChatHistory
} from "../controllers/chatController.js";

import {
  optionalAuth,
  verifyToken
} from "../middlewares/auth.middleware.js";

const router = Router();

// optionalAuth: cualquier persona puede chatear (logueada o no).
// Si trae token válido, el chat queda asociado a su usuario;
// si no, queda marcado como anónimo.
router.post(
  "/",
  optionalAuth,
  chatWithBarista
);

// verifyToken: el historial solo existe para cuentas reales, nunca
// para chats anónimos (se descartan al cerrar/perder la sesión).
router.get(
  "/history",
  verifyToken,
  getChatHistory
);

export default router;