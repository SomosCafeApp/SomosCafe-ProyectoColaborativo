import mongoose from "mongoose";

const emailVerificationSchema = new mongoose.Schema(
    {
        email: {
            type: String,
            required: true,
            unique: true,
            lowercase: true,
            trim: true
        },

        code: {
            type: String,
            required: true
        },

        expiresAt: {
            type: Date,
            required: true,
            index: {
                expires: 0
            }
        }
    },
    {
        timestamps: true,
        collection: "emailVerifications"
    }
);

const EmailVerification =
    mongoose.model(
        "EmailVerification",
        emailVerificationSchema
    );

export default EmailVerification;