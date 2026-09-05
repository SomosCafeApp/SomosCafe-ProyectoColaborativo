import "dotenv/config";
import express from "express";
import cors from "cors";

import { conectarDB } from "./db/db.js";

import userRoutes from "./routes/userRoutes.js";
import loginRoutes from "./routes/loginRoutes.js";
import recoveryRoutes from "./routes/recoveryRoutes.js";
import productRoutes from "./routes/productRoutes.js";
import categoryRoutes from "./routes/categoryRoutes.js";
import addressRoutes from "./routes/addressRoutes.js";
import cartRoutes from "./routes/cartRoutes.js";
import eventRoutes from "./routes/eventRoutes.js";
import favoriteRoutes from "./routes/favoriteRoutes.js";
import inventoryRoutes from "./routes/inventoryRoutes.js";
import notificationRoutes from "./routes/notificationRoutes.js";
import orderRoutes from "./routes/orderRoutes.js";
import paymentMethodRoutes from "./routes/paymentMethodRoutes.js";
import pointRoutes from "./routes/pointsRoutes.js";
import promotionRoutes from "./routes/promotionRoutes.js";
import reviewsRoutes from "./routes/reviewsRoutes.js";
import emailVerificationRoutes from "./routes/emailVerificationRoutes.js";
import chatRoutes from "./routes/chatRoutes.js";

// ===============================
// DATABASE CONNECTION
// ===============================

conectarDB();

// ===============================
// PORT
// ===============================

const PORT =
    process.env.PORT || 3000;

// ===============================
// MIDDLEWARES
// ===============================

const app = express();

app.use(
    express.json()
);

app.use(
    cors({
        origin: "*"
    })
);

// ===============================
// MAIN ROUTE
// ===============================

app.get(
    "/",
    (req, res) => {

        res.status(200).json({

            message:
                "Welcome to SomosCafe API"

        });

    }
);

// ===============================
// ROUTES
// ===============================

app.use(
    "/api/users",
    userRoutes
);

app.use(
    "/api/login",
    loginRoutes
);

app.use(
    "/api/recovery",
    recoveryRoutes
);

app.use(
    "/api/products",
    productRoutes
);

app.use(
    "/api/categories",
    categoryRoutes
);

app.use(
    "/api/addresses",
    addressRoutes
);

app.use(
    "/api/cart",
    cartRoutes
);

app.use(
    "/api/events",
    eventRoutes
);

app.use(
    "/api/favorites",
    favoriteRoutes
);

app.use(
    "/api/inventory",
    inventoryRoutes
);

app.use(
    "/api/notifications",
    notificationRoutes
);

app.use(
    "/api/orders",
    orderRoutes
);

app.use(
    "/api/payment-methods",
    paymentMethodRoutes
);

app.use(
    "/api/points",
    pointRoutes
);

app.use(
    "/api/promotions",
    promotionRoutes
);

app.use(
    "/api/reviews",
    reviewsRoutes
);

app.use(
    "/api/email-verification",
    emailVerificationRoutes
);

app.use(
    "/api/chat", 
    chatRoutes
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