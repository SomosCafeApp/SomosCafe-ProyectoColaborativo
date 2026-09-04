import "dotenv/config";
import express from "express";
<<<<<<< HEAD
=======
import cors from "cors";
>>>>>>> main

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
<<<<<<< HEAD

const app = express();
=======
import chatRoutes from "./routes/chatRoutes.js";
>>>>>>> main

// ===============================
// DATABASE CONNECTION
// ===============================
<<<<<<< HEAD
=======

>>>>>>> main
conectarDB();

// ===============================
// PORT
// ===============================
<<<<<<< HEAD
const PORT = process.env.PORT || 3000;
=======

const PORT =
    process.env.PORT || 3000;
>>>>>>> main

// ===============================
// MIDDLEWARES
// ===============================
<<<<<<< HEAD
app.use(express.json());
=======

const app = express();

app.use(
    express.json()
);

app.use(
    cors({
        origin: "*"
    })
);
>>>>>>> main

// ===============================
// MAIN ROUTE
// ===============================
<<<<<<< HEAD
app.get("/", (req, res) => {

    res.status(200).json({

        message:
            "Welcome to SomosCafe API"

    });

});
=======

app.get(
    "/",
    (req, res) => {

        res.status(200).json({

            message:
                "Welcome to SomosCafe API"

        });

    }
);
>>>>>>> main

// ===============================
// ROUTES
// ===============================

<<<<<<< HEAD
// USERS
=======
>>>>>>> main
app.use(
    "/api/users",
    userRoutes
);

<<<<<<< HEAD
// LOGIN
=======
>>>>>>> main
app.use(
    "/api/login",
    loginRoutes
);

<<<<<<< HEAD
// PASSWORD RECOVERY
=======
>>>>>>> main
app.use(
    "/api/recovery",
    recoveryRoutes
);

<<<<<<< HEAD
// PRODUCTS
=======
>>>>>>> main
app.use(
    "/api/products",
    productRoutes
);

<<<<<<< HEAD
// CATEGORIES
=======
>>>>>>> main
app.use(
    "/api/categories",
    categoryRoutes
);

<<<<<<< HEAD
// ADDRESSES

=======
>>>>>>> main
app.use(
    "/api/addresses",
    addressRoutes
);

<<<<<<< HEAD
// CART
=======
>>>>>>> main
app.use(
    "/api/cart",
    cartRoutes
);

<<<<<<< HEAD
// EVENTS
=======
>>>>>>> main
app.use(
    "/api/events",
    eventRoutes
);

<<<<<<< HEAD
// FAVORITES
=======
>>>>>>> main
app.use(
    "/api/favorites",
    favoriteRoutes
);

<<<<<<< HEAD
// INVENTORY
=======
>>>>>>> main
app.use(
    "/api/inventory",
    inventoryRoutes
);

<<<<<<< HEAD
// NOTIFICATIONS
=======
>>>>>>> main
app.use(
    "/api/notifications",
    notificationRoutes
);

<<<<<<< HEAD
// ORDERS
=======
>>>>>>> main
app.use(
    "/api/orders",
    orderRoutes
);

<<<<<<< HEAD
// PAYMENT METHODS
=======
>>>>>>> main
app.use(
    "/api/payment-methods",
    paymentMethodRoutes
);

<<<<<<< HEAD
// POINTS
=======
>>>>>>> main
app.use(
    "/api/points",
    pointRoutes
);

<<<<<<< HEAD
// PROMOTIONS
=======
>>>>>>> main
app.use(
    "/api/promotions",
    promotionRoutes
);

<<<<<<< HEAD
// REVIEWS
=======
>>>>>>> main
app.use(
    "/api/reviews",
    reviewsRoutes
);

<<<<<<< HEAD
// EMAIL VERIFICATION
=======
>>>>>>> main
app.use(
    "/api/email-verification",
    emailVerificationRoutes
);

<<<<<<< HEAD
// ===============================
// SERVER
// ===============================
=======
app.use(
    "/api/chat", 
    chatRoutes
);

// ===============================
// SERVER
// ===============================

>>>>>>> main
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