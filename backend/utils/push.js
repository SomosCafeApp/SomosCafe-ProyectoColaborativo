import fs from "fs/promises";

import DeviceToken from "../models/deviceTokenModel.js";

// ===================================
// PUSH NOTIFICATIONS (Firebase Cloud Messaging)
// ===================================
// Credenciales (una de las dos):
//   FIREBASE_SERVICE_ACCOUNT       -> JSON de la cuenta de servicio (en una línea)
//   FIREBASE_SERVICE_ACCOUNT_PATH  -> ruta a ese archivo JSON
//
// Si no hay credenciales (o firebase-admin no está instalado) el
// envío se omite con un aviso: la app sigue funcionando y las
// notificaciones siguen llegando a la pantalla de notificaciones.

// Debe coincidir con el canal que crea la app Flutter.
export const ANDROID_CHANNEL_ID = "somoscafe_default";

// FCM permite máximo 500 mensajes por llamada a sendEach.
const BATCH_SIZE = 500;

// Códigos de error de FCM que significan "este token ya no sirve".
const INVALID_TOKEN_CODES = new Set([
    "messaging/registration-token-not-registered",
    "messaging/invalid-registration-token",
    "messaging/invalid-argument"
]);

let messagingPromise = null;

const loadCredentials = async () => {

    const raw = process.env.FIREBASE_SERVICE_ACCOUNT;
    const path = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;

    if (!raw && !path) return null;

    const json = raw
        ? raw
        : await fs.readFile(path, "utf8");

    const credentials = JSON.parse(json);

    // Si la llave viene de una variable de entorno, los saltos de
    // línea llegan escapados.
    if (credentials.private_key) {
        credentials.private_key =
            credentials.private_key.replace(/\\n/g, "\n");
    }

    return credentials;
};

// Inicializa Firebase una sola vez. Devuelve null si no está
// configurado, en vez de lanzar error.
const getMessaging = () => {

    if (!messagingPromise) {

        messagingPromise = (async () => {

            try {

                const credentials = await loadCredentials();

                if (!credentials) {
                    console.warn(
                        "⚠️  Push desactivado: define " +
                        "FIREBASE_SERVICE_ACCOUNT o " +
                        "FIREBASE_SERVICE_ACCOUNT_PATH."
                    );
                    return null;
                }

                const { default: admin } =
                    await import("firebase-admin");

                if (!admin.apps.length) {
                    admin.initializeApp({
                        credential:
                            admin.credential.cert(credentials)
                    });
                }

                console.log("🔔 Push (FCM) listo");

                return admin.messaging();

            } catch (error) {

                console.error(
                    "Push init error:",
                    error.message
                );

                return null;
            }

        })();
    }

    return messagingPromise;
};

// Se llama al arrancar el servidor para ver de inmediato si Firebase
// quedó bien configurado (si no, solo se inicializaría al primer envío).
export const initPush = async () => {

    const messaging = await getMessaging();

    return Boolean(messaging);
};

const buildMessage = (token, notification) => ({
    token,

    // `notification` hace que el sistema la muestre solo cuando la
    // app está cerrada o en segundo plano.
    notification: {
        title: notification.title,
        body: notification.message
    },

    // FCM exige que todos los valores de `data` sean strings.
    data: {
        notificationId: String(notification._id),
        type: String(notification.type || "GENERAL"),
        relatedId: notification.relatedId
            ? String(notification.relatedId)
            : ""
    },

    android: {
        priority: "high",
        notification: {
            channelId: ANDROID_CHANNEL_ID
        }
    },

    apns: {
        payload: {
            aps: { sound: "default" }
        }
    }
});

// Envía el push de una lista de notificaciones recién creadas.
// NUNCA lanza: un fallo de push no debe romper la acción principal
// (cambio de estado de un pedido, validación de pago, etc.).
export const sendPushForNotifications = async (notifications) => {

    try {

        if (!notifications || notifications.length === 0) return;

        const messaging = await getMessaging();

        if (!messaging) return;

        // Tokens activos de todos los usuarios involucrados, en una
        // sola consulta.
        const userIds = [
            ...new Set(notifications.map(n => String(n.userId)))
        ];

        const devices = await DeviceToken.find({
            userId: { $in: userIds },
            pushEnabled: true
        }).select("userId token");

        if (devices.length === 0) {
            console.log(
                "🔕 Push: el usuario no tiene dispositivos " +
                "registrados con push activado."
            );
            return;
        }

        const tokensByUser = new Map();

        for (const device of devices) {
            const key = String(device.userId);
            if (!tokensByUser.has(key)) tokensByUser.set(key, []);
            tokensByUser.get(key).push(device.token);
        }

        const messages = [];

        for (const notification of notifications) {
            const tokens =
                tokensByUser.get(String(notification.userId)) || [];

            for (const token of tokens) {
                messages.push(buildMessage(token, notification));
            }
        }

        const invalidTokens = [];

        for (let i = 0; i < messages.length; i += BATCH_SIZE) {

            const batch = messages.slice(i, i + BATCH_SIZE);

            const result = await messaging.sendEach(batch);

            result.responses.forEach((response, index) => {

                if (!response.success) {
                    console.error(
                        "Push no enviado:",
                        response.error?.code,
                        "-",
                        response.error?.message
                    );
                }

                if (
                    !response.success &&
                    INVALID_TOKEN_CODES.has(response.error?.code)
                ) {
                    invalidTokens.push(batch[index].token);
                }
            });

            console.log(
                `🔔 Push: ${result.successCount} enviados, ` +
                `${result.failureCount} fallidos`
            );
        }

        // Limpieza: tokens de apps desinstaladas o vencidos.
        if (invalidTokens.length > 0) {
            await DeviceToken.deleteMany({
                token: { $in: invalidTokens }
            });
        }

    } catch (error) {

        console.error(
            "Send push error:",
            error.message
        );

    }
};
