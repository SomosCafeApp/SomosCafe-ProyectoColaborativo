import { Router } from "express";

import {
    verifyToken,
    adminOnly
} from "../middlewares/auth.middleware.js";

import {
    getEvents,
    getEventById,
    createEvent,
    updateEvent,
    deleteEvent
} from "../controllers/eventController.js";

const router = Router();

// ===================================
// PUBLIC ROUTES
// ===================================

// GET ALL EVENTS
router.get(
    "/",
    getEvents
);

// GET EVENT BY ID
router.get(
    "/:id",
    getEventById
);

// ===================================
// PROTECTED ADMIN ROUTES
// ===================================

// CREATE EVENT
router.post(
    "/",
    verifyToken,
    adminOnly,
    createEvent
);

// UPDATE EVENT
router.put(
    "/:id",
    verifyToken,
    adminOnly,
    updateEvent
);

// DELETE EVENT
router.delete(
    "/:id",
    verifyToken,
    adminOnly,
    deleteEvent
);

export default router;