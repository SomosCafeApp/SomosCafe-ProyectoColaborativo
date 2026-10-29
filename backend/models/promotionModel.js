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
        // Fecha en que se anunció a los clientes (null = aún no). La
        // tarea programada anuncia las que empiezan más adelante.
        launchNotifiedAt: {
            type: Date,
            default: null
        },

        isActive: {
            type: Boolean,
            default: true
        },

        // ===================================
        // PROMO OF THE DAY
        // ===================================
        // La que muestra el home. Solo una a la vez (índice parcial
        // único abajo); se cambia con PATCH /:id/promo-of-the-day.
        isPromoOfTheDay: {
            type: Boolean,
            default: false
        }
    },
    {
        timestamps: true,
        collection: "promotions"
    }
);

promotionSchema.index(
    { isPromoOfTheDay: 1 },
    {
        unique: true,
        partialFilterExpression: { isPromoOfTheDay: true }
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