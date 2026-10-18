import mongoose from "mongoose";

// ===================================
// DEVICE TOKEN (push notifications)
// ===================================
// Un registro por instalación de la app (token FCM). Un usuario puede
// tener varios dispositivos. El token es único: si otra cuenta inicia
// sesión en el mismo teléfono, el registro se reasigna a esa cuenta y
// el usuario anterior deja de recibir sus notificaciones ahí.

const deviceTokenSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
            index: true
        },

        token: {
            type: String,
            required: true,
            unique: true,
            trim: true
        },

        platform: {
            type: String,
            enum: ["android", "ios", "web", "unknown"],
            default: "unknown"
        },

        // Preferencia del usuario (switch "Push" de la app) para
        // este dispositivo.
        pushEnabled: {
            type: Boolean,
            default: true
        },

        lastSeenAt: {
            type: Date,
            default: Date.now
        }
    },
    {
        timestamps: true,
        collection: "deviceTokens"
    }
);

const DeviceToken = mongoose.model(
    "DeviceToken",
    deviceTokenSchema
);

export default DeviceToken;
