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

        // Cantidad de reseñas visibles usadas para calcular "rating".
        // Se recalcula automáticamente cada vez que una reseña de este
        // producto se crea, edita, elimina o cambia de visibilidad.
        reviewCount: {
            type: Number,
            default: 0,
            min: 0
        },

        // Cantidad de usuarios que tienen este producto en favoritos.
        // Se mantiene en sincronía desde favoriteController.js.
        favoritesCount: {
            type: Number,
            default: 0,
            min: 0
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