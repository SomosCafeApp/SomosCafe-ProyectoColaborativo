import User from "../models/userModel.js";
import EmailVerification from "../models/emailVerificationModel.js";

<<<<<<< HEAD
import nodemailer from "nodemailer";
import jwt from "jsonwebtoken";
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
=======
import jwt from "jsonwebtoken";
import dotenv from "dotenv";

import {
    sendVerificationEmail
} from "../utils/mailer.js";

dotenv.config();

// ===================================
>>>>>>> main
// GENERATE VERIFICATION CODE
// ===================================

const generateVerificationCode = () => {

    return Math.floor(
        100000 + Math.random() * 900000
    ).toString();

};

// ===================================
<<<<<<< HEAD
// SEND VERIFICATION EMAIL
// ===================================

const sendVerificationEmail = async (
    email,
    code
) => {

    const mailOptions = {

        from:
            `"SomosCafeApp" <${process.env.EMAIL_USER}>`,

        to:
            email,

        subject:
            "Email Verification Code - SomosCafeApp",

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
            Your coffee, your account, your security.
        </p>

    </div>

    <h2 style="
        color: #5c4033;
        margin-bottom: 20px;
    ">
        Email Verification
    </h2>

    <p style="
        font-size: 16px;
    ">
        Welcome to
        <strong>SomosCafeApp</strong>.
    </p>

    <p style="
        line-height: 1.7;
        color: #5f4637;
    ">
        Use the following code to verify
        your email address:
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
            0 10px 25px
            rgba(
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
    ">

        <p style="
            margin: 0;
            color: #6b4f3b;
            font-size: 14px;
        ">
            ⏱️ This code expires in
            <strong>15 minutes</strong>.
        </p>

    </div>

    <p style="
        color: #7b5e57;
        font-size: 14px;
        margin-top: 25px;
    ">
        🔒 If you did not request this verification,
        you can safely ignore this email.
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
        © 2026 SomosCafeApp · Coffee,
        technology and security ☕
    </p>

</div>

`

    };

    await transporter.sendMail(
        mailOptions
    );

};

// ===================================
=======
>>>>>>> main
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

<<<<<<< HEAD
=======
            // ===================================
            // NORMALIZE EMAIL
            // ===================================

>>>>>>> main
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

<<<<<<< HEAD
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
            // SEND EMAIL
            // ===================================

            await sendVerificationEmail(
                normalizedEmail,
                code
            );
=======
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
>>>>>>> main

            console.log(
                `📧 Verification email sent to ${normalizedEmail}`
            );

            // ===================================
            // RESPONSE
            // ===================================

            return res.status(200).json({

                message:
<<<<<<< HEAD
                    "Verification code sent successfully"
=======
                    "Verification code sent successfully",

                email:
                    normalizedEmail
>>>>>>> main

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

<<<<<<< HEAD
=======
            // ===================================
            // NORMALIZE EMAIL
            // ===================================

>>>>>>> main
            const normalizedEmail =
                email
                    .trim()
                    .toLowerCase();

            // ===================================
<<<<<<< HEAD
=======
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
>>>>>>> main
            // FIND VERIFICATION
            // ===================================

            const verification =
                await EmailVerification.findOne({

                    email:
                        normalizedEmail,

                    code:
<<<<<<< HEAD
                        code.toString(),

                    expiresAt: {
                        $gt: new Date()
=======
                        code.toString().trim(),

                    expiresAt: {

                        $gt:
                            new Date()

>>>>>>> main
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
<<<<<<< HEAD
                        expiresIn: "15m"
=======
                        expiresIn:
                            "15m"
>>>>>>> main
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

<<<<<<< HEAD
=======
            // ===================================
            // NORMALIZE EMAIL
            // ===================================

>>>>>>> main
            const normalizedEmail =
                email
                    .trim()
                    .toLowerCase();

            // ===================================
<<<<<<< HEAD
=======
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
>>>>>>> main
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
<<<<<<< HEAD
=======
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
>>>>>>> main
            // GENERATE NEW CODE
            // ===================================

            const code =
                generateVerificationCode();

<<<<<<< HEAD
=======
            // ===================================
            // NEW EXPIRATION
            // ===================================

>>>>>>> main
            const expiresAt =
                new Date(
                    Date.now() +
                    15 * 60 * 1000
                );

            // ===================================
            // UPDATE VERIFICATION
            // ===================================

<<<<<<< HEAD
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
            // SEND EMAIL
            // ===================================

            await sendVerificationEmail(
                normalizedEmail,
                code
            );
=======
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
>>>>>>> main

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

<<<<<<< HEAD
    };
=======
    };
>>>>>>> main
