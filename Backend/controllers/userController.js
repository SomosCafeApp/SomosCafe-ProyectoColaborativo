import User from "../models/userModel.js";

// ===================================
// REGISTRAR USUARIO
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

        // VALIDAR DATOS
        if (
            !name ||
            !lastName ||
            !email ||
            !password
        ) {

            return res.status(400).json({
                message: "Name, lastName, email and password are required"
            });

        }

        // VALIDAR PASSWORD
        if (password.length < 6) {

            return res.status(400).json({
                message: "Password must contain at least 6 characters"
            });

        }

        // VALIDAR CORREO
        const emailRegex =
            /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!emailRegex.test(email)) {

            return res.status(400).json({
                message: "Invalid email format"
            });

        }

        // VERIFICAR CORREO
        const existingUser = await User.findOne({
            email: email.toLowerCase()
        });

        if (existingUser) {

            return res.status(409).json({
                message: "Email is already registered"
            });

        }

        // CREAR USUARIO
        const newUser = new User({

            name,
            lastName,
            email: email.toLowerCase(),
            password,
            phone: phone || "",
            role: "USER",
            points: 0,
            profileImage: "",
            isActive: true

        });

        // GUARDAR
        const user = await newUser.save();

        // RESPUESTA
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

        return res.status(201).json({

            message: "User registered successfully",

            user: userResponse

        });

    } catch (error) {

        console.error(error);

        return res.status(500).json({

            message: "Error registering user",

            error: error.message

        });

    }

};