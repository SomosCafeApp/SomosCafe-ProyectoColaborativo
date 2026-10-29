import { Router } from "express";

import {
  chatWithBarista,
  getChatHistory,
  confirmChatAction,
  startNewConversation
} from "../controllers/chatController.js";

import {
  optionalAuth,
  verifyToken
} from "../middlewares/auth.middleware.js";

import { rateLimitMiddleware } from "../utils/rateLimit.js";

const router = Router();

// Límite por usuario (o IP si es invitado): protege el cupo de la IA
// y evita ráfagas de acciones sobre el carrito.
const chatLimiter = rateLimitMiddleware({
  windowMs: 60 * 1000,
  max: 20
});

// optionalAuth: cualquier persona puede chatear (logueada o no).
// Si trae token válido, el chat queda asociado a su usuario;
// si no, queda marcado como anónimo.
router.post(
  "/",
  optionalAuth,
  chatLimiter,
  chatWithBarista
);

// verifyToken: el historial solo existe para cuentas reales, nunca
// para chats anónimos (se descartan al cerrar/perder la sesión).
router.get(
  "/history",
  verifyToken,
  getChatHistory
);

// Confirmar o cancelar la propuesta de carrito de la conversación.
router.post(
  "/confirm",
  verifyToken,
  chatLimiter,
  confirmChatAction
);

// «Nueva conversación»: archiva la actual.
router.post(
  "/new",
  verifyToken,
  startNewConversation
);

export default router;
