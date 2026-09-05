import User from "../models/userModel.js";

import {
    sendRecoveryEmail,
    sendPasswordUpdatedEmail
} from "../utils/mailer.js";

import dotenv from "dotenv";

dotenv.config();

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
                    "Email is required"

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
                    "Invalid email format"

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
                    "User not found"

            });

        }

        // ===================================
        // VALIDATE ACTIVE ACCOUNT
        // ===================================

        if (!user.isActive) {

            return res.status(403).json({

                message:
                    "User account is inactive"

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
                    "Could not send recovery email"

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
                "Recovery email sent successfully"

        });

    } catch (error) {

        console.error(
            "❌ Recovery email error:",
            error
        );

        return res.status(500).json({

            message:
                "Error requesting password recovery",

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
                    "All fields are required"

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
                    "Invalid email format"

            });

        }

        // ===================================
        // PASSWORD LENGTH
        // ===================================

        if (newPassword.length < 6) {

            return res.status(400).json({

                message:
                    "Password must contain at least 6 characters"

            });

        }

        // ===================================
        // NUMBER
        // ===================================

        if (!/[0-9]/.test(newPassword)) {

            return res.status(400).json({

                message:
                    "Password must contain at least one number"

            });

        }

        // ===================================
        // UPPERCASE
        // ===================================

        if (!/[A-Z]/.test(newPassword)) {

            return res.status(400).json({

                message:
                    "Password must contain at least one uppercase letter"

            });

        }

        // ===================================
        // LOWERCASE
        // ===================================

        if (!/[a-z]/.test(newPassword)) {

            return res.status(400).json({

                message:
                    "Password must contain at least one lowercase letter"

            });

        }

        // ===================================
        // SPECIAL CHARACTER
        // ===================================

        if (
            !/[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]/
                .test(newPassword)
        ) {

            return res.status(400).json({

                message:
                    "Password must contain at least one special character"

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
                    "Invalid or expired recovery code"

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
                "Password updated successfully"

        });

    } catch (error) {

        console.error(
            "❌ Change password error:",
            error
        );

        return res.status(500).json({

            message:
                "Error changing password",

            error:
                error.message

        });

    }

};