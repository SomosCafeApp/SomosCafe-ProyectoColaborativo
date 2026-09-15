import { BrevoClient } from "@getbrevo/brevo";
import dotenv from "dotenv";

dotenv.config();

// ===================================
// CONFIGURE BREVO
// ===================================

const brevo = new BrevoClient({
    apiKey: process.env.BREVO_API_KEY
});

// ===================================
// SEND VERIFICATION EMAIL
// ===================================

export const sendVerificationEmail = async (
    email,
    code
) => {

    try {

        const result =
            await brevo.transactionalEmails.sendTransacEmail({

                sender: {
                    name: "SomosCafeApp",
                    email: process.env.EMAIL_USER
                },

                to: [
                    {
                        email: email
                    }
                ],

                subject:
                    "Email Verification Code - SomosCafeApp",

                htmlContent: `
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

    <p style="font-size: 16px;">
        Welcome to <strong>SomosCafeApp</strong>.
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
            0 10px 25px rgba(111, 78, 55, 0.25);
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
        border-top: 1px solid #d6bfae;
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
            });

        console.log(
            `📧 Verification email sent to ${email}`
        );

        return result;

    } catch (error) {

        console.error(
            "❌ Brevo verification email error:",
            error
        );

        throw error;

    }

};


// ===================================
// SEND RECOVERY EMAIL
// ===================================

export const sendRecoveryEmail = async (
    email,
    name,
    code
) => {

    try {

        const result =
            await brevo.transactionalEmails.sendTransacEmail({

                sender: {
                    name: "SomosCafeApp",
                    email: process.env.EMAIL_USER
                },

                to: [
                    {
                        email: email,
                        name: name || "Usuario"
                    }
                ],

                subject:
                    "Password Recovery Code - SomosCafeApp",

                htmlContent: `
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
        Hello <strong>${name || "User"}</strong>,
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
            0 10px 25px rgba(111, 78, 55, 0.25);
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
        border-top: 1px solid #d6bfae;
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
            });

        console.log(
            `📧 Recovery email sent to ${email}`
        );

        return result;

    } catch (error) {

        console.error(
            "❌ Brevo recovery email error:",
            error
        );

        throw error;

    }

};


// ===================================
// SEND PASSWORD UPDATED EMAIL
// ===================================

export const sendPasswordUpdatedEmail = async (
    email,
    name
) => {

    try {

        const result =
            await brevo.transactionalEmails.sendTransacEmail({

                sender: {
                    name: "SomosCafeApp",
                    email: process.env.EMAIL_USER
                },

                to: [
                    {
                        email: email,
                        name: name || "Usuario"
                    }
                ],

                subject:
                    "Password Updated - SomosCafeApp",

                htmlContent: `
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
            background: linear-gradient(
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
                0 10px 20px rgba(111, 78, 55, 0.3);
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
        Hello <strong>${name || "User"}</strong>,
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
        border-top: 1px solid #d6bfae;
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
            });

        console.log(
            `📧 Password confirmation email sent to ${email}`
        );

        return result;

    } catch (error) {

        console.error(
            "❌ Brevo password confirmation email error:",
            error
        );

        throw error;

    }

};