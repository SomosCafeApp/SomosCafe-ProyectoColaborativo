import User from "../models/userModel.js";
import { grantWelcomeCoupon } from "../utils/coupons.js";
import EmailVerification from "../models/emailVerificationModel.js";

import {
    sendVerificationEmail
} from "../utils/mailer.js";

import dotenv from "dotenv";

dotenv.config();

// ===================================
// GENERATE VERIFICATION CODE
// ===================================

const generateVerificationCode = () => {

    return Math.floor(
        100000 +
        Math.random() * 900000
    ).toString();

};

// ===================================
// VALIDATE EMAIL
// ===================================

const normalizeEmail = (email) => {

    if (
        typeof email !== "string"
    ) {
        return null;
    }

    const normalizedEmail =
        email
            .trim()
            .toLowerCase();

    const emailRegex =
        /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (
        !emailRegex.test(
            normalizedEmail
        )
    ) {
        return null;
    }

    return normalizedEmail;

};

// ===================================
// REQUEST EMAIL VERIFICATION
// ===================================

export const requestEmailVerification =
    async (req, res) => {

        try {

            const {
                email
            } = req.body;

            // ===================================
            // VALIDATE EMAIL
            // ===================================

            if (!email) {

                return res.status(400).json({

                    message:
                        "El correo es obligatorio"

                });

            }

            // ===================================
            // NORMALIZE EMAIL
            // ===================================

            const normalizedEmail =
                normalizeEmail(email);

            if (!normalizedEmail) {

                return res.status(400).json({

                    message:
                        "Formato de correo inválido"

                });

            }

            // ===================================
            // FIND USER
            // ===================================

            const user =
                await User.findOne({

                    email:
                        normalizedEmail

                });

            if (!user) {

                return res.status(404).json({

                    message:
                        "Usuario no encontrado. Regístrate primero."

                });

            }

            // ===================================
            // CHECK EMAIL STATUS
            // ===================================

            if (
                user.isEmailVerified
            ) {

                return res.status(409).json({

                    message:
                        "El correo ya está verificado"

                });

            }

            // ===================================
            // GENERATE CODE
            // ===================================

            const code =
                generateVerificationCode();

            // ===================================
            // EXPIRATION
            // ===================================

            const expiresAt =
                new Date(
                    Date.now() +
                    15 * 60 * 1000
                );

            // ===================================
            // SAVE VERIFICATION
            // ===================================

            await EmailVerification.findOneAndUpdate(

                {
                    email:
                        normalizedEmail
                },

                {
                    email:
                        normalizedEmail,

                    code,

                    expiresAt
                },

                {
                    upsert:
                        true,

                    new:
                        true,

                    setDefaultsOnInsert:
                        true
                }

            );

            // ===================================
            // SEND EMAIL WITH BREVO
            // ===================================

            try {

                await sendVerificationEmail(

                    normalizedEmail,

                    code

                );

            } catch (emailError) {

                await EmailVerification.deleteOne({

                    email:
                        normalizedEmail

                });

                console.error(

                    "❌ Brevo could not send verification email:",

                    emailError

                );

                return res.status(502).json({

                    message:
                        "No se pudo enviar el correo de verificación"

                });

            }

            // ===================================
            // RESPONSE
            // ===================================

            return res.status(200).json({

                message:
                    "Código de verificación enviado correctamente",

                email:
                    normalizedEmail

            });

        } catch (error) {

            console.error(

                "Request email verification error:",

                error

            );

            return res.status(500).json({

                message:
                    "Error al solicitar la verificación del correo",

                error:
                    error.message

            });

        }

    };

// ===================================
// VERIFY EMAIL
// ===================================

export const verifyEmail =
    async (req, res) => {

        try {

            const {
                email,
                code
            } = req.body;

            // ===================================
            // VALIDATE DATA
            // ===================================

            if (
                !email ||
                !code
            ) {

                return res.status(400).json({

                    message:
                        "El correo y el código de verificación son obligatorios"

                });

            }

            // ===================================
            // NORMALIZE EMAIL
            // ===================================

            const normalizedEmail =
                normalizeEmail(email);

            if (!normalizedEmail) {

                return res.status(400).json({

                    message:
                        "Formato de correo inválido"

                });

            }

            // ===================================
            // FIND USER
            // ===================================

            const user =
                await User.findOne({

                    email:
                        normalizedEmail

                });

            if (!user) {

                return res.status(404).json({

                    message:
                        "Usuario no encontrado. Regístrate primero."

                });

            }

            // ===================================
            // CHECK EMAIL STATUS
            // ===================================

            if (
                user.isEmailVerified
            ) {

                return res.status(409).json({

                    message:
                        "El correo ya está verificado"

                });

            }

            // ===================================
            // FIND VERIFICATION
            // ===================================

            const verification =
                await EmailVerification.findOne({

                    email:
                        normalizedEmail,

                    code:
                        code
                            .toString()
                            .trim(),

                    expiresAt: {

                        $gt:
                            new Date()

                    }

                });

            // ===================================
            // VALIDATE CODE
            // ===================================

            if (!verification) {

                return res.status(400).json({

                    message:
                        "Código de verificación inválido o vencido"

                });

            }

            // ===================================
            // VERIFY USER EMAIL
            // ===================================

            user.isEmailVerified =
                true;

            await user.save();

            // Cupón de bienvenida (si el admin tiene uno habilitado).
            // No se espera y nunca rompe la verificación.
            grantWelcomeCoupon(user._id);

            // ===================================
            // DELETE USED CODE
            // ===================================

            await EmailVerification.deleteOne({

                _id:
                    verification._id

            });

            // ===================================
            // RESPONSE
            // ===================================

            return res.status(200).json({

                message:
                    "Correo verificado correctamente",

                email:
                    user.email

            });

        } catch (error) {

            console.error(

                "Verify email error:",

                error

            );

            return res.status(500).json({

                message:
                    "Error al verificar el correo",

                error:
                    error.message

            });

        }

    };

// ===================================
// RESEND VERIFICATION CODE
// ===================================

export const resendVerificationCode =
    async (req, res) => {

        try {

            const {
                email
            } = req.body;

            // ===================================
            // VALIDATE EMAIL
            // ===================================

            if (!email) {

                return res.status(400).json({

                    message:
                        "El correo es obligatorio"

                });

            }

            // ===================================
            // NORMALIZE EMAIL
            // ===================================

            const normalizedEmail =
                normalizeEmail(email);

            if (!normalizedEmail) {

                return res.status(400).json({

                    message:
                        "Formato de correo inválido"

                });

            }

            // ===================================
            // FIND USER
            // ===================================

            const user =
                await User.findOne({

                    email:
                        normalizedEmail

                });

            if (!user) {

                return res.status(404).json({

                    message:
                        "Usuario no encontrado. Regístrate primero."

                });

            }

            // ===================================
            // CHECK EMAIL STATUS
            // ===================================

            if (
                user.isEmailVerified
            ) {

                return res.status(409).json({

                    message:
                        "El correo ya está verificado"

                });

            }

            // ===================================
            // GENERATE NEW CODE
            // ===================================

            const code =
                generateVerificationCode();

            // ===================================
            // EXPIRATION
            // ===================================

            const expiresAt =
                new Date(
                    Date.now() +
                    15 * 60 * 1000
                );

            // ===================================
            // SAVE NEW VERIFICATION
            // ===================================

            await EmailVerification.findOneAndUpdate(

                {
                    email:
                        normalizedEmail
                },

                {
                    email:
                        normalizedEmail,

                    code,

                    expiresAt
                },

                {
                    upsert:
                        true,

                    new:
                        true,

                    setDefaultsOnInsert:
                        true
                }

            );

            // ===================================
            // SEND EMAIL WITH BREVO
            // ===================================

            try {

                await sendVerificationEmail(

                    normalizedEmail,

                    code

                );

            } catch (emailError) {

                await EmailVerification.deleteOne({

                    email:
                        normalizedEmail

                });

                console.error(

                    "❌ Brevo could not resend verification email:",

                    emailError

                );

                return res.status(502).json({

                    message:
                        "No se pudo enviar el correo de verificación"

                });

            }

            // ===================================
            // RESPONSE
            // ===================================

            return res.status(200).json({

                message:
                    "Nuevo código de verificación enviado correctamente",

                email:
                    normalizedEmail

            });

        } catch (error) {

            console.error(

                "Resend verification code error:",

                error

            );

            return res.status(500).json({

                message:
                    "Error al reenviar el código de verificación",

                error:
                    error.message

            });

        }

    };