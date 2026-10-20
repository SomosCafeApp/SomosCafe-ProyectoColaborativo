import { formatBirthDate } from "../utils/userFormat.js";
import User from "../models/userModel.js";

// ===================================
// REGISTER USER
// ===================================

export const registerUser = async (req, res) => {

    try {

        const {
            name,
            lastName,
            email,
            password,
            phone
        } = req.body;

        // ===================================
        // VALIDATE REQUIRED DATA
        // ===================================

        if (
            !name ||
            !lastName ||
            !email ||
            !password
        ) {

            return res.status(400).json({

                message:
                    "Name, lastName, email y password son obligatorios"

            });

        }

        // ===================================
        // NORMALIZE EMAIL
        // ===================================

        const normalizedEmail =
            email
                .trim()
                .toLowerCase();

        // ===================================
        // VALIDATE EMAIL FORMAT
        // ===================================

        const emailRegex =
            /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (
            !emailRegex.test(
                normalizedEmail
            )
        ) {

            return res.status(400).json({

                message:
                    "Formato de correo inválido"

            });

        }

        // ===================================
        // VALIDATE NAME
        // ===================================

        if (
            name.trim().length < 2
        ) {

            return res.status(400).json({

                message:
                    "El nombre debe tener al menos 2 caracteres"

            });

        }

        // ===================================
        // VALIDATE LAST NAME
        // ===================================

        if (
            lastName.trim().length < 2
        ) {

            return res.status(400).json({

                message:
                    "El apellido debe tener al menos 2 caracteres"

            });

        }

        // ===================================
        // VALIDATE PASSWORD LENGTH
        // ===================================

        if (
            password.length < 6
        ) {

            return res.status(400).json({

                message:
                    "La contraseña debe tener al menos 6 caracteres"

            });

        }

        // ===================================
        // VALIDATE PASSWORD NUMBER
        // ===================================

        if (
            !/[0-9]/.test(password)
        ) {

            return res.status(400).json({

                message:
                    "La contraseña debe contener al menos un número"

            });

        }

        // ===================================
        // VALIDATE PASSWORD UPPERCASE
        // ===================================

        if (
            !/[A-Z]/.test(password)
        ) {

            return res.status(400).json({

                message:
                    "La contraseña debe contener al menos una letra mayúscula"

            });

        }

        // ===================================
        // VALIDATE PASSWORD LOWERCASE
        // ===================================

        if (
            !/[a-z]/.test(password)
        ) {

            return res.status(400).json({

                message:
                    "La contraseña debe contener al menos una letra minúscula"

            });

        }

        // ===================================
        // VALIDATE PASSWORD SPECIAL CHARACTER
        // ===================================

        if (
            !/[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]/
                .test(password)
        ) {

            return res.status(400).json({

                message:
                    "La contraseña debe contener al menos un carácter especial"

            });

        }

        // ===================================
        // CHECK IF EMAIL ALREADY EXISTS
        // ===================================

        const existingUser =
            await User.findOne({

                email:
                    normalizedEmail

            });

        if (existingUser) {

            // Permitir volver a registrarse solamente
            // si existe una cuenta pendiente de verificación.
            if (
                !existingUser.isEmailVerified
            ) {

                return res.status(409).json({

                    message:
                        "El correo ya está registrado pero no ha sido verificado"

                });

            }

            return res.status(409).json({

                message:
                    "El correo ya está registrado"

            });

        }

        // ===================================
        // CREATE USER
        // ===================================

        const newUser =
            new User({

                name:
                    name.trim(),

                lastName:
                    lastName.trim(),

                email:
                    normalizedEmail,

                password,

                phone:
                    phone
                        ? phone.trim()
                        : "",

                role:
                    "USER",

                points:
                    0,

                profileImage:
                    "",

                isActive:
                    true,

                isEmailVerified:
                    false

            });

        // ===================================
        // SAVE USER
        // ===================================

        const user =
            await newUser.save();

        // ===================================
        // USER RESPONSE
        // ===================================

        const userResponse = {

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

        };

        // ===================================
        // RESPONSE
        // ===================================

        return res.status(201).json({

            message:
                "Usuario registrado correctamente. Verifica tu correo.",

            user:
                userResponse

        });

    } catch (error) {

        console.error(
            "Register error:",
            error
        );

        // ===================================
        // DUPLICATE EMAIL
        // ===================================

        if (
            error.code === 11000
        ) {

            return res.status(409).json({

                message:
                    "El correo ya está registrado"

            });

        }

        return res.status(500).json({

            message:
                "Error al registrar el usuario",

            error:
                error.message

        });

    }

};