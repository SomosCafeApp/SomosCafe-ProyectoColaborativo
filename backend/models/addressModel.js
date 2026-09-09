import mongoose from "mongoose";

const addressSchema = new mongoose.Schema(
    {

        // ===================================
        // USER
        // ===================================

        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true
        },

        // ===================================
        // ADDRESS NAME
        // ===================================

        label: {
            type: String,
            required: true,
            trim: true
        },

        // ===================================
        // RECIPIENT
        // ===================================

        recipientName: {
            type: String,
            required: true,
            trim: true
        },

        // ===================================
        // PHONE
        // ===================================

        phone: {
            type: String,
            required: true,
            trim: true
        },

        // ===================================
        // ADDRESS
        // ===================================

        address: {
            type: String,
            required: true,
            trim: true
        },

        // ===================================
        // CITY
        // ===================================

        city: {
            type: String,
            required: true,
            trim: true
        },

        // ===================================
        // NEIGHBORHOOD
        // ===================================

        neighborhood: {
            type: String,
            trim: true,
            default: ""
        },

        // ===================================
        // ADDITIONAL INFORMATION
        // ===================================

        additionalInfo: {
            type: String,
            trim: true,
            default: ""
        },

        // ===================================
        // DEFAULT ADDRESS
        // ===================================

        isDefault: {
            type: Boolean,
            default: false
        }

    },
    {
        timestamps: true,
        collection: "addresses"
    }
);

const Address = mongoose.model(
    "Address",
    addressSchema
);

export default Address;