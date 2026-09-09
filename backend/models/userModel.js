import mongoose from "mongoose";
import bcrypt from "bcryptjs";

const userSchema = new mongoose.Schema(
    {
        // ===================================
        // INFORMACIÓN PERSONAL
        // ===================================

        name: {
            type: String,
            required: true,
            trim: true
        },

        lastName: {
            type: String,
            trim: true,
            default: ""
        },

        email: {
            type: String,
            required: true,
            lowercase: true,
            trim: true,
            unique: true
        },

        phone: {
            type: String,
            trim: true,
            default: ""
        },

        // ===================================
        // AUTENTICACIÓN TRADICIONAL
        // ===================================

        // La contraseña no es obligatoria porque
        // los usuarios de Google pueden no tenerla.
        password: {
            type: String,
            minlength: 6,
            maxlength: 100,
            default: null
        },

        // ===================================
        // AUTENTICACIÓN CON GOOGLE
        // ===================================

        // Índice sparse para permitir que los usuarios
        // tradicionales no tengan este campo.
        googleId: {
            type: String,
            unique: true,
            sparse: true,
            default: null
        },

        // Imagen de perfil del usuario.
        profileImage: {
            type: String,
            default: ""
        },

        // ===================================
        // INFORMACIÓN DEL USUARIO
        // ===================================

        role: {
            type: String,
            enum: ["ADMIN", "USER"],
            default: "USER"
        },

        points: {
            type: Number,
            default: 0,
            min: 0
        },

        isActive: {
            type: Boolean,
            default: true
        },

        // ===================================
        // RECUPERACIÓN DE CONTRASEÑA
        // ===================================

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
// HASH DE CONTRASEÑA
// ===================================

userSchema.pre("save", async function () {

    // No intentar encriptar una contraseña
    // que no existe.
    if (!this.password) {
        return;
    }

    // No volver a encriptar una contraseña
    // que ya fue almacenada.
    if (!this.isModified("password")) {
        return;
    }

    // Generar salt.
    const salt = await bcrypt.genSalt(10);

    // Encriptar contraseña.
    this.password = await bcrypt.hash(
        this.password,
        salt
    );

});

// ===================================
// USER MODEL
// ===================================

const User = mongoose.model(
    "User",
    userSchema
);

export default User;