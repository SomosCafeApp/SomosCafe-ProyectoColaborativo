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

        // VALIDATE REQUIRED DATA
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

        // VALIDATE PASSWORD LENGTH
        if (password.length < 6) {

            return res.status(400).json({

                message:
                    "Password must contain at least 6 characters"

            });

        }

        // VALIDATE EMAIL FORMAT
        const emailRegex =
            /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!emailRegex.test(email)) {

            return res.status(400).json({

                message:
                    "Invalid email format"

            });

        }

        // CHECK IF EMAIL ALREADY EXISTS
        const existingUser = await User.findOne({

            email: email.toLowerCase()

        });

        if (existingUser) {

            return res.status(409).json({

                message:
                    "Email is already registered"

            });

        }

        // CREATE USER
        const newUser = new User({

            name: name.trim(),

            lastName: lastName.trim(),

            email: email.toLowerCase().trim(),

            password,

            phone: phone
                ? phone.trim()
                : "",

            role: "USER",

            points: 0,

            profileImage: "",

            isActive: true

        });

        // SAVE USER
        const user = await newUser.save();

        // USER RESPONSE
        const userResponse = {

            id: user._id,

            name: user.name,

            lastName: user.lastName,

            email: user.email,

            role: user.role,

            phone: user.phone,

            points: user.points,

            profileImage: user.profileImage,

            isActive: user.isActive

        };

        // RESPONSE
        return res.status(201).json({

            message:
                "User registered successfully",

            user: userResponse

        });

    } catch (error) {

        console.error(
            "Register error:",
            error
        );

        return res.status(500).json({

            message:
                "Error registering user",

            error: error.message

        });

    }

};