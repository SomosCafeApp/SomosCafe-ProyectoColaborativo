import { Router } from "express";

import {
    verifyToken,
    adminOnly
} from "../middlewares/auth.middleware.js";

import {
    getUserNotifications,
    getUnreadNotifications,
    getUnreadCount,
    createNotification,
    markNotificationAsRead,
    markAllNotificationsAsRead,
    deleteNotification
} from "../controllers/notificationController.js";

const router = Router();

// ===================================
// USER NOTIFICATIONS
// ===================================

// GET ALL USER NOTIFICATIONS

router.get(
    "/",
    verifyToken,
    getUserNotifications
);

// GET UNREAD NOTIFICATIONS

router.get(
    "/unread",
    verifyToken,
    getUnreadNotifications
);

// GET UNREAD COUNT

router.get(
    "/unread/count",
    verifyToken,
    getUnreadCount
);

// MARK ALL AS READ

router.patch(
    "/read-all",
    verifyToken,
    markAllNotificationsAsRead
);

// MARK ONE AS READ

router.patch(
    "/:id/read",
    verifyToken,
    markNotificationAsRead
);

// DELETE NOTIFICATION

router.delete(
    "/:id",
    verifyToken,
    deleteNotification
);

// ===================================
// ADMIN
// ===================================

// CREATE NOTIFICATION

router.post(
    "/",
    verifyToken,
    adminOnly,
    createNotification
);

export default router;