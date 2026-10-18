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
    deleteNotification,
    registerDeviceToken,
    unregisterDeviceToken,
    setPushPreference
} from "../controllers/notificationController.js";

const router = Router();

// ===================================
// PUSH DEVICES
// ===================================
// (Van antes de las rutas con :id para que no se confundan.)

// REGISTER DEVICE TOKEN

router.post(
    "/device-token",
    verifyToken,
    registerDeviceToken
);

// UNREGISTER DEVICE TOKEN (logout)

router.post(
    "/device-token/unregister",
    verifyToken,
    unregisterDeviceToken
);

// SET PUSH PREFERENCE

router.patch(
    "/device-token/preference",
    verifyToken,
    setPushPreference
);

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