import Product from "../models/productModel.js";

// ===================================
// GET ALL PRODUCTS
// ===================================
export const getProducts = async (req, res) => {

    try {

        const products = await Product.find()
            .sort({
                createdAt: -1
            });

        return res.status(200).json({

            message: "Products retrieved successfully",

            products

        });

    } catch (error) {

        return res.status(500).json({

            message: "Error retrieving products",

            error: error.message

        });

    }

};

// ===================================
// GET PRODUCT BY ID
// ===================================
export const getProductById = async (req, res) => {

    try {

        const product = await Product.findById(
            req.params.id
        );

        if (!product) {

            return res.status(404).json({

                message: "Product not found"

            });

        }

        return res.status(200).json({

            message: "Product retrieved successfully",

            product

        });

    } catch (error) {

        return res.status(500).json({

            message: "Error retrieving product",

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

        // VALIDATE REQUIRED DATA
        if (
            !name ||
            price === undefined
        ) {

            return res.status(400).json({

                message: "Name and price are required"

            });

        }

        // CREATE PRODUCT
        const newProduct = new Product({

            name,
            description: description || "",
            price,
            images: images || [],
            ingredients: ingredients || [],
            rating: rating || 0,
            categoryId: categoryId || null,
            isAvailable:
                isAvailable !== undefined
                    ? isAvailable
                    : true

        });

        // SAVE
        await newProduct.save();

        return res.status(201).json({

            message: "Product created successfully",

            product: newProduct

        });

    } catch (error) {

        return res.status(500).json({

            message: "Error creating product",

            error: error.message

        });

    }

};

// ===================================
// UPDATE PRODUCT
// ===================================
export const updateProduct = async (req, res) => {

    try {

        const updatedProduct =
            await Product.findByIdAndUpdate(

                req.params.id,

                req.body,

                {
                    new: true,
                    runValidators: true
                }

            );

        if (!updatedProduct) {

            return res.status(404).json({

                message: "Product not found"

            });

        }

        return res.status(200).json({

            message: "Product updated successfully",

            product: updatedProduct

        });

    } catch (error) {

        return res.status(500).json({

            message: "Error updating product",

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

                message: "Product not found"

            });

        }

        return res.status(200).json({

            message: "Product deleted successfully"

        });

    } catch (error) {

        return res.status(500).json({

            message: "Error deleting product",

            error: error.message

        });

    }

};