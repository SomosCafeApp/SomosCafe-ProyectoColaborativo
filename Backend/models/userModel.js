import mongoose from "mongoose";
import bcrypt from "bcryptjs";

const userSchema = new mongoose.Schema(
    {
        name: {
            type: String,
            required: true,
            trim: true
        },

        lastName: {
            type: String,
            required: true,
            trim: true
        },

        email: {
            type: String,
            required: true,
            lowercase: true,
            trim: true,
            unique: true
        },

        password: {
            type: String,
            required: true,
            minlength: 6,
            maxlength: 100
        },

        role: {
            type: String,
            enum: ["ADMIN", "USER"],
            default: "USER"
        },

        phone: {
            type: String,
            trim: true,
            default: ""
        },

        points: {
            type: Number,
            default: 0,
            min: 0
        },

        profileImage: {
            type: String,
            default: ""
        },

        isActive: {
            type: Boolean,
            default: true
        },

        recoveryCode: {
            type: String,
            default: null
        },

        recoveryCodeExpiration: {
            type: Date,
            default: null
        }
    },
    {
        timestamps: true,
        collection: "users"
    }
);

// ===================================
// ENCRIPTAR PASSWORD
// ===================================
userSchema.pre("save", async function (next) {

    if (!this.isModified("password")) {
        return next();
    }

    try {

        const salt = await bcrypt.genSalt(10);

        this.password = await bcrypt.hash(
            this.password,
            salt
        );

        next();

    } catch (error) {

        next(error);

    }

});

const User = mongoose.model(
    "User",
    userSchema
);

export default User;