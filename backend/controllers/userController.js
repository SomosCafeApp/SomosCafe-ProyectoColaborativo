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
                    "Name, lastName, email and password are required"

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
                    "Invalid email format"

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
                    "Name must contain at least 2 characters"

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
                    "Last name must contain at least 2 characters"

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
                    "Password must contain at least 6 characters"

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
                    "Password must contain at least one number"

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
                    "Password must contain at least one uppercase letter"

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
                    "Password must contain at least one lowercase letter"

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
                    "Password must contain at least one special character"

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
                        "Email is already registered but not verified"

                });

            }

            return res.status(409).json({

                message:
                    "Email is already registered"

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

            isEmailVerified:
                user.isEmailVerified

        };

        // ===================================
        // RESPONSE
        // ===================================

        return res.status(201).json({

            message:
                "User registered successfully. Please verify your email.",

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
                    "Email is already registered"

            });

        }

        return res.status(500).json({

            message:
                "Error registering user",

            error:
                error.message

        });

    }

};