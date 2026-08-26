import "dotenv/config";
import express from "express";

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

// CATEGORIES
app.use(
    "/api/categories",
    categoryRoutes
);

// ADDRESSES

app.use(
    "/api/addresses",
    addressRoutes
);

// CART
app.use(
    "/api/cart",
    cartRoutes
);

// EVENTS
app.use(
    "/api/events",
    eventRoutes
);

// FAVORITES
app.use(
    "/api/favorites",
    favoriteRoutes
);

// INVENTORY
app.use(
    "/api/inventory",
    inventoryRoutes
);

// NOTIFICATIONS
app.use(
    "/api/notifications",
    notificationRoutes
);

// ORDERS
app.use(
    "/api/orders",
    orderRoutes
);

// PAYMENT METHODS
app.use(
    "/api/payment-methods",
    paymentMethodRoutes
);

// POINTS
app.use(
    "/api/points",
    pointRoutes
);

// PROMOTIONS
app.use(
    "/api/promotions",
    promotionRoutes
);

// REVIEWS
app.use(
    "/api/reviews",
    reviewsRoutes
);

// EMAIL VERIFICATION
app.use(
    "/api/email-verification",
    emailVerificationRoutes
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