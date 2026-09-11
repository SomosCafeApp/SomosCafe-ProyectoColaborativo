import { Router } from "express";

import {
  chatWithBarista
} from "../controllers/chatController.js";

import {
  verifyToken
} from "../middlewares/auth.middleware.js";

const router = Router();

router.post(
  "/",
  verifyToken,
  chatWithBarista
);

export default router;