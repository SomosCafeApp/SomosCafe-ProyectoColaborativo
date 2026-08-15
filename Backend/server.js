import "dotenv/config";
import express from "express";

import { conectarDB } from "./db/db.js";

import userRoutes from "./routes/userRoutes.js";
import loginRoutes from "./routes/loginRoutes.js";
import recoveryRoutes from "./routes/recoveryRoutes.js";
import productRoutes from "./routes/productRoutes.js";

const app = express();

// ===============================
// DATABASE CONNECTION
// ===============================
conectarDB();

// ===============================
// PORT
// ===============================
const PORT = process.env.PORT || 3000;

// ===============================
// MIDDLEWARES
// ===============================
app.use(express.json());

// ===============================
// MAIN ROUTE
// ===============================
app.get("/", (req, res) => {

    res.status(200).json({

        message:
            "Welcome to SomosCafe API"

    });

});

// ===============================
// ROUTES
// ===============================

// USERS
app.use(
    "/api/users",
    userRoutes
);

// LOGIN
app.use(
    "/api/login",
    loginRoutes
);

// PASSWORD RECOVERY
app.use(
    "/api/recovery",
    recoveryRoutes
);

// PRODUCTS
app.use(
    "/api/products",
    productRoutes
);

// ===============================
// SERVER
// ===============================
app.listen(
    PORT,
    () => {

        console.log(
            `🚀 Server running on port ${PORT}`
        );

        console.log(
            `🌐 http://localhost:${PORT}`
        );

    }
);