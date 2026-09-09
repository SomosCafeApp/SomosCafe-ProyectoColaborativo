import mongoose from "mongoose";

const promotionSchema = new mongoose.Schema(
    {
        // ===================================
        // PROMOTION CODE
        // ===================================
        code: {
            type: String,
            required: true,
            unique: true,
            uppercase: true,
            trim: true
        },

        // ===================================
        // PROMOTION NAME
        // ===================================
        name: {
            type: String,
            required: true,
            trim: true
        },

        // ===================================
        // DESCRIPTION
        // ===================================
        description: {
            type: String,
            trim: true,
            default: ""
        },

        // ===================================
        // DISCOUNT TYPE
        // ===================================
        discountType: {
            type: String,
            enum: [
                "percentage",
                "fixed"
            ],
            required: true
        },

        // ===================================
        // DISCOUNT VALUE
        // ===================================
        discountValue: {
            type: Number,
            required: true,
            min: 0
        },

        // ===================================
        // MINIMUM PURCHASE
        // ===================================
        minimumPurchase: {
            type: Number,
            default: 0,
            min: 0
        },

        // ===================================
        // MAXIMUM DISCOUNT
        // ===================================
        maximumDiscount: {
            type: Number,
            default: null,
            min: 0
        },

        // ===================================
        // SPECIFIC PRODUCTS
        // ===================================
        productIds: [
            {
                type: mongoose.Schema.Types.ObjectId,
                ref: "Product"
            }
        ],

        // ===================================
        // SPECIFIC USERS
        // ===================================
        userIds: [
            {
                type: mongoose.Schema.Types.ObjectId,
                ref: "User"
            }
        ],

        // ===================================
        // USAGE LIMIT
        // ===================================
        usageLimit: {
            type: Number,
            default: null,
            min: 0
        },

        // ===================================
        // CURRENT USAGE
        // ===================================
        usageCount: {
            type: Number,
            default: 0,
            min: 0
        },

        // ===================================
        // START DATE
        // ===================================
        startDate: {
            type: Date,
            required: true
        },

        // ===================================
        // END DATE
        // ===================================
        endDate: {
            type: Date,
            required: true
        },

        // ===================================
        // ACTIVE STATUS
        // ===================================
        isActive: {
            type: Boolean,
            default: true
        }
    },
    {
        timestamps: true,
        collection: "promotions"
    }
);

// ===================================
// PROMOTION MODEL
// ===================================
const Promotion = mongoose.model(
    "Promotion",
    promotionSchema
);

export default Promotion;