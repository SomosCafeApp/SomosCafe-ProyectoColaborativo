import mongoose from "mongoose";

const pointSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true
        },

        orderId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Order",
            default: null
        },

        amount: {
            type: Number,
            required: true
        },

        type: {
            type: String,
            enum: [
                "purchase",
                "bonus",
                "redeemed",
                "adjustment"
            ],
            required: true
        },

        description: {
            type: String,
            trim: true,
            default: ""
        }
    },
    {
        timestamps: true,
        collection: "points"
    }
);

// ===================================
// INDEX USER POINT HISTORY
// ===================================
pointSchema.index({
    userId: 1,
    createdAt: -1
});

const Point = mongoose.model(
    "Point",
    pointSchema
);

export default Point;