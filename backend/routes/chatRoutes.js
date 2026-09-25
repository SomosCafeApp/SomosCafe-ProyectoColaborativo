import { Router } from "express";

import {
  chatWithBarista
} from "../controllers/chatController.js";

import {
  optionalAuth
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

export default router;