import mongoose from "mongoose";

const paymentMethodSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true
        },

        type: {
            type: String,
            enum: [
                "CARD",
                "CASH",
                "BANK_TRANSFER",
                "DIGITAL_WALLET"
            ],
            required: true
        },

        provider: {
            type: String,
            trim: true,
            default: ""
        },

        name: {
            type: String,
            trim: true,
            default: ""
        },

        lastFourDigits: {
            type: String,
            trim: true,
            maxlength: 4,
            default: ""
        },

        expirationMonth: {
            type: Number,
            min: 1,
            max: 12,
            default: null
        },

        expirationYear: {
            type: Number,
            min: 2026,
            default: null
        },

        token: {
            type: String,
            trim: true,
            default: null
        },

        isDefault: {
            type: Boolean,
            default: false
        },

        isActive: {
            type: Boolean,
            default: true
        }
    },
    {
        timestamps: true,
        collection: "paymentMethods"
    }
);

const PaymentMethod = mongoose.model(
    "PaymentMethod",
    paymentMethodSchema
);

export default PaymentMethod;