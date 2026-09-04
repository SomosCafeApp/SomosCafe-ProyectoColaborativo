import { Router } from "express";

import {
    verifyToken,
    adminOnly
} from "../middlewares/auth.middleware.js";

import {
    getProducts,
    getProductById,
    createProduct,
    updateProduct,
    deleteProduct
} from "../controllers/productController.js";

<<<<<<< HEAD
=======
import {
    upload
} from "../middlewares/uploadMiddleware.js";

>>>>>>> main
const router = Router();

// ===================================
// PUBLIC ROUTES
// ===================================

<<<<<<< HEAD
=======
// GET ALL PRODUCTS
>>>>>>> main
router.get(
    "/",
    getProducts
);

<<<<<<< HEAD
=======
// GET PRODUCT BY ID
>>>>>>> main
router.get(
    "/:id",
    getProductById
);

// ===================================
// PROTECTED ADMIN ROUTES
// ===================================

<<<<<<< HEAD
=======
// CREATE PRODUCT
>>>>>>> main
router.post(
    "/",
    verifyToken,
    adminOnly,
<<<<<<< HEAD
    createProduct
);

=======
    upload.single("imagen"),
    createProduct
);

// UPDATE PRODUCT
>>>>>>> main
router.put(
    "/:id",
    verifyToken,
    adminOnly,
<<<<<<< HEAD
    updateProduct
);

=======
    upload.single("imagen"),
    updateProduct
);

// DELETE PRODUCT
>>>>>>> main
router.delete(
    "/:id",
    verifyToken,
    adminOnly,
    deleteProduct
);

export default router;