import User from "../models/userModel.js";
import EmailVerification from "../models/emailVerificationModel.js";

import jwt from "jsonwebtoken";
import dotenv from "dotenv";

import {
    sendVerificationEmail
} from "../utils/mailer.js";

dotenv.config();

// ===================================
// GENERATE VERIFICATION CODE
// ===================================

const generateVerificationCode = () => {

    return Math.floor(
        100000 + Math.random() * 900000
    ).toString();

};

// ===================================
// REQUEST EMAIL VERIFICATION
// ===================================

export const requestEmailVerification =
    async (req, res) => {

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

            if (
                !emailRegex.test(
                    normalizedEmail
                )
            ) {

                return res.status(400).json({

                    message:
                        "Invalid email format"

                });

            }

            // ===================================
            // CHECK IF EMAIL ALREADY EXISTS
            // ===================================

            const existingUser =
                await User.findOne({

                    email:
                        normalizedEmail

                });

            if (existingUser) {

                return res.status(409).json({

                    message:
                        "Email is already registered"

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

            const verification =
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
                        upsert: true,

                        new: true,

                        setDefaultsOnInsert: true
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

                // Remove pending verification
                // if Brevo fails.

                await EmailVerification.deleteOne({
                    _id: verification._id
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

            console.log(
                `📧 Verification email sent to ${normalizedEmail}`
            );

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
                email
                    .trim()
                    .toLowerCase();

            // ===================================
            // VALIDATE EMAIL FORMAT
            // ===================================

            const emailRegex =
                /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

            if (
                !emailRegex.test(
                    normalizedEmail
                )
            ) {

                return res.status(400).json({

                    message:
                        "Invalid email format"

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
                        code.toString().trim(),

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
            // GENERATE VERIFICATION TOKEN
            // ===================================

            const verificationToken =
                jwt.sign(

                    {
                        email:
                            normalizedEmail,

                        purpose:
                            "EMAIL_VERIFICATION"
                    },

                    process.env.JWT_SECRET,

                    {
                        expiresIn:
                            "15m"
                    }

                );

            // ===================================
            // DELETE USED CODE
            // ===================================

            await EmailVerification.deleteOne({

                _id:
                    verification._id

            });

            console.log(
                `✅ Email verified: ${normalizedEmail}`
            );

            // ===================================
            // RESPONSE
            // ===================================

            return res.status(200).json({

                message:
                    "Email verified successfully",

                verificationToken

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

            if (
                !emailRegex.test(
                    normalizedEmail
                )
            ) {

                return res.status(400).json({

                    message:
                        "Invalid email format"

                });

            }

            // ===================================
            // CHECK IF USER ALREADY EXISTS
            // ===================================

            const existingUser =
                await User.findOne({

                    email:
                        normalizedEmail

                });

            if (existingUser) {

                return res.status(409).json({

                    message:
                        "Email is already registered"

                });

            }

            // ===================================
            // CHECK PENDING VERIFICATION
            // ===================================

            const existingVerification =
                await EmailVerification.findOne({

                    email:
                        normalizedEmail

                });

            if (!existingVerification) {

                return res.status(404).json({

                    message:
                        "No pending email verification was found for this email"

                });

            }

            // ===================================
            // GENERATE NEW CODE
            // ===================================

            const code =
                generateVerificationCode();

            // ===================================
            // NEW EXPIRATION
            // ===================================

            const expiresAt =
                new Date(
                    Date.now() +
                    15 * 60 * 1000
                );

            // ===================================
            // UPDATE VERIFICATION
            // ===================================

            existingVerification.code =
                code;

            existingVerification.expiresAt =
                expiresAt;

            await existingVerification.save();

            // ===================================
            // SEND EMAIL WITH BREVO
            // ===================================

            try {

                await sendVerificationEmail(
                    normalizedEmail,
                    code
                );

            } catch (emailError) {

                console.error(
                    "❌ Brevo could not resend verification email:",
                    emailError
                );

                return res.status(502).json({

                    message:
                        "Could not send verification email"

                });

            }

            console.log(
                `📧 New verification code sent to ${normalizedEmail}`
            );

            // ===================================
            // RESPONSE
            // ===================================

            return res.status(200).json({

                message:
                    "New verification code sent successfully"

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
