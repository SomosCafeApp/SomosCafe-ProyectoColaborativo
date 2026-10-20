import User from "../models/userModel.js";

import nodemailer from "nodemailer";

import {
    sendRecoveryEmail,
    sendPasswordUpdatedEmail
} from "../utils/mailer.js";

import dotenv from "dotenv";

dotenv.config();

// ===================================
// CONFIGURE EMAIL TRANSPORTER
// ===================================

const transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 587,
    secure: false,
    requireTLS: true,
    family: 4,
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

// ===================================
// GENERATE RECOVERY CODE
// ===================================

const generateRecoveryCode = () => {
    return Math.floor(
        100000 + Math.random() * 900000
    ).toString();
};

// ===================================
// REQUEST RECOVERY CODE
// ===================================

export const requestRecoveryCode = async (req, res) => {
    try {
        const { email } = req.body;

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
            email
                .trim()
                .toLowerCase();

        // ===================================
        // VALIDATE EMAIL FORMAT
        // ===================================

        const emailRegex =
            /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!emailRegex.test(normalizedEmail)) {
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
                    "Usuario no encontrado"
            });
        }

        // ===================================
        // VALIDATE ACTIVE ACCOUNT
        // ===================================

        if (!user.isActive) {
            return res.status(403).json({
                message:
                    "La cuenta de usuario está inactiva"
            });
        }

        // ===================================
        // GENERATE RECOVERY CODE
        // ===================================

        const code =
            generateRecoveryCode();

        // ===================================
        // SAVE RECOVERY DATA
        // ===================================

        user.recoveryCode =
            code;

        user.recoveryCodeExpiration =
            new Date(
                Date.now() +
                15 * 60 * 1000
            );

        await user.save();

        // ===================================
        // EMAIL
        // ===================================

        const mailOptions = {
            from:
                `"SomosCafeApp" <${process.env.EMAIL_USER}>`,
            to:
                user.email,
            subject:
                "Código de recuperación de contraseña - SomosCafeApp",
            html: `
<div style="
    font-family: Arial, sans-serif;
    max-width: 600px;
    margin: 0 auto;
    padding: 30px;
    background: #f8f3ee;
    color: #4b2e2b;
    border-radius: 18px;
    border: 1px solid #d8c3b5;
">
    <div style="
        text-align: center;
        margin-bottom: 35px;
    ">
        <h1 style="
            color: #6f4e37;
            margin: 0;
            font-size: 34px;
            letter-spacing: 1px;
        ">
            ☕ SomosCafeApp ☕
        </h1>

        <p style="
            color: #8b5e3c;
            margin-top: 10px;
            font-size: 15px;
        ">
            Tu café, tu cuenta, tu seguridad.
        </p>
    </div>

    <h2 style="
        color: #5c4033;
        margin-bottom: 20px;
    ">
        Recuperación de contraseña
    </h2>

    <p style="font-size: 16px;">
        Hola <strong>${user.name || "Usuario"}</strong>,
    </p>

    <p style="
        line-height: 1.7;
        color: #5f4637;
    ">
        Recibimos una solicitud para restablecer tu contraseña.
        Usa el siguiente código para continuar:
    </p>

    <div style="
        background: linear-gradient(
            135deg,
            #6f4e37 0%,
            #8b5e3c 50%,
            #c4a484 100%
        );
        padding: 35px 20px;
        border-radius: 16px;
        text-align: center;
        margin: 35px 0;
        box-shadow:
            0 10px 25px rgba(
                111,
                78,
                55,
                0.25
            );
    ">
        <h1 style="
            color: #fff8f0;
            font-size: 42px;
            letter-spacing: 10px;
            margin: 0;
            font-family:
                'Courier New',
                Courier,
                monospace;
        ">
            ${code}
        </h1>
    </div>

    <div style="
        background: #efe2d6;
        padding: 18px;
        border-radius: 12px;
        margin-bottom: 20px;
    ">
        <p style="
            margin: 0;
            color: #6b4f3b;
            font-size: 14px;
        ">
            ⏱️ Este código vence en
            <strong>15 minutos</strong>.
        </p>
    </div>

    <p style="
        color: #7b5e57;
        font-size: 14px;
        line-height: 1.6;
    ">
        🔒 Si no solicitaste este cambio,
        puedes ignorar este correo sin problema.
    </p>

    <hr style="
        margin: 35px 0;
        border: none;
        border-top:
            1px solid #d6bfae;
    ">

    <p style="
        color: #9b7b67;
        font-size: 12px;
        text-align: center;
    ">
        © 2026 SomosCafeApp · Café,
        tecnología y seguridad ☕
    </p>
</div>
`
        };

        // ===================================
        // SEND RECOVERY EMAIL WITH BREVO
        // ===================================

        try {
            await sendRecoveryEmail(
                user.email,
                user.name,
                code
            );
        } catch (emailError) {

            // Clear recovery data because
            // the email was not sent.

            user.recoveryCode = null;
            user.recoveryCodeExpiration = null;

            await user.save();

            console.error(
                "❌ Brevo recovery email error:",
                emailError
            );

            return res.status(502).json({
                message:
                    "No se pudo enviar el correo de recuperación"
            });
        }

        console.log(
            `📧 Recovery email sent to ${user.email}`
        );

        // ===================================
        // RESPONSE
        // ===================================

        return res.status(200).json({
            message:
                "Correo de recuperación enviado correctamente"
        });

    } catch (error) {

        console.error(
            "❌ Recovery email error:",
            error
        );

        return res.status(500).json({
            message:
                "Error al solicitar la recuperación de contraseña",
            error:
                error.message
        });
    }
};

// ===================================
// CHANGE PASSWORD
// ===================================

export const changePassword = async (req, res) => {
    try {
        const {
            email,
            code,
            newPassword
        } = req.body;

        // ===================================
        // VALIDATE FIELDS
        // ===================================

        if (
            !email ||
            !code ||
            !newPassword
        ) {
            return res.status(400).json({
                message:
                    "Todos los campos son obligatorios"
            });
        }

        // ===================================
        // NORMALIZE EMAIL
        // ===================================

        const normalizedEmail =
            email
                .trim()
                .toLowerCase();

        // ===================================
        // VALIDATE EMAIL FORMAT
        // ===================================

        const emailRegex =
            /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!emailRegex.test(normalizedEmail)) {
            return res.status(400).json({
                message:
                    "Formato de correo inválido"
            });
        }

        // ===================================
        // PASSWORD LENGTH
        // ===================================

        if (newPassword.length < 6) {
            return res.status(400).json({
                message:
                    "La contraseña debe tener al menos 6 caracteres"
            });
        }

        // ===================================
        // NUMBER
        // ===================================

        if (!/[0-9]/.test(newPassword)) {
            return res.status(400).json({
                message:
                    "La contraseña debe contener al menos un número"
            });
        }

        // ===================================
        // UPPERCASE
        // ===================================

        if (!/[A-Z]/.test(newPassword)) {
            return res.status(400).json({
                message:
                    "La contraseña debe contener al menos una letra mayúscula"
            });
        }

        // ===================================
        // LOWERCASE
        // ===================================

        if (!/[a-z]/.test(newPassword)) {
            return res.status(400).json({
                message:
                    "La contraseña debe contener al menos una letra minúscula"
            });
        }

        // ===================================
        // SPECIAL CHARACTER
        // ===================================

        if (
            !/[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]/.test(
                newPassword
            )
        ) {
            return res.status(400).json({
                message:
                    "La contraseña debe contener al menos un carácter especial"
            });
        }

        // ===================================
        // FIND USER
        // ===================================

        const user =
            await User.findOne({
                email:
                    normalizedEmail,
                recoveryCode:
                    code.toString().trim(),
                recoveryCodeExpiration: {
                    $gt:
                        new Date()
                }
            });

        // ===================================
        // VALIDATE RECOVERY CODE
        // ===================================

        if (!user) {
            return res.status(400).json({
                message:
                    "Código de recuperación inválido o vencido"
            });
        }

        // ===================================
        // CHANGE PASSWORD
        // ===================================

        user.password =
            newPassword;

        // ===================================
        // CLEAR RECOVERY DATA
        // ===================================

        user.recoveryCode = null;
        user.recoveryCodeExpiration = null;

        // ===================================
        // SAVE USER
        // ===================================

        await user.save();

        console.log(
            `🔐 Password updated for ${user.email}`
        );

        // ===================================
        // CONFIRMATION EMAIL
        // ===================================

        const mailOptions = {
            from:
                `"SomosCafeApp" <${process.env.EMAIL_USER}>`,
            to:
                user.email,
            subject:
                "Contraseña actualizada - SomosCafeApp",
            html: `
<div style="
    font-family: Arial, sans-serif;
    max-width: 600px;
    margin: 0 auto;
    padding: 30px;
    background: #f8f3ee;
    color: #4b2e2b;
    border-radius: 18px;
    border: 1px solid #d8c3b5;
">
    <div style="
        text-align: center;
        margin-bottom: 35px;
    ">
        <div style="
            background:
                linear-gradient(
                    135deg,
                    #6f4e37 0%,
                    #8b5e3c 100%
                );
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 20px;
            box-shadow:
                0 10px 20px
                rgba(
                    111,
                    78,
                    55,
                    0.3
                );
        ">
            <span style="
                color: white;
                font-size: 38px;
            ">
                ✓
            </span>
        </div>

        <h1 style="
            color: #6f4e37;
            margin: 0;
        ">
            Contraseña actualizada
        </h1>
    </div>

    <p style="font-size: 16px;">
        Hola <strong>${user.name || "Usuario"}</strong>,
    </p>

    <p style="
        line-height: 1.7;
        color: #5f4637;
    ">
        Tu contraseña se actualizó correctamente
        en <strong>SomosCafeApp</strong>.
    </p>

    <div style="
        background: #efe2d6;
        padding: 18px;
        border-radius: 12px;
        margin: 25px 0;
    ">
        <p style="
            margin: 0;
            color: #6b4f3b;
            font-size: 15px;
        ">
            ✅ Ya puedes iniciar sesión
            con tu nueva contraseña.
        </p>
    </div>

    <p style="
        color: #7b5e57;
        font-size: 14px;
    ">
        🔒 Si no realizaste este cambio,
        comunícate con soporte de inmediato.
    </p>

    <hr style="
        margin: 35px 0;
        border: none;
        border-top:
            1px solid #d6bfae;
    ">

    <p style="
        color: #9b7b67;
        font-size: 12px;
        text-align: center;
    ">
        © 2026 SomosCafeApp · Café,
        tecnología y seguridad ☕
    </p>
</div>
`
        };

        // ===================================
        // SEND CONFIRMATION EMAIL
        // ===================================

        try {
            await sendPasswordUpdatedEmail(
                user.email,
                user.name
            );

        } catch (emailError) {

            // The password has already been changed.
            // We don't rollback the password just because
            // the confirmation email failed.

            console.error(
                "⚠️ Password changed, but confirmation email could not be sent:",
                emailError
            );
        }

        // ===================================
        // SUCCESS RESPONSE
        // ===================================

        return res.status(200).json({
            message:
                "Contraseña actualizada correctamente"
        });

    } catch (error) {

        console.error(
            "❌ Change password error:",
            error
        );

        return res.status(500).json({
            message:
                "Error al cambiar la contraseña",
            error:
                error.message
        });
    }
};
