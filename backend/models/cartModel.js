import mongoose from "mongoose";

const customizationSchema = new mongoose.Schema(
    {
        size: { type: String, required: true },
        type: { type: String, required: true },
        milk: { type: String, required: true },
        extraShots: { type: Number, default: 0, min: 0 },
        toppings: { type: [String], default: [] },
        // Porciones por topping: { "Canela": 2 }. Vacío = 1 de cada uno.
        toppingQuantities: { type: mongoose.Schema.Types.Mixed, default: {} },
        syrups: { type: [String], default: [] },
        sweeteners: { type: [String], default: [] },
        // Diseño de latte art ("" = ninguno): Corazón, Hoja o Cisne.
        latteArt: { type: String, default: "" }
    },
    {
        _id: false
    }
);

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
        },

        // ===================================
        // CUSTOMIZATION
        // ===================================
        // Cada línea del carrito es producto + personalización.
        // Su _id (lineId) es lo que usan PUT/DELETE /cart/items/:itemId.

        customization: {
            type: customizationSchema,
            default: undefined
        },

        customizationKey: {
            type: String,
            default: ""
        }

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