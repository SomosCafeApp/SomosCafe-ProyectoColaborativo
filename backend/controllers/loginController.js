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

        // VALIDATE REQUIRED DATA
        if (!email || !password) {

            return res.status(400).json({

                message:
                    "Email and password are required"

            });

        }

        // FIND USER
        const user = await User.findOne({

            email: email.toLowerCase().trim()

        });

        if (!user) {

            return res.status(404).json({

                message:
                    "User not found"

            });

        }

        // CHECK ACCOUNT STATUS
        if (!user.isActive) {

            return res.status(403).json({

                message:
                    "User account is inactive"

            });

        }

        // COMPARE PASSWORD
        const passwordValid =
            await bcrypt.compare(
                password,
                user.password
            );

        if (!passwordValid) {

            return res.status(401).json({

                message:
                    "Invalid password"

            });

        }

        // GENERATE JWT
        const token = jwt.sign(

            {
                id: user._id,
                email: user.email,
                role: user.role
            },

            process.env.JWT_SECRET,

            {
                expiresIn: "1h"
            }

        );

        // RESPONSE
        return res.status(200).json({

            message:
                "Login successful",

            token,

            user: {

                id: user._id,

                name: user.name,

                lastName: user.lastName,

                email: user.email,

                role: user.role,

                phone: user.phone,

                points: user.points,

                profileImage: user.profileImage,

                isActive: user.isActive

            }

        });

    } catch (error) {

        console.error(
            "Login error:",
            error
        );

        return res.status(500).json({

            message:
                "Error during login",

            error: error.message

        });

    }

};