import User from "../models/userModel.js";
<<<<<<< HEAD
import nodemailer from "nodemailer";
=======

import {
    sendRecoveryEmail,
    sendPasswordUpdatedEmail
} from "../utils/mailer.js";

>>>>>>> main
import dotenv from "dotenv";

dotenv.config();

// ===================================
<<<<<<< HEAD
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
=======
// GENERATE RECOVERY CODE
// ===================================

>>>>>>> main
const generateRecoveryCode = () => {

    return Math.floor(
        100000 + Math.random() * 900000
    ).toString();

};

// ===================================
// REQUEST RECOVERY CODE
// ===================================
<<<<<<< HEAD
=======

>>>>>>> main
export const requestRecoveryCode = async (req, res) => {

    try {

        const { email } = req.body;

        // ===================================
        // VALIDATE EMAIL
        // ===================================

        if (!email) {

            return res.status(400).json({

<<<<<<< HEAD
                message: "Email is required"
=======
                message:
                    "Email is required"
>>>>>>> main

            });

        }

<<<<<<< HEAD
        const normalizedEmail =
            email.trim().toLowerCase();
=======
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
>>>>>>> main

        const emailRegex =
            /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!emailRegex.test(normalizedEmail)) {

            return res.status(400).json({

<<<<<<< HEAD
                message: "Invalid email format"
=======
                message:
                    "Invalid email format"
>>>>>>> main

            });

        }

        // ===================================
        // FIND USER
        // ===================================

<<<<<<< HEAD
        const user = await User.findOne({

            email: normalizedEmail

        });
=======
        const user =
            await User.findOne({

                email:
                    normalizedEmail

            });
>>>>>>> main

        if (!user) {

            return res.status(404).json({

<<<<<<< HEAD
                message: "User not found"
=======
                message:
                    "User not found"
>>>>>>> main

            });

        }

        // ===================================
        // VALIDATE ACTIVE ACCOUNT
        // ===================================

        if (!user.isActive) {

            return res.status(403).json({

<<<<<<< HEAD
                message: "User account is inactive"
=======
                message:
                    "User account is inactive"
>>>>>>> main

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

<<<<<<< HEAD
        user.recoveryCode = code;

        user.recoveryCodeExpiration =
            new Date(
                Date.now() + 15 * 60 * 1000
=======
        user.recoveryCode =
            code;

        user.recoveryCodeExpiration =
            new Date(
                Date.now() +
                15 * 60 * 1000
>>>>>>> main
            );

        await user.save();

        // ===================================
<<<<<<< HEAD
        // EMAIL
        // ===================================

        const mailOptions = {

            from: `"SomosCafeApp" <${process.env.EMAIL_USER}>`,

            to: user.email,

            subject:
                "Password Recovery Code - SomosCafeApp",

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
        Password Recovery
    </h2>

    <p style="font-size: 16px;">
        Hello <strong>${user.name || "User"}</strong>,
    </p>

    <p style="
        line-height: 1.7;
        color: #5f4637;
    ">
        We received a request to reset your password.
        Use the following code to continue:
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
            ⏱️ This code expires in
            <strong>15 minutes</strong>.
        </p>

    </div>

    <p style="
        color: #7b5e57;
        font-size: 14px;
        line-height: 1.6;
    ">
        🔒 If you did not request this change,
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

        // ===================================
        // SEND EMAIL
        // ===================================

        await transporter.sendMail(
            mailOptions
        );
=======
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
>>>>>>> main

        console.log(
            `📧 Recovery email sent to ${user.email}`
        );

<<<<<<< HEAD
=======
        // ===================================
        // RESPONSE
        // ===================================

>>>>>>> main
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

<<<<<<< HEAD
            error: error.message
=======
            error:
                error.message
>>>>>>> main

        });

    }

};

// ===================================
// CHANGE PASSWORD
// ===================================
<<<<<<< HEAD
=======

>>>>>>> main
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

<<<<<<< HEAD
        const normalizedEmail =
            email.trim().toLowerCase();
=======
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
>>>>>>> main

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
<<<<<<< HEAD
            !/[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]/.test(
                newPassword
            )
=======
            !/[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]/
                .test(newPassword)
>>>>>>> main
        ) {

            return res.status(400).json({

                message:
                    "Password must contain at least one special character"

            });

        }

        // ===================================
        // FIND USER
        // ===================================

<<<<<<< HEAD
        const user = await User.findOne({

            email: normalizedEmail,

            recoveryCode:
                code.toString(),

            recoveryCodeExpiration: {

                $gt: new Date()

            }

        });
=======
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
>>>>>>> main

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
<<<<<<< HEAD
        // CONFIRMATION EMAIL
        // ===================================

        const mailOptions = {

            from: `"SomosCafeApp" <${process.env.EMAIL_USER}>`,

            to: user.email,

            subject:
                "Password Updated - SomosCafeApp",

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
            Password Updated
        </h1>

    </div>

    <p style="font-size: 16px;">
        Hello <strong>${user.name}</strong>,
    </p>

    <p style="
        line-height: 1.7;
        color: #5f4637;
    ">
        Your password has been successfully
        updated in <strong>SomosCafeApp</strong>.
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
            ✅ You can now log in
            with your new password.
        </p>

    </div>

    <p style="
        color: #7b5e57;
        font-size: 14px;
    ">
        🔒 If you did not make this change,
        contact support immediately.
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

        // ===================================
=======
>>>>>>> main
        // SEND CONFIRMATION EMAIL
        // ===================================

        try {

<<<<<<< HEAD
            await transporter.sendMail(
                mailOptions
            );

            console.log(
                `📧 Password confirmation email sent to ${user.email}`
=======
            await sendPasswordUpdatedEmail(
                user.email,
                user.name
>>>>>>> main
            );

        } catch (emailError) {

<<<<<<< HEAD
            console.error(
                "⚠️ Password changed, but confirmation email could not be sent:",
                emailError.message
=======
            // The password has already been changed.
            // We don't rollback the password just because
            // the confirmation email failed.

            console.error(
                "⚠️ Password changed, but confirmation email could not be sent:",
                emailError
>>>>>>> main
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

<<<<<<< HEAD
            error: error.message
=======
            error:
                error.message
>>>>>>> main

        });

    }

};