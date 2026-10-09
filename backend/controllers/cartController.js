import Cart from "../models/cartModel.js";
import Product from "../models/productModel.js";

import {
    DEFAULT_CUSTOMIZATION,
    resolveCustomization,
    customizationPrice,
    customizationKey
} from "../utils/customization.js";

import {
    getDiscountResolver,
    promotionSummary
} from "../utils/promotions.js";

// ===================================
// HELPERS
// ===================================

// Convierte el carrito (con productId poblado) en la respuesta que
// consume Flutter. Los precios se calculan aquí, con el precio ACTUAL
// del producto, su promoción vigente y el extra de la personalización:
//   originalUnitPrice = base + personalización        (sin descuento)
//   discountPerUnit   = descuento de la promo sobre el precio base
//   unitPrice         = originalUnitPrice - discountPerUnit
// subtotal = antes de descuento · discount = ahorro · total = a pagar.
const buildCartResponse = (cart, resolver) => {

    let subtotal = 0;
    let discount = 0;

    const items = cart.items
        .filter(item => item.productId)
        .map(item => {

            const customization =
                item.customization
                    ? {
                        size: item.customization.size,
                        type: item.customization.type,
                        milk: item.customization.milk,
                        extraShots: item.customization.extraShots || 0,
                        toppings: [...(item.customization.toppings || [])]
                    }
                    : { ...DEFAULT_CUSTOMIZATION };

            const extra = customizationPrice(customization);
            const originalUnitPrice = item.productId.price + extra;

            const applied =
                resolver(item.productId._id, item.productId.price);

            const discountPerUnit =
                applied ? applied.discountPerUnit : 0;

            const unitPrice = originalUnitPrice - discountPerUnit;
            const lineTotal = unitPrice * item.quantity;

            subtotal += originalUnitPrice * item.quantity;
            discount += discountPerUnit * item.quantity;

            return {
                _id: item._id,
                productId: item.productId,
                quantity: item.quantity,
                // false si el admin ocultó el producto del menú
                // después de que el usuario lo agregó al carrito.
                isAvailable: item.productId.isAvailable !== false,
                customization,
                customizationKey: item.customizationKey,
                customizationPrice: extra,
                originalUnitPrice,
                discountPerUnit,
                promotion: applied
                    ? promotionSummary(applied.promotion)
                    : null,
                unitPrice,
                lineTotal
            };
        });

    return {
        _id: cart._id,
        userId: cart.userId,
        items,
        subtotal,
        discount,
        total: subtotal - discount
    };
};

// Carritos creados antes de existir la personalización no tienen
// customization/_id estable: los normalizamos una sola vez.
const upgradeLegacyItems = async (cart) => {

    const legacy = cart.items.some(item => !item.customization);

    if (!legacy) return;

    cart.items.forEach(item => {
        if (!item.customization) {
            item.customization = { ...DEFAULT_CUSTOMIZATION };
            item.customizationKey = customizationKey(DEFAULT_CUSTOMIZATION);
        }
    });

    await cart.save();
};

// ===================================
// GET USER CART
// ===================================

export const getCart = async (req, res) => {

    try {

        let cart = await Cart.findOne({
            userId: req.user.id
        });

        if (!cart) {
            cart = new Cart({
                userId: req.user.id,
                items: []
            });

            await cart.save();
        }

        await upgradeLegacyItems(cart);

        await cart.populate("items.productId");

        const response = buildCartResponse(
            cart,
            await getDiscountResolver(req.user.id)
        );

        return res.status(200).json({
            message: "Cart retrieved successfully",
            cart: response,
            subtotal: response.subtotal,
            discount: response.discount,
            total: response.total
        });

    } catch (error) {

        console.error("Get cart error:", error);

        return res.status(500).json({
            message: "Error retrieving cart",
            error: error.message
        });

    }

};

// ===================================
// ADD PRODUCT TO CART
// ===================================
// Si ya existe una línea con el mismo producto Y la misma
// personalización, se acumula la cantidad. Si la personalización es
// distinta, se crea una línea nueva.

export const addToCart = async (req, res) => {

    try {

        const {
            productId,
            quantity,
            customization: rawCustomization
        } = req.body;

        if (!productId) {
            return res.status(400).json({
                message: "Product ID is required"
            });
        }

        const productQuantity = quantity || 1;

        if (
            !Number.isInteger(productQuantity) ||
            productQuantity < 1
        ) {
            return res.status(400).json({
                message: "Quantity must be a positive integer"
            });
        }

        const product = await Product
            .findById(productId)
            .populate("categoryId", "name");

        if (!product) {
            return res.status(404).json({
                message: "Product not found"
            });
        }

        if (!product.isAvailable) {
            return res.status(400).json({
                message: "Product is currently unavailable"
            });
        }

        // Postres: se ignora cualquier personalización enviada.
        const { customization, error } =
            resolveCustomization(product, rawCustomization);

        if (error) {
            return res.status(400).json({ message: error });
        }

        const key = customizationKey(customization);

        let cart = await Cart.findOne({
            userId: req.user.id
        });

        if (!cart) {
            cart = new Cart({
                userId: req.user.id,
                items: []
            });
        }

        await upgradeLegacyItems(cart);

        const existingItem = cart.items.find(item =>
            item.productId.toString() === productId.toString() &&
            item.customizationKey === key
        );

        if (existingItem) {
            existingItem.quantity += productQuantity;
        } else {
            cart.items.push({
                productId,
                quantity: productQuantity,
                customization,
                customizationKey: key
            });
        }

        await cart.save();

        await cart.populate("items.productId");

        const response = buildCartResponse(
            cart,
            await getDiscountResolver(req.user.id)
        );

        return res.status(200).json({
            message: "Product added to cart successfully",
            cart: response,
            subtotal: response.subtotal,
            discount: response.discount,
            total: response.total
        });

    } catch (error) {

        console.error("Add to cart error:", error);

        return res.status(500).json({
            message: "Error adding product to cart",
            error: error.message
        });

    }

};

// ===================================
// UPDATE CART LINE QUANTITY
// ===================================

export const updateCartItem = async (req, res) => {

    try {

        const { quantity } = req.body;

        if (
            quantity === undefined ||
            !Number.isInteger(quantity) ||
            quantity < 1
        ) {
            return res.status(400).json({
                message: "Quantity must be a positive integer"
            });
        }

        const cart = await Cart.findOne({
            userId: req.user.id
        });

        if (!cart) {
            return res.status(404).json({
                message: "Cart not found"
            });
        }

        const item = cart.items.id(req.params.itemId);

        if (!item) {
            return res.status(404).json({
                message: "Item not found in cart"
            });
        }

        item.quantity = quantity;

        await cart.save();

        await cart.populate("items.productId");

        const response = buildCartResponse(
            cart,
            await getDiscountResolver(req.user.id)
        );

        return res.status(200).json({
            message: "Cart item updated successfully",
            cart: response,
            subtotal: response.subtotal,
            discount: response.discount,
            total: response.total
        });

    } catch (error) {

        console.error("Update cart item error:", error);

        return res.status(500).json({
            message: "Error updating cart item",
            error: error.message
        });

    }

};

// ===================================
// REMOVE LINE FROM CART
// ===================================

export const removeFromCart = async (req, res) => {

    try {

        const cart = await Cart.findOne({
            userId: req.user.id
        });

        if (!cart) {
            return res.status(404).json({
                message: "Cart not found"
            });
        }

        const item = cart.items.id(req.params.itemId);

        if (!item) {
            return res.status(404).json({
                message: "Item not found in cart"
            });
        }

        item.deleteOne();

        await cart.save();

        await cart.populate("items.productId");

        const response = buildCartResponse(
            cart,
            await getDiscountResolver(req.user.id)
        );

        return res.status(200).json({
            message: "Product removed from cart successfully",
            cart: response,
            subtotal: response.subtotal,
            discount: response.discount,
            total: response.total
        });

    } catch (error) {

        console.error("Remove from cart error:", error);

        return res.status(500).json({
            message: "Error removing product from cart",
            error: error.message
        });

    }

};

// ===================================
// CLEAR CART
// ===================================

export const clearCart = async (req, res) => {

    try {

        const cart = await Cart.findOne({
            userId: req.user.id
        });

        if (!cart) {
            return res.status(404).json({
                message: "Cart not found"
            });
        }

        cart.items = [];

        await cart.save();

        return res.status(200).json({
            message: "Cart cleared successfully",
            cart: {
                _id: cart._id,
                userId: cart.userId,
                items: [],
                subtotal: 0,
                discount: 0,
                total: 0
            }
        });

    } catch (error) {

        console.error("Clear cart error:", error);

        return res.status(500).json({
            message: "Error clearing cart",
            error: error.message
        });

    }

};
