import mongoose from "mongoose";

const inventorySchema = new mongoose.Schema(
    {

        // ===================================
        // PRODUCT REFERENCE
        // ===================================

        productId: {

            type: mongoose.Schema.Types.ObjectId,

            ref: "Product",

            required: true,

            unique: true

        },

        // ===================================
        // CURRENT STOCK
        // ===================================

        stock: {

            type: Number,

            required: true,

            min: 0,

            default: 0

        },

        // ===================================
        // MINIMUM STOCK
        // ===================================

        minimumStock: {

            type: Number,

            required: true,

            min: 0,

            default: 5

        },

        // ===================================
        // MAXIMUM STOCK
        // ===================================

        maximumStock: {

            type: Number,

            required: true,

            min: 0,

            default: 100

        },

        // ===================================
        // INVENTORY STATUS
        // ===================================

        status: {

            type: String,

            enum: [
                "AVAILABLE",
                "LOW_STOCK",
                "OUT_OF_STOCK"
            ],

            default: "AVAILABLE"

        }

    },

    {

        timestamps: true,

        collection: "inventory"

    }

);

// ===================================
// UPDATE INVENTORY STATUS
// ===================================

inventorySchema.pre(
    "save",
    function () {

        if (this.stock === 0) {

            this.status = "OUT_OF_STOCK";

        } else if (
            this.stock <= this.minimumStock
        ) {

            this.status = "LOW_STOCK";

        } else {

            this.status = "AVAILABLE";

        }

    }
);

// ===================================
// INVENTORY MODEL
// ===================================

const Inventory = mongoose.model(
    "Inventory",
    inventorySchema
);

export default Inventory;