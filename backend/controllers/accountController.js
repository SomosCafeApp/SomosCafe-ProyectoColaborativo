import bcrypt from "bcryptjs";
import crypto from "crypto";

import User from "../models/userModel.js";
import Order from "../models/orderModel.js";
import Address from "../models/addressModel.js";
import Cart from "../models/cartModel.js";
import Chat from "../models/chatModel.js";
import DeviceToken from "../models/deviceTokenModel.js";
import Favorite from "../models/favoriteModel.js";
import Notification from "../models/notificationModel.js";
import Point from "../models/pointsModel.js";
import PaymentMethod from "../models/paymentMethodModel.js";
import Promotion from "../models/promotionModel.js";
import UserCoupon from "../models/userCouponModel.js";
import EmailVerification from "../models/emailVerificationModel.js";

import { deleteCloudinaryImage } from "../utils/cloudinary.js";

import {
    sendRecoveryEmail,
    sendPasswordUpdatedEmail
} from "../utils/mailer.js";
import { validatePasswordPolicy } from "../utils/passwordPolicy.js";
import { formatBirthDate } from "../utils/userFormat.js";
import { avatarFields, isValidPreset } from "../utils/avatars.js";

// ===================================
// ACCOUNT (usuario ya logueado)
// ===================================
// Datos personales y cambio de contraseña de la cuenta del token.
// El correo NO se puede cambiar aquí (está verificado y es el login).

const CODE_TTL_MS = 15 * 60 * 1000;
const RESEND_COOLDOWN_MS = 60 * 1000;
const MAX_CODE_ATTEMPTS = 5;

const PHONE_REGEX = /^[0-9+()\-\s]{7,20}$/;
const BIRTH_DATE_REGEX = /^\d{4}-\d{2}-\d{2}$/;

const notificationPrefsOf = (user) => ({
    promotions: user.notificationPrefs?.promotions !== false,
    news: user.notificationPrefs?.news !== false
});

const userResponse = (user) => ({
    id: user._id,
    name: user.name,
    lastName: user.lastName,
    email: user.email,
    role: user.role,
    phone: user.phone,
    points: user.points,
    ...avatarFields(user),
    isActive: user.isActive,
    isEmailVerified: user.isEmailVerified,
    hasPassword: Boolean(user.password),
    birthDate: formatBirthDate(user.birthDate),
    notificationPrefs: notificationPrefsOf(user)
});

// "AAAA-MM-DD" → Date a las 12:00 UTC, o null si no es una fecha real.
const parseBirthDate = (value) => {

    if (!BIRTH_DATE_REGEX.test(value)) return null;

    const date = new Date(`${value}T12:00:00.000Z`);

    if (Number.isNaN(date.getTime())) return null;

    // Rechaza fechas inexistentes (ej. 2025-02-31 pasaría a marzo).
    if (date.toISOString().slice(0, 10) !== value) return null;

    return date;

};

const findAccount = async (req, res) => {

    const user = await User.findById(req.user.id);

    if (!user) {
        res.status(404).json({ message: "Usuario no encontrado" });
        return null;
    }

    if (!user.isActive) {
        res.status(403).json({ message: "La cuenta de usuario está inactiva" });
        return null;
    }

    return user;

};

// Contraseña cambiada: se avisa por correo (si falla, no importa).
const sendUpdatedEmail = async (user) => {

    try {
        await sendPasswordUpdatedEmail(user.email, user.name);
    } catch (error) {
        console.error(
            "Password changed, but confirmation email failed:",
            error
        );
    }

};

// ===================================
// UPDATE PROFILE
// ===================================
export const updateProfile = async (req, res) => {

    try {

        const user = await findAccount(req, res);
        if (!user) return;

        const name = (req.body.name || "").toString().trim();
        const lastName = (req.body.lastName || "").toString().trim();
        const phone = (req.body.phone || "").toString().trim();
        const rawBirthDate = (req.body.birthDate || "").toString().trim();

        if (!name) {
            return res.status(400).json({ message: "El nombre es obligatorio" });
        }

        if (name.length > 50 || lastName.length > 50) {
            return res.status(400).json({
                message: "El nombre y el apellido no pueden superar los 50 caracteres"
            });
        }

        if (phone && !PHONE_REGEX.test(phone)) {
            return res.status(400).json({ message: "Número de teléfono inválido" });
        }

        // El cumpleaños se registra UNA sola vez: evita cambiarlo para
        // cobrar el cupón de cumpleaños en otra fecha.
        if (rawBirthDate) {

            const birthDate = parseBirthDate(rawBirthDate);

            if (!birthDate) {
                return res.status(400).json({
                    message: "Fecha de nacimiento inválida"
                });
            }

            if (birthDate > new Date() || birthDate.getUTCFullYear() < 1900) {
                return res.status(400).json({
                    message: "Fecha de nacimiento inválida"
                });
            }

            if (user.birthDate) {

                if (formatBirthDate(user.birthDate) !== rawBirthDate) {
                    return res.status(400).json({
                        message: "La fecha de nacimiento solo se puede establecer una vez"
                    });
                }

            } else {

                user.birthDate = birthDate;

            }

        }

        user.name = name;
        user.lastName = lastName;
        user.phone = phone;

        await user.save();

        return res.status(200).json({
            message: "Perfil actualizado correctamente",
            user: userResponse(user)
        });

    } catch (error) {

        console.error("Update profile error:", error);

        return res.status(500).json({
            message: "Error al actualizar el perfil",
            error: error.message
        });

    }

};

// ===================================
// CHANGE PASSWORD - con la contraseña actual
// ===================================
export const changePasswordWithCurrent = async (req, res) => {

    try {

        const { currentPassword, newPassword } = req.body;

        if (!currentPassword || !newPassword) {
            return res.status(400).json({
                message: "Todos los campos son obligatorios"
            });
        }

        const user = await findAccount(req, res);
        if (!user) return;

        // Las cuentas creadas con Google no tienen contraseña: pueden
        // crear una con el método del código al correo.
        if (!user.password) {
            return res.status(400).json({
                message: "La cuenta no tiene contraseña"
            });
        }

        const matches = await bcrypt.compare(
            currentPassword.toString(),
            user.password
        );

        if (!matches) {
            return res.status(400).json({
                message: "La contraseña actual es incorrecta"
            });
        }

        if (newPassword === currentPassword) {
            return res.status(400).json({
                message: "La nueva contraseña debe ser diferente de la actual"
            });
        }

        const policyError = validatePasswordPolicy(newPassword);

        if (policyError) {
            return res.status(400).json({ message: policyError });
        }

        // El hook de userModel la encripta al guardar.
        user.password = newPassword;
        await user.save();

        await sendUpdatedEmail(user);

        return res.status(200).json({
            message: "Contraseña actualizada correctamente"
        });

    } catch (error) {

        console.error("Change password (current) error:", error);

        return res.status(500).json({
            message: "Error al cambiar la contraseña",
            error: error.message
        });

    }

};

// ===================================
// REQUEST CODE - "¿Olvidaste tu contraseña?" estando logueado
// ===================================
// El código va al correo de la cuenta del token: no se pide el correo.
export const requestOwnPasswordCode = async (req, res) => {

    try {

        const user = await findAccount(req, res);
        if (!user) return;

        // Anti-spam: el código anterior se emitió hace menos de 1 minuto.
        if (user.recoveryCode && user.recoveryCodeExpiration) {

            const issuedAt =
                user.recoveryCodeExpiration.getTime() - CODE_TTL_MS;

            if (Date.now() - issuedAt < RESEND_COOLDOWN_MS) {
                return res.status(429).json({
                    message: "Espera un momento antes de solicitar otro código"
                });
            }

        }

        const code = crypto.randomInt(100000, 1000000).toString();

        user.recoveryCode = code;
        user.recoveryCodeExpiration = new Date(Date.now() + CODE_TTL_MS);
        user.recoveryAttempts = 0;

        await user.save();

        try {

            await sendRecoveryEmail(user.email, user.name, code);

        } catch (emailError) {

            user.recoveryCode = null;
            user.recoveryCodeExpiration = null;
            await user.save();

            console.error("Own recovery email error:", emailError);

            return res.status(502).json({
                message: "No se pudo enviar el correo de recuperación"
            });

        }

        return res.status(200).json({
            message: "Correo de recuperación enviado correctamente",
            email: user.email
        });

    } catch (error) {

        console.error("Request own code error:", error);

        return res.status(500).json({
            message: "Error al solicitar el código de contraseña",
            error: error.message
        });

    }

};

// ===================================
// CHANGE PASSWORD - con el código enviado al correo
// ===================================
export const changePasswordWithCode = async (req, res) => {

    try {

        const { code, newPassword } = req.body;

        if (!code || !newPassword) {
            return res.status(400).json({
                message: "Todos los campos son obligatorios"
            });
        }

        const policyError = validatePasswordPolicy(newPassword);

        if (policyError) {
            return res.status(400).json({ message: policyError });
        }

        const user = await findAccount(req, res);
        if (!user) return;

        const invalid = () =>
            res.status(400).json({
                message: "Código de recuperación inválido o vencido"
            });

        if (
            !user.recoveryCode ||
            !user.recoveryCodeExpiration ||
            user.recoveryCodeExpiration <= new Date()
        ) {
            return invalid();
        }

        if (user.recoveryCode !== code.toString().trim()) {

            // A los 5 intentos fallidos el código deja de servir.
            user.recoveryAttempts = (user.recoveryAttempts || 0) + 1;

            if (user.recoveryAttempts >= MAX_CODE_ATTEMPTS) {
                user.recoveryCode = null;
                user.recoveryCodeExpiration = null;
                user.recoveryAttempts = 0;
            }

            await user.save();

            return invalid();

        }

        user.password = newPassword;
        user.recoveryCode = null;
        user.recoveryCodeExpiration = null;
        user.recoveryAttempts = 0;

        await user.save();

        await sendUpdatedEmail(user);

        return res.status(200).json({
            message: "Contraseña actualizada correctamente"
        });

    } catch (error) {

        console.error("Change password (code) error:", error);

        return res.status(500).json({
            message: "Error al cambiar la contraseña",
            error: error.message
        });

    }

};

// ===================================
// DELETE ACCOUNT
// ===================================
// Elimina la cuenta del usuario del token. Es irreversible.
//
// No se borra el documento: se ANONIMIZA. Los pedidos entregados son
// historial de ventas de la cafetería y deben seguir existiendo, pero
// quedan ligados a una cuenta sin datos personales. Se borran los datos
// del cliente (favoritos, direcciones, carrito, puntos, cupones,
// notificaciones, dispositivos, chat) y el correo queda libre para
// volver a registrarse.
//
// Requisitos: confirmar escribiendo ELIMINAR, la contraseña (si la
// cuenta tiene una; las de Google no) y no tener pedidos en curso.
// Las cuentas de administrador no se pueden eliminar desde aquí.
export const deleteAccount = async (req, res) => {

    try {

        const { password, confirmation } = req.body;

        const user = await findAccount(req, res);
        if (!user) return;

        if (user.role === "ADMIN") {
            return res.status(403).json({
                message: "Las cuentas de administrador no se pueden eliminar"
            });
        }

        if (
            (confirmation || "").toString().trim().toUpperCase() !==
            "ELIMINAR"
        ) {
            return res.status(400).json({
                message: "La confirmación es obligatoria"
            });
        }

        if (user.password) {

            const matches =
                password &&
                await bcrypt.compare(
                    password.toString(),
                    user.password
                );

            if (!matches) {
                return res.status(400).json({
                    message: "La contraseña es incorrecta"
                });
            }

        }

        const activeOrder = await Order.exists({
            userId: user._id,
            status: { $nin: ["DELIVERED", "CANCELLED"] }
        });

        if (activeOrder) {
            return res.status(409).json({
                message: "Tienes pedidos en curso"
            });
        }

        const userId = user._id;
        const oldEmail = user.email;
        const oldImage = user.profileImage;

        // Datos del cliente.
        await Promise.all([
            Address.deleteMany({ userId }),
            Cart.deleteMany({ userId }),
            Chat.deleteMany({ userId }),
            DeviceToken.deleteMany({ userId }),
            Favorite.deleteMany({ userId }),
            Notification.deleteMany({ userId }),
            Point.deleteMany({ userId }),
            PaymentMethod.deleteMany({ userId }),
            UserCoupon.deleteMany({ userId }),
            EmailVerification.deleteMany({ email: oldEmail }),
            Promotion.updateMany(
                { userIds: userId },
                { $pull: { userIds: userId } }
            )
        ]);

        await deleteCloudinaryImage(oldImage);

        // updateOne no pasa por los validadores del esquema: el correo
        // anónimo (único) no tiene que cumplir el formato de un email.
        await User.updateOne(
            { _id: userId },
            {
                $set: {
                    name: "Cuenta eliminada",
                    lastName: "",
                    email: `deleted-${userId}@deleted.invalid`,
                    phone: "",
                    profileImage: "",
                    avatarType: "none",
                    avatarPreset: "",
                    birthDate: null,
                    points: 0,
                    isActive: false,
                    isEmailVerified: false,
                    password: null,
                    recoveryCode: null,
                    recoveryCodeExpiration: null,
                    recoveryAttempts: 0
                },
                $unset: { googleId: "" }
            }
        );

        return res.status(200).json({
            message: "Cuenta eliminada correctamente"
        });

    } catch (error) {

        console.error("Delete account error:", error);

        return res.status(500).json({
            message: "Error al eliminar la cuenta",
            error: error.message
        });

    }

};

// ===================================
// PROFILE PHOTO
// ===================================
// La foto se sube a Cloudinary (carpeta somoscafeapp/perfiles). Las
// fotos que vienen de Google (cuentas creadas con Google) son URLs
// ajenas: no se borran de ningún lado, solo se dejan de usar.

const isOwnProfileImage = (url) =>
    typeof url === "string" && url.includes("/somoscafeapp/perfiles/");

// ===================================
// SET / CHANGE PROFILE PHOTO
// ===================================
export const updateProfileImage = async (req, res) => {

    try {

        if (!req.file) {
            return res.status(400).json({
                message: "La imagen es obligatoria"
            });
        }

        const newImage = req.file.path;

        const user = await findAccount(req, res);

        if (!user) {
            // multer ya la subió: no dejamos archivos huérfanos.
            await deleteCloudinaryImage(newImage);
            return;
        }

        const oldImage = user.profileImage;

        user.profileImage = newImage;
        user.profileImageRemoved = false;
        user.avatarType = "photo";
        user.avatarPreset = "";
        await user.save();

        if (isOwnProfileImage(oldImage)) {
            await deleteCloudinaryImage(oldImage);
        }

        return res.status(200).json({
            message: "Foto de perfil actualizada correctamente",
            user: userResponse(user)
        });

    } catch (error) {

        if (req.file?.path) {
            await deleteCloudinaryImage(req.file.path);
        }

        console.error("Update profile image error:", error);

        return res.status(500).json({
            message: "Error al actualizar la foto de perfil",
            error: error.message
        });

    }

};

// ===================================
// DELETE PROFILE PHOTO
// ===================================
// Vuelve a mostrarse el avatar con las iniciales. Es idempotente: si
// no había foto, responde igual que si la hubiera borrado.
export const deleteProfileImage = async (req, res) => {

    try {

        const user = await findAccount(req, res);
        if (!user) return;

        const oldImage = user.profileImage;

        user.profileImage = "";
        user.profileImageRemoved = true;
        user.avatarType = "none";
        user.avatarPreset = "";
        await user.save();

        if (isOwnProfileImage(oldImage)) {
            await deleteCloudinaryImage(oldImage);
        }

        return res.status(200).json({
            message: "Foto de perfil eliminada correctamente",
            user: userResponse(user)
        });

    } catch (error) {

        console.error("Delete profile image error:", error);

        return res.status(500).json({
            message: "Error al eliminar la foto de perfil",
            error: error.message
        });

    }

};


// ===================================
// SET PRESET AVATAR
// ===================================
// Body: { avatarPreset: "grano" | "taza" | "barista" | "latte" | "cafetera" }
// Elegir un avatar predefinido reemplaza la foto propia (si la había,
// se borra de Cloudinary). profileImageRemoved evita que al volver a
// entrar con Google se le reponga la foto de Google encima del avatar.
export const updateAvatarPreset = async (req, res) => {

    try {

        const { avatarPreset } = req.body || {};

        if (!isValidPreset(avatarPreset)) {
            return res.status(400).json({
                message: "El avatar elegido no es válido"
            });
        }

        const user = await findAccount(req, res);
        if (!user) return;

        const oldImage = user.profileImage;

        user.avatarType = "preset";
        user.avatarPreset = avatarPreset;
        user.profileImage = "";
        user.profileImageRemoved = true;
        await user.save();

        if (isOwnProfileImage(oldImage)) {
            await deleteCloudinaryImage(oldImage);
        }

        return res.status(200).json({
            message: "Avatar actualizado correctamente",
            user: userResponse(user)
        });

    } catch (error) {

        console.error("Update avatar preset error:", error);

        return res.status(500).json({
            message: "Error al actualizar el avatar",
            error: error.message
        });

    }

};

// ===================================
// NOTIFICATION PREFERENCES
// ===================================
// Promociones/cupones y novedades (productos, eventos) se pueden
// silenciar; los avisos importantes (pedidos, pagos) nunca.
export const getNotificationPreferences = async (req, res) => {

    try {

        const user = await findAccount(req, res);
        if (!user) return;

        return res.status(200).json({
            preferences: notificationPrefsOf(user)
        });

    } catch (error) {

        console.error("Get notification prefs error:", error);

        return res.status(500).json({
            message: "Error al obtener las preferencias"
        });

    }

};

export const updateNotificationPreferences = async (req, res) => {

    try {

        const { promotions, news } = req.body || {};

        if (
            (promotions !== undefined && typeof promotions !== "boolean") ||
            (news !== undefined && typeof news !== "boolean")
        ) {
            return res.status(400).json({
                message: "Las preferencias deben ser verdadero o falso"
            });
        }

        if (promotions === undefined && news === undefined) {
            return res.status(400).json({
                message: "Indica al menos una preferencia"
            });
        }

        const user = await findAccount(req, res);
        if (!user) return;

        const current = notificationPrefsOf(user);

        user.notificationPrefs = {
            promotions: promotions ?? current.promotions,
            news: news ?? current.news
        };

        await user.save();

        return res.status(200).json({
            message: "Preferencias actualizadas",
            preferences: notificationPrefsOf(user)
        });

    } catch (error) {

        console.error("Update notification prefs error:", error);

        return res.status(500).json({
            message: "Error al actualizar las preferencias"
        });

    }

};
