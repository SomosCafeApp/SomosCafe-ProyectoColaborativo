import User from "../models/userModel.js";
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
                        "Email is required"

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
                        "User not found. Please register first."

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
                        "Email is already verified"

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
                        "Could not send verification email"

                });

            }

            // ===================================
            // RESPONSE
            // ===================================

            return res.status(200).json({

                message:
                    "Verification code sent successfully",

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
                    "Error requesting email verification",

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
                        "Email and verification code are required"

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
                        "User not found. Please register first."

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
                        "Email is already verified"

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
                        "Invalid or expired verification code"

                });

            }

            // ===================================
            // VERIFY USER EMAIL
            // ===================================

            user.isEmailVerified =
                true;

            await user.save();

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
                    "Email verified successfully",

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
                    "Error verifying email",

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
                        "Email is required"

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
                        "User not found. Please register first."

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
                        "Email is already verified"

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
                        "Could not send verification email"

                });

            }

            // ===================================
            // RESPONSE
            // ===================================

            return res.status(200).json({

                message:
                    "New verification code sent successfully",

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
                    "Error resending verification code",

                error:
                    error.message

            });

        }

    };