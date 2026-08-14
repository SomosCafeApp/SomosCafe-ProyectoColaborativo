import User from "../models/userModel.js";
import nodemailer from "nodemailer";
import dotenv from "dotenv";

dotenv.config();

// ===================================
// CONFIGURE EMAIL TRANSPORTER
// ===================================
const transporter = nodemailer.createTransport({

    service: "gmail",

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

        // VALIDATE EMAIL
        if (!email) {

            return res.status(400).json({

                message: "Email is required"

            });

        }

        const emailRegex =
            /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!emailRegex.test(email)) {

            return res.status(400).json({

                message: "Invalid email format"

            });

        }

        // FIND USER
        const user = await User.findOne({

            email: email.toLowerCase()

        });

        if (!user) {

            return res.status(404).json({

                message: "User not found"

            });

        }

        // GENERATE CODE
        const code =
            generateRecoveryCode();

        // SAVE CODE
        user.recoveryCode = code;

        user.recoveryCodeExpiration =
            new Date(Date.now() + 900000);

        await user.save();

        // EMAIL
        const mailOptions = {

            from: process.env.EMAIL_USER,

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

        // SEND EMAIL
        await transporter.sendMail(
            mailOptions
        );

        return res.status(200).json({

            message:
                "Recovery email sent successfully"

        });

    } catch (error) {

        console.error(error);

        return res.status(500).json({

            message:
                "Error requesting password recovery",

            error: error.message

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

        // VALIDATE FIELDS
        if (
            !email ||
            !code ||
            !newPassword
        ) {

            return res.status(400).json({

                message: "All fields are required"

            });

        }

        // PASSWORD LENGTH
        if (newPassword.length < 6) {

            return res.status(400).json({

                message:
                    "Password must contain at least 6 characters"

            });

        }

        // NUMBER
        if (!/[0-9]/.test(newPassword)) {

            return res.status(400).json({

                message:
                    "Password must contain at least one number"

            });

        }

        // UPPERCASE
        if (!/[A-Z]/.test(newPassword)) {

            return res.status(400).json({

                message:
                    "Password must contain at least one uppercase letter"

            });

        }

        // LOWERCASE
        if (!/[a-z]/.test(newPassword)) {

            return res.status(400).json({

                message:
                    "Password must contain at least one lowercase letter"

            });

        }

        // SPECIAL CHARACTER
        if (
            !/[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]/.test(
                newPassword
            )
        ) {

            return res.status(400).json({

                message:
                    "Password must contain at least one special character"

            });

        }

        // FIND USER
        const user = await User.findOne({

            email: email.toLowerCase(),

            recoveryCode:
                code.toString(),

            recoveryCodeExpiration: {

                $gt: new Date()

            }

        });

        // VALIDATE CODE
        if (!user) {

            return res.status(400).json({

                message:
                    "Invalid or expired recovery code"

            });

        }

        // CHANGE PASSWORD
        user.password =
            newPassword;

        // CLEAR RECOVERY DATA
        user.recoveryCode = null;

        user.recoveryCodeExpiration = null;

        // SAVE
        await user.save();

        // CONFIRMATION EMAIL
        const mailOptions = {

            from: process.env.EMAIL_USER,

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

        // SEND EMAIL
        await transporter.sendMail(
            mailOptions
        );

        return res.status(200).json({

            message:
                "Password updated successfully"

        });

    } catch (error) {

        console.error(error);

        return res.status(500).json({

            message:
                "Error changing password",

            error: error.message

        });

    }

};