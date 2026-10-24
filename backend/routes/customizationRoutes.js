import { Router } from "express";

import {
    getOptions
} from "../controllers/customizationController.js";

const router = Router();

// ===================================
// PUBLIC ROUTES
// ===================================

// GET CUSTOMIZATION OPTIONS
router.get(
    "/options",
    getOptions
);

export default router;
