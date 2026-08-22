import express from "express";

import {
    verifyToken
} from "../middlewares/auth.middleware.js";

import {
    createAddress,
    getAddresses,
    getAddressById,
    updateAddress,
    deleteAddress,
    setDefaultAddress
} from "../controllers/addressController.js";

const router = express.Router();

// ===================================
// PROTECTED ADDRESS ROUTES
// ===================================

// CREATE ADDRESS

router.post(
    "/",
    verifyToken,
    createAddress
);

// GET USER ADDRESSES

router.get(
    "/",
    verifyToken,
    getAddresses
);

// GET ADDRESS BY ID

router.get(
    "/:id",
    verifyToken,
    getAddressById
);

// UPDATE ADDRESS

router.put(
    "/:id",
    verifyToken,
    updateAddress
);

// DELETE ADDRESS

router.delete(
    "/:id",
    verifyToken,
    deleteAddress
);

// SET DEFAULT ADDRESS

router.patch(
    "/:id/default",
    verifyToken,
    setDefaultAddress
);

export default router;