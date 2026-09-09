import mongoose from "mongoose";

const reviewSchema = new mongoose.Schema(
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
        },

        rating: {
            type: Number,
            required: true,
            min: 1,
            max: 5
        },

        comment: {
            type: String,
            trim: true,
            default: ""
        },

        isVisible: {
            type: Boolean,
            default: true
        }
    },
    {
        timestamps: true,
        collection: "reviews"
    }
);

// ===================================
// PREVENT DUPLICATE USER REVIEW
// ===================================

reviewSchema.index(
    {
        userId: 1,
        productId: 1
    },
    {
        unique: true
    }
);

// ===================================
// PRODUCT REVIEWS INDEX
// ===================================

reviewSchema.index({
    productId: 1,
    createdAt: -1
});

// ===================================
// REVIEW MODEL
// ===================================

const Review = mongoose.model(
    "Review",
    reviewSchema
);

export default Review;