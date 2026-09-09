import mongoose from "mongoose";

const notificationSchema = new mongoose.Schema(
    {

        // ===================================
        // USER REFERENCE
        // ===================================

        userId: {

            type: mongoose.Schema.Types.ObjectId,

            ref: "User",

            required: true

        },

        // ===================================
        // NOTIFICATION TITLE
        // ===================================

        title: {

            type: String,

            required: true,

            trim: true

        },

        // ===================================
        // NOTIFICATION MESSAGE
        // ===================================

        message: {

            type: String,

            required: true,

            trim: true

        },

        // ===================================
        // NOTIFICATION TYPE
        // ===================================

        type: {

            type: String,

            enum: [
                "GENERAL",
                "ORDER",
                "PROMOTION",
                "SYSTEM",
                "REWARD"
            ],

            default: "GENERAL"

        },

        // ===================================
        // READ STATUS
        // ===================================

        isRead: {

            type: Boolean,

            default: false

        },

        // ===================================
        // OPTIONAL RELATED DATA
        // ===================================

        relatedId: {

            type: mongoose.Schema.Types.ObjectId,

            default: null

        }

    },

    {

        timestamps: true,

        collection: "notifications"

    }
);

// ===================================
// NOTIFICATION MODEL
// ===================================

const Notification = mongoose.model(
    "Notification",
    notificationSchema
);

export default Notification;