import mongoose from "mongoose";

import { sendPushForNotifications } from "../utils/push.js";

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
                "REWARD",
                "EVENT",
                "PRODUCT"
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

        },

        // ===================================
        // DEDUPE KEY
        // ===================================
        // Identifica la novedad (producto nuevo, promoción con su
        // vigencia...). El índice único (userId + dedupeKey) garantiza
        // que un mismo usuario reciba UNA sola notificación por novedad
        // aunque se guarde, actualice o reactive varias veces.

        dedupeKey: {

            type: String,

            default: null

        }

    },

    {

        timestamps: true,

        collection: "notifications"

    }
);

notificationSchema.index(
    { userId: 1, dedupeKey: 1 },
    {
        unique: true,
        partialFilterExpression: {
            dedupeKey: { $type: "string" }
        }
    }
);

// ===================================
// PUSH HOOKS
// ===================================
// Cada notificación NUEVA (create / save / insertMany) también se
// envía como push al teléfono. Así no hay que tocar los lugares que
// ya crean notificaciones (pedidos, pagos, admin).
// Se envía sin `await`: el push no debe retrasar ni romper la
// acción que originó la notificación.

// `save()` también se ejecuta al marcar como leída; solo nos
// interesan los documentos nuevos.
notificationSchema.pre("save", function () {
    this.$locals.wasNew = this.isNew;
});

notificationSchema.post("save", function (doc) {
    if (doc.$locals.wasNew) {
        sendPushForNotifications([doc]);
    }
});

notificationSchema.post("insertMany", function (docs) {
    sendPushForNotifications(docs);
});

// ===================================
// NOTIFICATION MODEL
// ===================================

const Notification = mongoose.model(
    "Notification",
    notificationSchema
);

export default Notification;