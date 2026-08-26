import Notification from "../models/notificationModel.js";
import User from "../models/userModel.js";

// ===================================
// GET USER NOTIFICATIONS
// ===================================

export const getUserNotifications = async (
    req,
    res
) => {

    try {

        const notifications =
            await Notification.find({

                userId: req.user.id

            })
            .sort({

                createdAt: -1

            });

        return res.status(200).json({

            message:
                "Notifications retrieved successfully",

            notifications

        });

    } catch (error) {

        console.error(
            "Get notifications error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving notifications",

            error: error.message

        });

    }

};

// ===================================
// GET UNREAD NOTIFICATIONS
// ===================================

export const getUnreadNotifications = async (
    req,
    res
) => {

    try {

        const notifications =
            await Notification.find({

                userId: req.user.id,

                isRead: false

            })
            .sort({

                createdAt: -1

            });

        return res.status(200).json({

            message:
                "Unread notifications retrieved successfully",

            notifications,

            count:
                notifications.length

        });

    } catch (error) {

        console.error(
            "Get unread notifications error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving unread notifications",

            error: error.message

        });

    }

};

// ===================================
// GET UNREAD COUNT
// ===================================

export const getUnreadCount = async (
    req,
    res
) => {

    try {

        const count =
            await Notification.countDocuments({

                userId: req.user.id,

                isRead: false

            });

        return res.status(200).json({

            message:
                "Unread notification count retrieved successfully",

            count

        });

    } catch (error) {

        console.error(
            "Get unread count error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving unread notification count",

            error: error.message

        });

    }

};

// ===================================
// CREATE NOTIFICATION
// ===================================

export const createNotification = async (
    req,
    res
) => {

    try {

        const {
            userId,
            title,
            message,
            type,
            relatedId
        } = req.body;

        // ===================================
        // VALIDATE REQUIRED DATA
        // ===================================

        if (
            !userId ||
            !title ||
            !message
        ) {

            return res.status(400).json({

                message:
                    "User ID, title and message are required"

            });

        }

        // ===================================
        // CHECK USER
        // ===================================

        const user =
            await User.findById(userId);

        if (!user) {

            return res.status(404).json({

                message:
                    "User not found"

            });

        }

        // ===================================
        // CREATE NOTIFICATION
        // ===================================

        const newNotification =
            new Notification({

                userId,

                title,

                message,

                type:
                    type || "GENERAL",

                relatedId:
                    relatedId || null

            });

        // ===================================
        // SAVE
        // ===================================

        await newNotification.save();

        return res.status(201).json({

            message:
                "Notification created successfully",

            notification:
                newNotification

        });

    } catch (error) {

        console.error(
            "Create notification error:",
            error
        );

        return res.status(500).json({

            message:
                "Error creating notification",

            error: error.message

        });

    }

};

// ===================================
// MARK NOTIFICATION AS READ
// ===================================

export const markNotificationAsRead = async (
    req,
    res
) => {

    try {

        const notification =
            await Notification.findOne({

                _id: req.params.id,

                userId: req.user.id

            });

        if (!notification) {

            return res.status(404).json({

                message:
                    "Notification not found"

            });

        }

        // ===================================
        // UPDATE READ STATUS
        // ===================================

        notification.isRead = true;

        await notification.save();

        return res.status(200).json({

            message:
                "Notification marked as read",

            notification

        });

    } catch (error) {

        console.error(
            "Mark notification as read error:",
            error
        );

        return res.status(500).json({

            message:
                "Error marking notification as read",

            error: error.message

        });

    }

};

// ===================================
// MARK ALL NOTIFICATIONS AS READ
// ===================================

export const markAllNotificationsAsRead = async (
    req,
    res
) => {

    try {

        await Notification.updateMany(

            {

                userId: req.user.id,

                isRead: false

            },

            {

                $set: {

                    isRead: true

                }

            }

        );

        return res.status(200).json({

            message:
                "All notifications marked as read"

        });

    } catch (error) {

        console.error(
            "Mark all notifications as read error:",
            error
        );

        return res.status(500).json({

            message:
                "Error marking notifications as read",

            error: error.message

        });

    }

};

// ===================================
// DELETE NOTIFICATION
// ===================================

export const deleteNotification = async (
    req,
    res
) => {

    try {

        const notification =
            await Notification.findOneAndDelete({

                _id: req.params.id,

                userId: req.user.id

            });

        if (!notification) {

            return res.status(404).json({

                message:
                    "Notification not found"

            });

        }

        return res.status(200).json({

            message:
                "Notification deleted successfully"

        });

    } catch (error) {

        console.error(
            "Delete notification error:",
            error
        );

        return res.status(500).json({

            message:
                "Error deleting notification",

            error: error.message

        });

    }

};