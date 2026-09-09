import mongoose from "mongoose";

const eventSchema = new mongoose.Schema(
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

        image: {
            type: String,
            trim: true,
            default: ""
        },

        location: {
            type: String,
            trim: true,
            default: ""
        },

        startDate: {
            type: Date,
            required: true
        },

        endDate: {
            type: Date,
            required: true
        },

        isActive: {
            type: Boolean,
            default: true
        }
    },
    {
        timestamps: true,
        collection: "events"
    }
);

// ===================================
// VALIDATE EVENT DATES
// ===================================
eventSchema.pre("validate", function () {

    if (
        this.startDate &&
        this.endDate &&
        this.endDate < this.startDate
    ) {

        this.invalidate(
            "endDate",
            "End date cannot be before start date"
        );

    }

});

// ===================================
// EVENT MODEL
// ===================================
const Event = mongoose.model(
    "Event",
    eventSchema
);

export default Event;