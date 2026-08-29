import Cart from "../models/cartModel.js";
import Product from "../models/productModel.js";

// ===================================
// GET USER CART
// ===================================

export const getCart = async (req, res) => {

    try {

        // ===================================
        // FIND CART
        // ===================================

        let cart = await Cart.findOne({

            userId: req.user.id

        }).populate(
            "items.productId"
        );

        // ===================================
        // CREATE CART IF IT DOES NOT EXIST
        // ===================================

        if (!cart) {

            cart = new Cart({

                userId: req.user.id,

                items: []

            });

            await cart.save();

            cart = await Cart.findById(
                cart._id
            ).populate(
                "items.productId"
            );

        }

        // ===================================
        // CALCULATE SUBTOTAL
        // ===================================

        let subtotal = 0;

        cart.items.forEach(item => {

            if (item.productId) {

                subtotal +=
                    item.productId.price *
                    item.quantity;

            }

        });

        return res.status(200).json({

            message:
                "Cart retrieved successfully",

            cart,

            subtotal

        });

    } catch (error) {

        console.error(
            "Get cart error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving cart",

            error:
                error.message

        });

    }

};


// ===================================
// ADD PRODUCT TO CART
// ===================================

export const addToCart = async (req, res) => {

    try {

        const {
            productId,
            quantity
        } = req.body;

        // ===================================
        // VALIDATE DATA
        // ===================================

        if (!productId) {

            return res.status(400).json({

                message:
                    "Product ID is required"

            });

        }

        const productQuantity =
            quantity || 1;

        if (
            !Number.isInteger(productQuantity) ||
            productQuantity < 1
        ) {

            return res.status(400).json({

                message:
                    "Quantity must be a positive integer"

            });

        }

        // ===================================
        // FIND PRODUCT
        // ===================================

        const product =
            await Product.findById(
                productId
            );

        if (!product) {

            return res.status(404).json({

                message:
                    "Product not found"

            });

        }

        // ===================================
        // CHECK PRODUCT AVAILABILITY
        // ===================================

        if (!product.isAvailable) {

            return res.status(400).json({

                message:
                    "Product is currently unavailable"

            });

        }

        // ===================================
        // FIND CART
        // ===================================

        let cart =
            await Cart.findOne({

                userId: req.user.id

            });

        // ===================================
        // CREATE CART
        // ===================================

        if (!cart) {

            cart = new Cart({

                userId: req.user.id,

                items: [

                    {
                        productId,
                        quantity:
                            productQuantity
                    }

                ]

            });

        } else {

            // ===================================
            // CHECK EXISTING PRODUCT
            // ===================================

            const existingItem =
                cart.items.find(

                    item =>
                        item.productId.toString() ===
                        productId.toString()

                );

            if (existingItem) {

                existingItem.quantity +=
                    productQuantity;

            } else {

                cart.items.push({

                    productId,

                    quantity:
                        productQuantity

                });

            }

        }

        await cart.save();

        // ===================================
        // POPULATE CART
        // ===================================

        await cart.populate(
            "items.productId"
        );

        return res.status(200).json({

            message:
                "Product added to cart successfully",

            cart

        });

    } catch (error) {

        console.error(
            "Add to cart error:",
            error
        );

        return res.status(500).json({

            message:
                "Error adding product to cart",

            error:
                error.message

        });

    }

};


// ===================================
// UPDATE CART ITEM QUANTITY
// ===================================

export const updateCartItem = async (req, res) => {

    try {

        const {
            quantity
        } = req.body;

        // ===================================
        // VALIDATE QUANTITY
        // ===================================

        if (
            quantity === undefined ||
            !Number.isInteger(quantity) ||
            quantity < 1
        ) {

            return res.status(400).json({

                message:
                    "Quantity must be a positive integer"

            });

        }

        // ===================================
        // FIND CART
        // ===================================

        const cart =
            await Cart.findOne({

                userId: req.user.id

            });

        if (!cart) {

            return res.status(404).json({

                message:
                    "Cart not found"

            });

        }

        // ===================================
        // FIND ITEM
        // ===================================

        const item =
            cart.items.find(

                item =>
                    item.productId.toString() ===
                    req.params.productId

            );

        if (!item) {

            return res.status(404).json({

                message:
                    "Product not found in cart"

            });

        }

        // ===================================
        // UPDATE QUANTITY
        // ===================================

        item.quantity = quantity;

        await cart.save();

        await cart.populate(
            "items.productId"
        );

        return res.status(200).json({

            message:
                "Cart item updated successfully",

            cart

        });

    } catch (error) {

        console.error(
            "Update cart item error:",
            error
        );

        return res.status(500).json({

            message:
                "Error updating cart item",

            error:
                error.message

        });

    }

};


// ===================================
// REMOVE PRODUCT FROM CART
// ===================================

export const removeFromCart = async (req, res) => {

    try {

        const cart =
            await Cart.findOne({

                userId: req.user.id

            });

        if (!cart) {

            return res.status(404).json({

                message:
                    "Cart not found"

            });

        }

        const originalLength =
            cart.items.length;

        cart.items =
            cart.items.filter(

                item =>
                    item.productId.toString() !==
                    req.params.productId

            );

        // ===================================
        // CHECK IF PRODUCT EXISTED
        // ===================================

        if (
            cart.items.length ===
            originalLength
        ) {

            return res.status(404).json({

                message:
                    "Product not found in cart"

            });

        }

        await cart.save();

        await cart.populate(
            "items.productId"
        );

        return res.status(200).json({

            message:
                "Product removed from cart successfully",

            cart

        });

    } catch (error) {

        console.error(
            "Remove from cart error:",
            error
        );

        return res.status(500).json({

            message:
                "Error removing product from cart",

            error:
                error.message

        });

    }

};


// ===================================
// CLEAR CART
// ===================================

export const clearCart = async (req, res) => {

    try {

        const cart =
            await Cart.findOne({

                userId: req.user.id

            });

        if (!cart) {

            return res.status(404).json({

                message:
                    "Cart not found"

            });

        }

        cart.items = [];

        await cart.save();

        return res.status(200).json({

            message:
                "Cart cleared successfully",

            cart

        });

    } catch (error) {

        console.error(
            "Clear cart error:",
            error
        );

        return res.status(500).json({

            message:
                "Error clearing cart",

            error:
                error.message

        });

    }

};