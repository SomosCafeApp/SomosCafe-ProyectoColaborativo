import { Router } from "express";

import {
    verifyToken,
    adminOnly
} from "../middlewares/auth.middleware.js";

import {
    getEvents,
    getActiveEvent,
    getEventById,
    createEvent,
    updateEvent,
    setEventActive,
    deleteEvent
} from "../controllers/eventController.js";

import {
    uploadEventImage
} from "../middlewares/uploadMiddleware.js";

const router = Router();

// ===================================
// PUBLIC ROUTES
// ===================================

// GET ALL EVENTS
router.get(
    "/",
    getEvents
);

// GET ACTIVE EVENT (pop-up de inicio)
// Debe ir ANTES de "/:id", si no Express lo tomaría como un id.
router.get(
    "/active",
    getActiveEvent
);

// GET EVENT BY ID
router.get(
    "/:id",
    getEventById
);

// ===================================
// PROTECTED ADMIN ROUTES
// ===================================

// CREATE EVENT (multipart: campo "imagen" opcional)
router.post(
    "/",
    verifyToken,
    adminOnly,
    uploadEventImage,
    createEvent
);

// UPDATE EVENT (multipart: campo "imagen" opcional)
router.put(
    "/:id",
    verifyToken,
    adminOnly,
    uploadEventImage,
    updateEvent
);

// ACTIVATE / DEACTIVATE EVENT (solo uno activo a la vez)
router.patch(
    "/:id/active",
    verifyToken,
    adminOnly,
    setEventActive
);

// DELETE EVENT
router.delete(
    "/:id",
    verifyToken,
    adminOnly,
    deleteEvent
);

export default router;
