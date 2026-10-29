import Notification from "../models/notificationModel.js";
import User from "../models/userModel.js";
import { categoryForType, selectRecipients } from "./notifyPlan.js";

// ===================================
// NOTIFICATION HELPERS
// ===================================
// Crean notificaciones para varios usuarios a la vez. Al guardarse
// con insertMany, el hook de notificationModel también las envía
// como push (ver utils/push.js).
//
// NINGUNA lanza error: una notificación nunca debe romper la acción
// principal (crear una promoción, un pedido...). Llámalas SIN await
// cuando no quieras retrasar la respuesta al cliente.

// Tamaño de cada insertMany (evita lotes enormes con muchos usuarios).
const CHUNK_SIZE = 500;

export const formatMoney = (value) =>
    `$${Number(value || 0).toLocaleString("es-CO")}`;

export const formatDate = (date) =>
    new Date(date).toLocaleDateString("es-CO", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
        timeZone: "America/Bogota"
    });

// payload: { title, message, type?, relatedId? }
// options.dedupeKey: una novedad se avisa UNA sola vez por usuario.
// Devuelve cuántas notificaciones se crearon (0 si no había a quién).
//
// Antes de crear, respeta las preferencias del usuario: las
// promociones/cupones y las novedades se pueden silenciar; los avisos
// importantes (pedidos, pagos...) siempre llegan.
export const notifyUsers = async (userIds, payload, options = {}) => {

    try {

        const { dedupeKey = null } = options;

        const candidates = [...new Set(userIds.map(String))];

        if (candidates.length === 0) return 0;

        const category = categoryForType(payload.type);

        let optedOutIds = new Set();

        if (category) {
            const optedOut = await User.find({
                _id: { $in: candidates },
                [`notificationPrefs.${category}`]: false
            }).select("_id").lean();

            optedOutIds = new Set(optedOut.map(u => String(u._id)));
        }

        const loadAlreadyNotified = async () => {
            if (!dedupeKey) return new Set();

            const existing = await Notification.find({
                dedupeKey,
                userId: { $in: candidates }
            }).select("userId").lean();

            return new Set(existing.map(n => String(n.userId)));
        };

        const buildDocs = (recipients) => recipients.map(userId => ({
            type: "GENERAL",
            ...payload,
            ...(dedupeKey ? { dedupeKey } : {}),
            userId
        }));

        let recipients = selectRecipients({
            userIds: candidates,
            optedOutIds,
            alreadyNotifiedIds: await loadAlreadyNotified()
        });

        let created = 0;

        for (let attempt = 0; attempt < 2 && recipients.length; attempt++) {

            try {

                const docs = buildDocs(recipients);

                for (let i = 0; i < docs.length; i += CHUNK_SIZE) {
                    await Notification.insertMany(
                        docs.slice(i, i + CHUNK_SIZE)
                    );
                }

                created += docs.length;
                break;

            } catch (error) {

                // Carrera con otra creación de la misma novedad (índice
                // único): se recalcula quién falta y se reintenta una vez.
                if (error?.code !== 11000 || !dedupeKey) throw error;

                recipients = selectRecipients({
                    userIds: candidates,
                    optedOutIds,
                    alreadyNotifiedIds: await loadAlreadyNotified()
                });
            }
        }

        return created;

    } catch (error) {

        console.error(
            "Notify users error:",
            error
        );

        return 0;

    }
};

// Todos los clientes activos (rol USER).
export const notifyAllCustomers = async (payload, options = {}) => {

    try {

        const users = await User.find({
            role: "USER",
            isActive: true
        }).select("_id").lean();

        return await notifyUsers(
            users.map(user => user._id),
            payload,
            options
        );

    } catch (error) {

        console.error(
            "Notify customers error:",
            error
        );

        return 0;

    }
};

// Todos los administradores activos.
export const notifyAllAdmins = async (payload) => {

    try {

        const admins = await User.find({
            role: "ADMIN",
            isActive: true
        }).select("_id").lean();

        await notifyUsers(
            admins.map(admin => admin._id),
            payload
        );

    } catch (error) {

        console.error(
            "Notify admins error:",
            error
        );

    }
};
