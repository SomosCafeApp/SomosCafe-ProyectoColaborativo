import Product from "../models/productModel.js";
import Category from "../models/categoryModel.js";

<<<<<<< HEAD
// ===================================
// GET ALL PRODUCTS
// ===================================
=======
import {
    deleteCloudinaryImage
} from "../utils/cloudinary.js";

// ===================================
// GET ALL PRODUCTS
// ===================================

>>>>>>> main
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
<<<<<<< HEAD
=======

>>>>>>> main
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
<<<<<<< HEAD
=======

>>>>>>> main
export const createProduct = async (req, res) => {

    try {

        const {
            name,
            description,
            price,
<<<<<<< HEAD
            images,
=======
>>>>>>> main
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
<<<<<<< HEAD
            price === undefined
=======
            price === undefined ||
            price === ""
>>>>>>> main
        ) {

            return res.status(400).json({

                message:
                    "Name and price are required"

            });

        }

        // ===================================
<<<<<<< HEAD
=======
        // VALIDATE IMAGE
        // ===================================

        if (!req.file) {

            return res.status(400).json({

                message:
                    "Product image is required"

            });

        }

        // ===================================
>>>>>>> main
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
<<<<<<< HEAD
=======
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
>>>>>>> main
        // CREATE PRODUCT
        // ===================================

        const newProduct =
            new Product({

<<<<<<< HEAD
                name: name.trim(),
=======
                name:
                    name.trim(),
>>>>>>> main

                description:
                    description
                        ? description.trim()
                        : "",

<<<<<<< HEAD
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
=======
                price:
                    Number(price),

                images: [
                    imageUrl
                ],

                ingredients:
                    processedIngredients,

                rating:
                    processedRating,
>>>>>>> main

                categoryId:
                    categoryId || null,

                isAvailable:
<<<<<<< HEAD
                    isAvailable !== undefined
                        ? isAvailable
                        : true
=======
                    processedAvailability
>>>>>>> main

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

<<<<<<< HEAD
=======
        // ===================================
        // RESPONSE
        // ===================================

>>>>>>> main
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

<<<<<<< HEAD
=======
        // ===================================
        // CLEAN CLOUDINARY IMAGE IF DB FAILS
        // ===================================

        if (req.file?.path) {

            await deleteCloudinaryImage(
                req.file.path
            );

        }

>>>>>>> main
        return res.status(500).json({

            message:
                "Error creating product",

<<<<<<< HEAD
            error: error.message
=======
            error:
                error.message
>>>>>>> main

        });

    }

};

// ===================================
// UPDATE PRODUCT
// ===================================
<<<<<<< HEAD
=======

>>>>>>> main
export const updateProduct = async (req, res) => {

    try {

<<<<<<< HEAD
        const {
            categoryId
=======
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
>>>>>>> main
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

<<<<<<< HEAD
=======
                if (req.file?.path) {

                    await deleteCloudinaryImage(
                        req.file.path
                    );

                }

>>>>>>> main
                return res.status(404).json({

                    message:
                        "Category not found"

                });

            }

            if (!category.isActive) {

<<<<<<< HEAD
=======
                if (req.file?.path) {

                    await deleteCloudinaryImage(
                        req.file.path
                    );

                }

>>>>>>> main
                return res.status(400).json({

                    message:
                        "Selected category is inactive"

                });

            }

        }

        // ===================================
<<<<<<< HEAD
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

=======
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

>>>>>>> main
        return res.status(200).json({

            message:
                "Product updated successfully",

<<<<<<< HEAD
            product:
                updatedProduct
=======
            product
>>>>>>> main

        });

    } catch (error) {

        console.error(
            "Update product error:",
            error
        );

<<<<<<< HEAD
=======
        // If new image was uploaded
        // but update failed, remove it.

        if (req.file?.path) {

            await deleteCloudinaryImage(
                req.file.path
            );

        }

>>>>>>> main
        return res.status(500).json({

            message:
                "Error updating product",

<<<<<<< HEAD
            error: error.message
=======
            error:
                error.message
>>>>>>> main

        });

    }

};

// ===================================
// DELETE PRODUCT
// ===================================
<<<<<<< HEAD
=======

>>>>>>> main
export const deleteProduct = async (req, res) => {

    try {

<<<<<<< HEAD
        const deletedProduct =
            await Product.findByIdAndDelete(
                req.params.id
            );

        if (!deletedProduct) {
=======
        // ===================================
        // FIND PRODUCT
        // ===================================

        const product =
            await Product.findById(
                req.params.id
            );

        if (!product) {
>>>>>>> main

            return res.status(404).json({

                message:
                    "Product not found"

            });

        }

<<<<<<< HEAD
=======
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

>>>>>>> main
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

<<<<<<< HEAD
            error: error.message
=======
            error:
                error.message
>>>>>>> main

        });

    }

};