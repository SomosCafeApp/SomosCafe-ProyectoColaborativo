import mongoose from "mongoose";

const favoriteSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true
        },

        productId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Product",
            required: true
        }
    },
    {
        timestamps: true,
        collection: "favorites"
    }
);

// ===================================
// PREVENT DUPLICATE FAVORITES
// ===================================
favoriteSchema.index(
    {
        userId: 1,
        productId: 1
    },
    {
        unique: true
    }
);

// ===================================
// FAVORITE MODEL
// ===================================
const Favorite = mongoose.model(
    "Favorite",
    favoriteSchema
);

export default Favorite;