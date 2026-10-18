import Notification from "../models/notificationModel.js";
import User from "../models/userModel.js";

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
export const notifyUsers = async (userIds, payload) => {

    try {

        const ids = [...new Set(userIds.map(String))];

        if (ids.length === 0) return;

        const docs = ids.map(userId => ({
            type: "GENERAL",
            ...payload,
            userId
        }));

        for (let i = 0; i < docs.length; i += CHUNK_SIZE) {
            await Notification.insertMany(
                docs.slice(i, i + CHUNK_SIZE)
            );
        }

    } catch (error) {

        console.error(
            "Notify users error:",
            error
        );

    }
};

// Todos los clientes activos (rol USER).
export const notifyAllCustomers = async (payload) => {

    try {

        const users = await User.find({
            role: "USER",
            isActive: true
        }).select("_id").lean();

        await notifyUsers(
            users.map(user => user._id),
            payload
        );

    } catch (error) {

        console.error(
            "Notify customers error:",
            error
        );

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
