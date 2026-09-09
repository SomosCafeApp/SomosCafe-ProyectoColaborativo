import Inventory from "../models/inventoryModel.js";
import Product from "../models/productModel.js";

// ===================================
// GET ALL INVENTORY
// ===================================

export const getInventory = async (req, res) => {

    try {

        const inventory =
            await Inventory.find()
                .populate(
                    "productId",
                    "name price images isAvailable"
                )
                .sort({
                    createdAt: -1
                });

        return res.status(200).json({

            message:
                "Inventory retrieved successfully",

            inventory

        });

    } catch (error) {

        console.error(
            "Get inventory error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving inventory",

            error: error.message

        });

    }

};

// ===================================
// GET INVENTORY BY PRODUCT
// ===================================

export const getInventoryByProduct = async (
    req,
    res
) => {

    try {

        const inventory =
            await Inventory.findOne({

                productId:
                    req.params.productId

            })
            .populate(
                "productId",
                "name price images isAvailable"
            );

        if (!inventory) {

            return res.status(404).json({

                message:
                    "Inventory record not found"

            });

        }

        return res.status(200).json({

            message:
                "Inventory retrieved successfully",

            inventory

        });

    } catch (error) {

        console.error(
            "Get inventory by product error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving inventory",

            error: error.message

        });

    }

};

// ===================================
// CREATE INVENTORY
// ===================================

export const createInventory = async (
    req,
    res
) => {

    try {

        const {
            productId,
            stock,
            minimumStock,
            maximumStock
        } = req.body;

        // ===================================
        // VALIDATE PRODUCT
        // ===================================

        if (!productId) {

            return res.status(400).json({

                message:
                    "Product ID is required"

            });

        }

        // ===================================
        // CHECK PRODUCT EXISTS
        // ===================================

        const product =
            await Product.findById(productId);

        if (!product) {

            return res.status(404).json({

                message:
                    "Product not found"

            });

        }

        // ===================================
        // CHECK EXISTING INVENTORY
        // ===================================

        const existingInventory =
            await Inventory.findOne({

                productId

            });

        if (existingInventory) {

            return res.status(409).json({

                message:
                    "Inventory already exists for this product"

            });

        }

        // ===================================
        // VALIDATE STOCK
        // ===================================

        if (
            stock !== undefined &&
            stock < 0
        ) {

            return res.status(400).json({

                message:
                    "Stock cannot be negative"

            });

        }

        // ===================================
        // VALIDATE MINIMUM STOCK
        // ===================================

        if (
            minimumStock !== undefined &&
            minimumStock < 0
        ) {

            return res.status(400).json({

                message:
                    "Minimum stock cannot be negative"

            });

        }

        // ===================================
        // VALIDATE MAXIMUM STOCK
        // ===================================

        if (
            maximumStock !== undefined &&
            maximumStock < 0
        ) {

            return res.status(400).json({

                message:
                    "Maximum stock cannot be negative"

            });

        }

        // ===================================
        // VALIDATE STOCK LIMITS
        // ===================================

        const finalStock =
            stock !== undefined
                ? stock
                : 0;

        const finalMinimum =
            minimumStock !== undefined
                ? minimumStock
                : 5;

        const finalMaximum =
            maximumStock !== undefined
                ? maximumStock
                : 100;

        if (finalMinimum > finalMaximum) {

            return res.status(400).json({

                message:
                    "Minimum stock cannot be greater than maximum stock"

            });

        }

        if (finalStock > finalMaximum) {

            return res.status(400).json({

                message:
                    "Stock cannot be greater than maximum stock"

            });

        }

        // ===================================
        // CREATE INVENTORY
        // ===================================

        const newInventory =
            new Inventory({

                productId,

                stock: finalStock,

                minimumStock:
                    finalMinimum,

                maximumStock:
                    finalMaximum

            });

        // ===================================
        // SAVE
        // ===================================

        await newInventory.save();

        // ===================================
        // POPULATE PRODUCT
        // ===================================

        await newInventory.populate(
            "productId",
            "name price images isAvailable"
        );

        return res.status(201).json({

            message:
                "Inventory created successfully",

            inventory:
                newInventory

        });

    } catch (error) {

        console.error(
            "Create inventory error:",
            error
        );

        return res.status(500).json({

            message:
                "Error creating inventory",

            error: error.message

        });

    }

};

// ===================================
// UPDATE INVENTORY
// ===================================

export const updateInventory = async (
    req,
    res
) => {

    try {

        const {
            stock,
            minimumStock,
            maximumStock
        } = req.body;

        // ===================================
        // FIND INVENTORY
        // ===================================

        const inventory =
            await Inventory.findOne({

                productId:
                    req.params.productId

            });

        if (!inventory) {

            return res.status(404).json({

                message:
                    "Inventory record not found"

            });

        }

        // ===================================
        // UPDATE VALUES
        // ===================================

        if (stock !== undefined) {

            if (stock < 0) {

                return res.status(400).json({

                    message:
                        "Stock cannot be negative"

                });

            }

            inventory.stock = stock;

        }

        if (minimumStock !== undefined) {

            if (minimumStock < 0) {

                return res.status(400).json({

                    message:
                        "Minimum stock cannot be negative"

                });

            }

            inventory.minimumStock =
                minimumStock;

        }

        if (maximumStock !== undefined) {

            if (maximumStock < 0) {

                return res.status(400).json({

                    message:
                        "Maximum stock cannot be negative"

                });

            }

            inventory.maximumStock =
                maximumStock;

        }

        // ===================================
        // VALIDATE LIMITS
        // ===================================

        if (
            inventory.minimumStock >
            inventory.maximumStock
        ) {

            return res.status(400).json({

                message:
                    "Minimum stock cannot be greater than maximum stock"

            });

        }

        if (
            inventory.stock >
            inventory.maximumStock
        ) {

            return res.status(400).json({

                message:
                    "Stock cannot be greater than maximum stock"

            });

        }

        // ===================================
        // SAVE
        // ===================================

        await inventory.save();

        await inventory.populate(
            "productId",
            "name price images isAvailable"
        );

        return res.status(200).json({

            message:
                "Inventory updated successfully",

            inventory

        });

    } catch (error) {

        console.error(
            "Update inventory error:",
            error
        );

        return res.status(500).json({

            message:
                "Error updating inventory",

            error: error.message

        });

    }

};

// ===================================
// UPDATE STOCK
// ===================================

export const updateStock = async (
    req,
    res
) => {

    try {

        const {
            quantity,
            operation
        } = req.body;

        // ===================================
        // VALIDATE DATA
        // ===================================

        if (
            quantity === undefined ||
            !operation
        ) {

            return res.status(400).json({

                message:
                    "Quantity and operation are required"

            });

        }

        if (quantity <= 0) {

            return res.status(400).json({

                message:
                    "Quantity must be greater than zero"

            });

        }

        if (
            operation !== "ADD" &&
            operation !== "REMOVE"
        ) {

            return res.status(400).json({

                message:
                    "Operation must be ADD or REMOVE"

            });

        }

        // ===================================
        // FIND INVENTORY
        // ===================================

        const inventory =
            await Inventory.findOne({

                productId:
                    req.params.productId

            });

        if (!inventory) {

            return res.status(404).json({

                message:
                    "Inventory record not found"

            });

        }

        // ===================================
        // CALCULATE NEW STOCK
        // ===================================

        let newStock;

        if (operation === "ADD") {

            newStock =
                inventory.stock + quantity;

        } else {

            newStock =
                inventory.stock - quantity;

        }

        // ===================================
        // VALIDATE NEGATIVE STOCK
        // ===================================

        if (newStock < 0) {

            return res.status(400).json({

                message:
                    "Insufficient stock"

            });

        }

        // ===================================
        // VALIDATE MAXIMUM STOCK
        // ===================================

        if (
            newStock >
            inventory.maximumStock
        ) {

            return res.status(400).json({

                message:
                    "Stock cannot exceed maximum stock"

            });

        }

        // ===================================
        // UPDATE STOCK
        // ===================================

        inventory.stock = newStock;

        await inventory.save();

        await inventory.populate(
            "productId",
            "name price images isAvailable"
        );

        return res.status(200).json({

            message:
                operation === "ADD"
                    ? "Stock increased successfully"
                    : "Stock decreased successfully",

            inventory

        });

    } catch (error) {

        console.error(
            "Update stock error:",
            error
        );

        return res.status(500).json({

            message:
                "Error updating stock",

            error: error.message

        });

    }

};

// ===================================
// DELETE INVENTORY
// ===================================

export const deleteInventory = async (
    req,
    res
) => {

    try {

        const deletedInventory =
            await Inventory.findOneAndDelete({

                productId:
                    req.params.productId

            });

        if (!deletedInventory) {

            return res.status(404).json({

                message:
                    "Inventory record not found"

            });

        }

        return res.status(200).json({

            message:
                "Inventory deleted successfully"

        });

    } catch (error) {

        console.error(
            "Delete inventory error:",
            error
        );

        return res.status(500).json({

            message:
                "Error deleting inventory",

            error: error.message

        });

    }

};