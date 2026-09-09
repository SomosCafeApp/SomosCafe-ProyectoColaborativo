import Order from "../models/orderModel.js";
import Product from "../models/productModel.js";

// ===================================
// GET USER ORDERS
// ===================================
export const getUserOrders = async (req, res) => {

    try {

        const orders = await Order.find({
            userId: req.user.id
        })
            .populate(
                "addressId"
            )
            .sort({
                createdAt: -1
            });

        return res.status(200).json({

            message:
                "User orders retrieved successfully",

            orders

        });

    } catch (error) {

        console.error(
            "Get user orders error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving user orders",

            error: error.message

        });

    }

};

// ===================================
// GET ORDER BY ID
// ===================================
export const getOrderById = async (req, res) => {

    try {

        const order =
            await Order.findById(
                req.params.id
            )
                .populate("addressId")
                .populate("userId");

        if (!order) {

            return res.status(404).json({

                message:
                    "Order not found"

            });

        }

        // USER CAN ONLY SEE THEIR OWN ORDER
        if (
            req.user.role !== "ADMIN" &&
            order.userId._id.toString() !==
            req.user.id.toString()
        ) {

            return res.status(403).json({

                message:
                    "You are not authorized to access this order"

            });

        }

        return res.status(200).json({

            message:
                "Order retrieved successfully",

            order

        });

    } catch (error) {

        console.error(
            "Get order error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving order",

            error: error.message

        });

    }

};

// ===================================
// CREATE ORDER
// ===================================
export const createOrder = async (req, res) => {

    try {

        const {
            addressId,
            items,
            shippingCost,
            discount,
            paymentMethodId,
            notes
        } = req.body;

        // ===================================
        // VALIDATE REQUIRED DATA
        // ===================================

        if (!addressId) {

            return res.status(400).json({

                message:
                    "Address is required"

            });

        }

        if (
            !items ||
            !Array.isArray(items) ||
            items.length === 0
        ) {

            return res.status(400).json({

                message:
                    "Order must contain at least one item"

            });

        }

        // ===================================
        // GET PRODUCTS
        // ===================================

        const productIds =
            items.map(
                item => item.productId
            );

        const products =
            await Product.find({

                _id: {
                    $in: productIds
                }

            });

        // ===================================
        // VALIDATE PRODUCTS
        // ===================================

        if (
            products.length !==
            productIds.length
        ) {

            return res.status(404).json({

                message:
                    "One or more products were not found"

            });

        }

        // ===================================
        // BUILD ORDER ITEMS
        // ===================================

        const orderItems = [];

        let subtotal = 0;

        for (
            const item of items
        ) {

            const product =
                products.find(

                    product =>
                        product._id.toString() ===
                        item.productId.toString()

                );

            if (!product) {

                return res.status(404).json({

                    message:
                        `Product ${item.productId} not found`

                });

            }

            if (!product.isAvailable) {

                return res.status(400).json({

                    message:
                        `Product ${product.name} is not available`

                });

            }

            const quantity =
                Number(item.quantity);

            if (
                !Number.isInteger(quantity) ||
                quantity < 1
            ) {

                return res.status(400).json({

                    message:
                        "Product quantity must be at least 1"

                });

            }

            const itemSubtotal =
                product.price * quantity;

            subtotal += itemSubtotal;

            orderItems.push({

                productId:
                    product._id,

                name:
                    product.name,

                image:
                    product.images?.[0] || "",

                price:
                    product.price,

                quantity,

                subtotal:
                    itemSubtotal

            });

        }

        // ===================================
        // CALCULATE TOTAL
        // ===================================

        const validShippingCost =
            Number(shippingCost) || 0;

        const validDiscount =
            Number(discount) || 0;

        if (
            validShippingCost < 0 ||
            validDiscount < 0
        ) {

            return res.status(400).json({

                message:
                    "Shipping cost and discount cannot be negative"

            });

        }

        const total =
            subtotal +
            validShippingCost -
            validDiscount;

        if (total < 0) {

            return res.status(400).json({

                message:
                    "Order total cannot be negative"

            });

        }

        // ===================================
        // CREATE ORDER
        // ===================================

        const newOrder = new Order({

            userId:
                req.user.id,

            addressId,

            items:
                orderItems,

            subtotal,

            shippingCost:
                validShippingCost,

            discount:
                validDiscount,

            total,

            paymentMethodId:
                paymentMethodId || null,

            notes:
                notes || "",

            status:
                "PENDING",

            paymentStatus:
                "PENDING"

        });

        // ===================================
        // SAVE ORDER
        // ===================================

        const order =
            await newOrder.save();

        return res.status(201).json({

            message:
                "Order created successfully",

            order

        });

    } catch (error) {

        console.error(
            "Create order error:",
            error
        );

        return res.status(500).json({

            message:
                "Error creating order",

            error: error.message

        });

    }

};

// ===================================
// GET ALL ORDERS - ADMIN
// ===================================
export const getAllOrders = async (req, res) => {

    try {

        const orders =
            await Order.find()
                .populate(
                    "userId",
                    "name lastName email phone"
                )
                .populate(
                    "addressId"
                )
                .sort({
                    createdAt: -1
                });

        return res.status(200).json({

            message:
                "All orders retrieved successfully",

            orders

        });

    } catch (error) {

        console.error(
            "Get all orders error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving orders",

            error: error.message

        });

    }

};

// ===================================
// UPDATE ORDER STATUS - ADMIN
// ===================================
export const updateOrderStatus = async (req, res) => {

    try {

        const {
            status
        } = req.body;

        // ===================================
        // VALIDATE STATUS
        // ===================================

        const validStatuses = [

            "PENDING",
            "CONFIRMED",
            "PREPARING",
            "READY",
            "OUT_FOR_DELIVERY",
            "DELIVERED",
            "CANCELLED"

        ];

        if (
            !validStatuses.includes(status)
        ) {

            return res.status(400).json({

                message:
                    "Invalid order status"

            });

        }

        // ===================================
        // FIND ORDER
        // ===================================

        const order =
            await Order.findById(
                req.params.id
            );

        if (!order) {

            return res.status(404).json({

                message:
                    "Order not found"

            });

        }

        // ===================================
        // UPDATE STATUS
        // ===================================

        order.status = status;

        // ===================================
        // DELIVERY DATE
        // ===================================

        if (
            status === "DELIVERED"
        ) {

            order.deliveredAt =
                new Date();

        }

        // ===================================
        // CANCELLATION DATE
        // ===================================

        if (
            status === "CANCELLED"
        ) {

            order.cancelledAt =
                new Date();

        }

        await order.save();

        return res.status(200).json({

            message:
                "Order status updated successfully",

            order

        });

    } catch (error) {

        console.error(
            "Update order status error:",
            error
        );

        return res.status(500).json({

            message:
                "Error updating order status",

            error: error.message

        });

    }

};

// ===================================
// UPDATE PAYMENT STATUS - ADMIN
// ===================================
export const updatePaymentStatus = async (req, res) => {

    try {

        const {
            paymentStatus
        } = req.body;

        const validStatuses = [

            "PENDING",
            "PAID",
            "FAILED",
            "REFUNDED"

        ];

        if (
            !validStatuses.includes(
                paymentStatus
            )
        ) {

            return res.status(400).json({

                message:
                    "Invalid payment status"

            });

        }

        const order =
            await Order.findById(
                req.params.id
            );

        if (!order) {

            return res.status(404).json({

                message:
                    "Order not found"

            });

        }

        order.paymentStatus =
            paymentStatus;

        await order.save();

        return res.status(200).json({

            message:
                "Payment status updated successfully",

            order

        });

    } catch (error) {

        console.error(
            "Update payment status error:",
            error
        );

        return res.status(500).json({

            message:
                "Error updating payment status",

            error: error.message

        });

    }

};

// ===================================
// CANCEL USER ORDER
// ===================================
export const cancelOrder = async (req, res) => {

    try {

        const order =
            await Order.findById(
                req.params.id
            );

        if (!order) {

            return res.status(404).json({

                message:
                    "Order not found"

            });

        }

        // ===================================
        // VERIFY OWNER
        // ===================================

        if (
            order.userId.toString() !==
            req.user.id.toString()
        ) {

            return res.status(403).json({

                message:
                    "You are not authorized to cancel this order"

            });

        }

        // ===================================
        // VALIDATE STATUS
        // ===================================

        if (
            ![
                "PENDING",
                "CONFIRMED"
            ].includes(order.status)
        ) {

            return res.status(400).json({

                message:
                    "This order can no longer be cancelled"

            });

        }

        // ===================================
        // CANCEL
        // ===================================

        order.status =
            "CANCELLED";

        order.cancelledAt =
            new Date();

        await order.save();

        return res.status(200).json({

            message:
                "Order cancelled successfully",

            order

        });

    } catch (error) {

        console.error(
            "Cancel order error:",
            error
        );

        return res.status(500).json({

            message:
                "Error cancelling order",

            error: error.message

        });

    }

};