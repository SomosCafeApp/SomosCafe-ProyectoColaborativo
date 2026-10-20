import { formatBirthDate } from "../utils/userFormat.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

import User from "../models/userModel.js";

// ===================================
// LOGIN USER
// ===================================

export const loginUser = async (req, res) => {

    try {

        const {
            email,
            password
        } = req.body;

        // ===================================
        // VALIDATE REQUIRED DATA
        // ===================================

        if (
            !email ||
            !password
        ) {

            return res.status(400).json({

                message:
                    "El correo y la contraseña son obligatorios"

            });

        }

        // ===================================
        // NORMALIZE EMAIL
        // ===================================

        const normalizedEmail =
            email
                .toLowerCase()
                .trim();

        // ===================================
        // FIND USER
        // ===================================

        const user =
            await User.findOne({

                email:
                    normalizedEmail

            });

        if (!user) {

            return res.status(404).json({

                message:
                    "Usuario no encontrado"

            });

        }

        // ===================================
        // CHECK ACCOUNT STATUS
        // ===================================

        if (
            !user.isActive
        ) {

            return res.status(403).json({

                message:
                    "La cuenta de usuario está inactiva"

            });

        }

        // ===================================
        // CHECK EMAIL VERIFICATION
        // ===================================

        // Google accounts are already authenticated
        // through Google and do not need the
        // traditional email verification flow.
        if (
            !user.isEmailVerified &&
            !user.googleId
        ) {

            return res.status(403).json({

                message:
                    "Verifica tu correo antes de iniciar sesión"

            });

        }

        // ===================================
        // CHECK PASSWORD
        // ===================================

        if (
            !user.password
        ) {

            return res.status(401).json({

                message:
                    "Esta cuenta no tiene contraseña. Inicia sesión con Google."

            });

        }

        // ===================================
        // COMPARE PASSWORD
        // ===================================

        const passwordValid =
            await bcrypt.compare(

                password,

                user.password

            );

        if (!passwordValid) {

            return res.status(401).json({

                message:
                    "Contraseña incorrecta"

            });

        }

        // ===================================
        // GENERATE JWT
        // ===================================

        const token =
            jwt.sign(

                {
                    id:
                        user._id,

                    userId:
                        user._id,

                    email:
                        user.email,

                    role:
                        user.role
                },

                process.env.JWT_SECRET,

                {
                    expiresIn:
                        "1h"
                }

            );

        // ===================================
        // RESPONSE
        // ===================================

        return res.status(200).json({

            message:
                "Inicio de sesión exitoso",

            token,

            user: {

                id:
                    user._id,

                name:
                    user.name,

                lastName:
                    user.lastName,

                email:
                    user.email,

                role:
                    user.role,

                phone:
                    user.phone,

                points:
                    user.points,

                profileImage:
                    user.profileImage,

                isActive:
                    user.isActive,

                hasPassword:
                    Boolean(user.password),

                birthDate:
                    formatBirthDate(user.birthDate),

                isEmailVerified:
                    user.isEmailVerified

            }

        });

    } catch (error) {

        console.error(

            "Login error:",

            error

        );

        return res.status(500).json({

            message:
                "Error durante el inicio de sesión",

            error:
                error.message

        });

    }

};