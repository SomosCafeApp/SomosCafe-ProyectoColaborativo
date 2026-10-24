import { Router } from "express";

import { getContact } from "../controllers/supportController.js";

const router = Router();

// GET SUPPORT CONTACT (público)
router.get("/contact", getContact);

export default router;
