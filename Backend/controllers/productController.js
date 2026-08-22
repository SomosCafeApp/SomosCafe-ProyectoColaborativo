import Product from "../models/productModel.js";
import Category from "../models/categoryModel.js";

// ===================================
// GET ALL PRODUCTS
// ===================================
export const getProducts = async (req, res) => {

    try {

        const products =
            await Product.find()
                .populate(
                    "categoryId",
                    "name description image isActive"
                )
                .sort({
                    createdAt: -1
                });

        return res.status(200).json({

            message:
                "Products retrieved successfully",

            products

        });

    } catch (error) {

        console.error(
            "Get products error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving products",

            error: error.message

        });

    }

};

// ===================================
// GET PRODUCT BY ID
// ===================================
export const getProductById = async (req, res) => {

    try {

        const product =
            await Product.findById(
                req.params.id
            )
            .populate(
                "categoryId",
                "name description image isActive"
            );

        if (!product) {

            return res.status(404).json({

                message:
                    "Product not found"

            });

        }

        return res.status(200).json({

            message:
                "Product retrieved successfully",

            product

        });

    } catch (error) {

        console.error(
            "Get product error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving product",

            error: error.message

        });

    }

};

// ===================================
// CREATE PRODUCT
// ===================================
export const createProduct = async (req, res) => {

    try {

        const {
            name,
            description,
            price,
            images,
            ingredients,
            rating,
            categoryId,
            isAvailable
        } = req.body;

        // ===================================
        // VALIDATE REQUIRED DATA
        // ===================================

        if (
            !name ||
            price === undefined
        ) {

            return res.status(400).json({

                message:
                    "Name and price are required"

            });

        }

        // ===================================
        // VALIDATE CATEGORY
        // ===================================

        if (categoryId) {

            const category =
                await Category.findById(
                    categoryId
                );

            if (!category) {

                return res.status(404).json({

                    message:
                        "Category not found"

                });

            }

            if (!category.isActive) {

                return res.status(400).json({

                    message:
                        "Selected category is inactive"

                });

            }

        }

        // ===================================
        // CREATE PRODUCT
        // ===================================

        const newProduct =
            new Product({

                name: name.trim(),

                description:
                    description
                        ? description.trim()
                        : "",

                price,

                images:
                    Array.isArray(images)
                        ? images
                        : [],

                ingredients:
                    Array.isArray(ingredients)
                        ? ingredients
                        : [],

                rating:
                    rating !== undefined
                        ? rating
                        : 0,

                categoryId:
                    categoryId || null,

                isAvailable:
                    isAvailable !== undefined
                        ? isAvailable
                        : true

            });

        // ===================================
        // SAVE PRODUCT
        // ===================================

        await newProduct.save();

        // ===================================
        // POPULATE CATEGORY
        // ===================================

        await newProduct.populate(
            "categoryId",
            "name description image isActive"
        );

        return res.status(201).json({

            message:
                "Product created successfully",

            product:
                newProduct

        });

    } catch (error) {

        console.error(
            "Create product error:",
            error
        );

        return res.status(500).json({

            message:
                "Error creating product",

            error: error.message

        });

    }

};

// ===================================
// UPDATE PRODUCT
// ===================================
export const updateProduct = async (req, res) => {

    try {

        const {
            categoryId
        } = req.body;

        // ===================================
        // VALIDATE CATEGORY
        // ===================================

        if (categoryId) {

            const category =
                await Category.findById(
                    categoryId
                );

            if (!category) {

                return res.status(404).json({

                    message:
                        "Category not found"

                });

            }

            if (!category.isActive) {

                return res.status(400).json({

                    message:
                        "Selected category is inactive"

                });

            }

        }

        // ===================================
        // UPDATE PRODUCT
        // ===================================

        const updatedProduct =
            await Product.findByIdAndUpdate(

                req.params.id,

                req.body,

                {
                    new: true,
                    runValidators: true
                }

            )
            .populate(
                "categoryId",
                "name description image isActive"
            );

        if (!updatedProduct) {

            return res.status(404).json({

                message:
                    "Product not found"

            });

        }

        return res.status(200).json({

            message:
                "Product updated successfully",

            product:
                updatedProduct

        });

    } catch (error) {

        console.error(
            "Update product error:",
            error
        );

        return res.status(500).json({

            message:
                "Error updating product",

            error: error.message

        });

    }

};

// ===================================
// DELETE PRODUCT
// ===================================
export const deleteProduct = async (req, res) => {

    try {

        const deletedProduct =
            await Product.findByIdAndDelete(
                req.params.id
            );

        if (!deletedProduct) {

            return res.status(404).json({

                message:
                    "Product not found"

            });

        }

        return res.status(200).json({

            message:
                "Product deleted successfully"

        });

    } catch (error) {

        console.error(
            "Delete product error:",
            error
        );

        return res.status(500).json({

            message:
                "Error deleting product",

            error: error.message

        });

    }

};