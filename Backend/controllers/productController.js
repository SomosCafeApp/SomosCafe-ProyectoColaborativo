import Product from "../models/productModel.js";
import Category from "../models/categoryModel.js";

import {
    deleteCloudinaryImage
} from "../utils/cloudinary.js";

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
            price === undefined ||
            price === ""
        ) {

            return res.status(400).json({

                message:
                    "Name and price are required"

            });

        }

        // ===================================
        // VALIDATE IMAGE
        // ===================================

        if (!req.file) {

            return res.status(400).json({

                message:
                    "Product image is required"

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
        // PROCESS INGREDIENTS
        // ===================================

        let processedIngredients = [];

        if (ingredients) {

            if (Array.isArray(ingredients)) {

                processedIngredients =
                    ingredients;

            } else {

                try {

                    processedIngredients =
                        JSON.parse(ingredients);

                } catch {

                    processedIngredients =
                        [ingredients];

                }

            }

        }

        // ===================================
        // PROCESS RATING
        // ===================================

        const processedRating =
            rating !== undefined &&
            rating !== ""
                ? Number(rating)
                : 0;

        // ===================================
        // PROCESS AVAILABILITY
        // ===================================

        let processedAvailability = true;

        if (isAvailable !== undefined) {

            processedAvailability =
                isAvailable === true ||
                isAvailable === "true";

        }

        // ===================================
        // CLOUDINARY IMAGE URL
        // ===================================

        const imageUrl =
            req.file.path;

        // ===================================
        // CREATE PRODUCT
        // ===================================

        const newProduct =
            new Product({

                name:
                    name.trim(),

                description:
                    description
                        ? description.trim()
                        : "",

                price:
                    Number(price),

                images: [
                    imageUrl
                ],

                ingredients:
                    processedIngredients,

                rating:
                    processedRating,

                categoryId:
                    categoryId || null,

                isAvailable:
                    processedAvailability

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

        // ===================================
        // RESPONSE
        // ===================================

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

        // ===================================
        // CLEAN CLOUDINARY IMAGE IF DB FAILS
        // ===================================

        if (req.file?.path) {

            await deleteCloudinaryImage(
                req.file.path
            );

        }

        return res.status(500).json({

            message:
                "Error creating product",

            error:
                error.message

        });

    }

};

// ===================================
// UPDATE PRODUCT
// ===================================

export const updateProduct = async (req, res) => {

    try {

        // ===================================
        // FIND PRODUCT
        // ===================================

        const product =
            await Product.findById(
                req.params.id
            );

        if (!product) {

            // If Multer uploaded an image
            // but product doesn't exist,
            // remove the orphan image.

            if (req.file?.path) {

                await deleteCloudinaryImage(
                    req.file.path
                );

            }

            return res.status(404).json({

                message:
                    "Product not found"

            });

        }

        const {
            name,
            description,
            price,
            ingredients,
            rating,
            categoryId,
            isAvailable
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

                if (req.file?.path) {

                    await deleteCloudinaryImage(
                        req.file.path
                    );

                }

                return res.status(404).json({

                    message:
                        "Category not found"

                });

            }

            if (!category.isActive) {

                if (req.file?.path) {

                    await deleteCloudinaryImage(
                        req.file.path
                    );

                }

                return res.status(400).json({

                    message:
                        "Selected category is inactive"

                });

            }

        }

        // ===================================
        // UPDATE BASIC DATA
        // ===================================

        if (name !== undefined) {

            product.name =
                name.trim();

        }

        if (description !== undefined) {

            product.description =
                description.trim();

        }

        if (
            price !== undefined &&
            price !== ""
        ) {

            product.price =
                Number(price);

        }

        if (rating !== undefined) {

            product.rating =
                Number(rating);

        }

        if (categoryId !== undefined) {

            product.categoryId =
                categoryId || null;

        }

        if (isAvailable !== undefined) {

            product.isAvailable =
                isAvailable === true ||
                isAvailable === "true";

        }

        // ===================================
        // UPDATE INGREDIENTS
        // ===================================

        if (ingredients !== undefined) {

            if (Array.isArray(ingredients)) {

                product.ingredients =
                    ingredients;

            } else {

                try {

                    product.ingredients =
                        JSON.parse(ingredients);

                } catch {

                    product.ingredients =
                        [ingredients];

                }

            }

        }

        // ===================================
        // UPDATE IMAGE
        // ===================================

        let oldImage = null;

        if (req.file) {

            oldImage =
                product.images?.[0] || null;

            product.images = [
                req.file.path
            ];

        }

        // ===================================
        // SAVE PRODUCT
        // ===================================

        await product.save();

        // ===================================
        // DELETE OLD CLOUDINARY IMAGE
        // ===================================

        if (oldImage) {

            await deleteCloudinaryImage(
                oldImage
            );

        }

        // ===================================
        // POPULATE CATEGORY
        // ===================================

        await product.populate(
            "categoryId",
            "name description image isActive"
        );

        // ===================================
        // RESPONSE
        // ===================================

        return res.status(200).json({

            message:
                "Product updated successfully",

            product

        });

    } catch (error) {

        console.error(
            "Update product error:",
            error
        );

        // If new image was uploaded
        // but update failed, remove it.

        if (req.file?.path) {

            await deleteCloudinaryImage(
                req.file.path
            );

        }

        return res.status(500).json({

            message:
                "Error updating product",

            error:
                error.message

        });

    }

};

// ===================================
// DELETE PRODUCT
// ===================================

export const deleteProduct = async (req, res) => {

    try {

        // ===================================
        // FIND PRODUCT
        // ===================================

        const product =
            await Product.findById(
                req.params.id
            );

        if (!product) {

            return res.status(404).json({

                message:
                    "Product not found"

            });

        }

        // ===================================
        // SAVE IMAGE URL
        // ===================================

        const imageUrl =
            product.images?.[0] || null;

        // ===================================
        // DELETE PRODUCT FROM DATABASE
        // ===================================

        await Product.findByIdAndDelete(
            req.params.id
        );

        // ===================================
        // DELETE IMAGE FROM CLOUDINARY
        // ===================================

        if (imageUrl) {

            await deleteCloudinaryImage(
                imageUrl
            );

        }

        // ===================================
        // RESPONSE
        // ===================================

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

            error:
                error.message

        });

    }

};