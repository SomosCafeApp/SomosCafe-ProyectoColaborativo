import mongoose from "mongoose";

const cartItemSchema = new mongoose.Schema(
    {

        // ===================================
        // PRODUCT
        // ===================================

        productId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Product",
            required: true
        },

        // ===================================
        // QUANTITY
        // ===================================

        quantity: {
            type: Number,
            required: true,
            min: 1
        }

    },
    {
        _id: false
    }
);

const cartSchema = new mongoose.Schema(
    {

        // ===================================
        // USER
        // ===================================

        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
            unique: true
        },

        // ===================================
        // CART ITEMS
        // ===================================

        items: {
            type: [cartItemSchema],
            default: []
        }

    },
    {
        timestamps: true,
        collection: "cart"
    }
);

const Cart = mongoose.model(
    "Cart",
    cartSchema
);

export default Cart;