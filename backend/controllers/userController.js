import User from "../models/userModel.js";
import jwt from "jsonwebtoken";

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
            phone,
            verificationToken
        } = req.body;

        // ===================================
        // VALIDATE REQUIRED DATA
        // ===================================

        if (
            !name ||
            !lastName ||
            !email ||
            !password ||
            !verificationToken
        ) {

            return res.status(400).json({

                message:
                    "Name, lastName, email, password and verificationToken are required"

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
        // VALIDATE EMAIL TOKEN
        // ===================================

        let decodedToken;

        try {

            decodedToken =
                jwt.verify(
                    verificationToken,
                    process.env.JWT_SECRET
                );

        } catch (tokenError) {

            return res.status(400).json({

                message:
                    "Invalid or expired email verification token"

            });

        }

        // ===================================
        // VALIDATE TOKEN PURPOSE
        // ===================================

        if (
            decodedToken.purpose !==
            "EMAIL_VERIFICATION"
        ) {

            return res.status(400).json({

                message:
                    "Invalid email verification token"

            });

        }

        // ===================================
        // VALIDATE TOKEN EMAIL
        // ===================================

        if (
            decodedToken.email !==
            normalizedEmail
        ) {

            return res.status(400).json({

                message:
                    "Verification token does not match the email"

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
                    true

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
                user.isActive

        };

        // ===================================
        // RESPONSE
        // ===================================

        return res.status(201).json({

            message:
                "User registered successfully",

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