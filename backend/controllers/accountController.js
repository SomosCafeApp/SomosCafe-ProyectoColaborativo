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

const userResponse = (user) => ({
    id: user._id,
    name: user.name,
    lastName: user.lastName,
    email: user.email,
    role: user.role,
    phone: user.phone,
    points: user.points,
    profileImage: user.profileImage,
    isActive: user.isActive,
    isEmailVerified: user.isEmailVerified,
    hasPassword: Boolean(user.password),
    birthDate: formatBirthDate(user.birthDate)
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
        res.status(404).json({ message: "User not found" });
        return null;
    }

    if (!user.isActive) {
        res.status(403).json({ message: "User account is inactive" });
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
            return res.status(400).json({ message: "Name is required" });
        }

        if (name.length > 50 || lastName.length > 50) {
            return res.status(400).json({
                message: "Name and last name cannot exceed 50 characters"
            });
        }

        if (phone && !PHONE_REGEX.test(phone)) {
            return res.status(400).json({ message: "Invalid phone number" });
        }

        // El cumpleaños se registra UNA sola vez: evita cambiarlo para
        // cobrar el cupón de cumpleaños en otra fecha.
        if (rawBirthDate) {

            const birthDate = parseBirthDate(rawBirthDate);

            if (!birthDate) {
                return res.status(400).json({
                    message: "Invalid birth date"
                });
            }

            if (birthDate > new Date() || birthDate.getUTCFullYear() < 1900) {
                return res.status(400).json({
                    message: "Invalid birth date"
                });
            }

            if (user.birthDate) {

                if (formatBirthDate(user.birthDate) !== rawBirthDate) {
                    return res.status(400).json({
                        message: "Birth date can only be set once"
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
            message: "Profile updated successfully",
            user: userResponse(user)
        });

    } catch (error) {

        console.error("Update profile error:", error);

        return res.status(500).json({
            message: "Error updating profile",
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
                message: "All fields are required"
            });
        }

        const user = await findAccount(req, res);
        if (!user) return;

        // Las cuentas creadas con Google no tienen contraseña: pueden
        // crear una con el método del código al correo.
        if (!user.password) {
            return res.status(400).json({
                message: "Account has no password"
            });
        }

        const matches = await bcrypt.compare(
            currentPassword.toString(),
            user.password
        );

        if (!matches) {
            return res.status(400).json({
                message: "Current password is incorrect"
            });
        }

        if (newPassword === currentPassword) {
            return res.status(400).json({
                message: "New password must be different from the current one"
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
            message: "Password updated successfully"
        });

    } catch (error) {

        console.error("Change password (current) error:", error);

        return res.status(500).json({
            message: "Error changing password",
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
                    message: "Please wait before requesting another code"
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
                message: "Could not send recovery email"
            });

        }

        return res.status(200).json({
            message: "Recovery email sent successfully",
            email: user.email
        });

    } catch (error) {

        console.error("Request own code error:", error);

        return res.status(500).json({
            message: "Error requesting password code",
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
                message: "All fields are required"
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
                message: "Invalid or expired recovery code"
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
            message: "Password updated successfully"
        });

    } catch (error) {

        console.error("Change password (code) error:", error);

        return res.status(500).json({
            message: "Error changing password",
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
                message: "Admin accounts cannot be deleted"
            });
        }

        if (
            (confirmation || "").toString().trim().toUpperCase() !==
            "ELIMINAR"
        ) {
            return res.status(400).json({
                message: "Confirmation is required"
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
                    message: "Password is incorrect"
                });
            }

        }

        const activeOrder = await Order.exists({
            userId: user._id,
            status: { $nin: ["DELIVERED", "CANCELLED"] }
        });

        if (activeOrder) {
            return res.status(409).json({
                message: "You have orders in progress"
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
            message: "Account deleted successfully"
        });

    } catch (error) {

        console.error("Delete account error:", error);

        return res.status(500).json({
            message: "Error deleting account",
            error: error.message
        });

    }

};
