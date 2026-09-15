import mongoose from "mongoose";

const productSchema = new mongoose.Schema(
    {
        name: {
            type: String,
            required: true,
            trim: true
        },

        description: {
            type: String,
            trim: true,
            default: ""
        },

        price: {
            type: Number,
            required: true,
            min: 0
        },

        images: {
            type: [String],
            default: []
        },

        ingredients: {
            type: [String],
            default: []
        },

        rating: {
            type: Number,
            default: 0,
            min: 0,
            max: 5
        },

        categoryId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Category",
            default: null
        },

        isAvailable: {
            type: Boolean,
            default: true
        }
    },
    {
        timestamps: true,
        collection: "products"
    }
);

const Product = mongoose.model(
    "Product",
    productSchema
);

export default Product;