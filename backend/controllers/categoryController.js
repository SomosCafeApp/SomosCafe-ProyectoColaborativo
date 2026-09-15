import Category from "../models/categoryModel.js";
import Product from "../models/productModel.js";

// ===================================
// GET ALL CATEGORIES
// ===================================
export const getCategories = async (req, res) => {

    try {

        const categories = await Category.find()
            .sort({
                createdAt: -1
            });

        return res.status(200).json({

            message:
                "Categories retrieved successfully",

            categories

        });

    } catch (error) {

        console.error(
            "Get categories error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving categories",

            error: error.message

        });

    }

};

// ===================================
// GET CATEGORY BY ID
// ===================================
export const getCategoryById = async (req, res) => {

    try {

        const category =
            await Category.findById(
                req.params.id
            );

        if (!category) {

            return res.status(404).json({

                message:
                    "Category not found"

            });

        }

        return res.status(200).json({

            message:
                "Category retrieved successfully",

            category

        });

    } catch (error) {

        console.error(
            "Get category error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving category",

            error: error.message

        });

    }

};

// ===================================
// CREATE CATEGORY
// ===================================
export const createCategory = async (req, res) => {

    try {

        const {
            name,
            description,
            image,
            isActive
        } = req.body;

        // ===================================
        // VALIDATE REQUIRED DATA
        // ===================================

        if (!name || !name.trim()) {

            return res.status(400).json({

                message:
                    "Category name is required"

            });

        }

        const normalizedName =
            name.trim();

        // ===================================
        // CHECK DUPLICATE CATEGORY
        // ===================================

        const existingCategory =
            await Category.findOne({

                name: {
                    $regex:
                        `^${normalizedName}$`,
                    $options: "i"
                }

            });

        if (existingCategory) {

            return res.status(409).json({

                message:
                    "Category already exists"

            });

        }

        // ===================================
        // CREATE CATEGORY
        // ===================================

        const newCategory =
            new Category({

                name: normalizedName,

                description:
                    description
                        ? description.trim()
                        : "",

                image:
                    image
                        ? image.trim()
                        : "",

                isActive:
                    isActive !== undefined
                        ? isActive
                        : true

            });

        // ===================================
        // SAVE CATEGORY
        // ===================================

        await newCategory.save();

        return res.status(201).json({

            message:
                "Category created successfully",

            category:
                newCategory

        });

    } catch (error) {

        console.error(
            "Create category error:",
            error
        );

        return res.status(500).json({

            message:
                "Error creating category",

            error: error.message

        });

    }

};

// ===================================
// UPDATE CATEGORY
// ===================================
export const updateCategory = async (req, res) => {

    try {

        const {
            name,
            description,
            image,
            isActive
        } = req.body;

        // ===================================
        // VALIDATE CATEGORY NAME
        // ===================================

        if (
            name !== undefined &&
            !name.trim()
        ) {

            return res.status(400).json({

                message:
                    "Category name cannot be empty"

            });

        }

        // ===================================
        // PREVENT DUPLICATE NAME
        // ===================================

        if (name !== undefined) {

            const existingCategory =
                await Category.findOne({

                    name: {
                        $regex:
                            `^${name.trim()}$`,
                        $options: "i"
                    },

                    _id: {
                        $ne: req.params.id
                    }

                });

            if (existingCategory) {

                return res.status(409).json({

                    message:
                        "Category name is already in use"

                });

            }

        }

        // ===================================
        // BUILD UPDATE
        // ===================================

        const updateData = {};

        if (name !== undefined) {

            updateData.name =
                name.trim();

        }

        if (description !== undefined) {

            updateData.description =
                description.trim();

        }

        if (image !== undefined) {

            updateData.image =
                image.trim();

        }

        if (isActive !== undefined) {

            updateData.isActive =
                isActive;

        }

        // ===================================
        // UPDATE CATEGORY
        // ===================================

        const updatedCategory =
            await Category.findByIdAndUpdate(

                req.params.id,

                updateData,

                {
                    new: true,
                    runValidators: true
                }

            );

        if (!updatedCategory) {

            return res.status(404).json({

                message:
                    "Category not found"

            });

        }

        return res.status(200).json({

            message:
                "Category updated successfully",

            category:
                updatedCategory

        });

    } catch (error) {

        console.error(
            "Update category error:",
            error
        );

        return res.status(500).json({

            message:
                "Error updating category",

            error: error.message

        });

    }

};

// ===================================
// DELETE CATEGORY
// ===================================
export const deleteCategory = async (req, res) => {

    try {

        // ===================================
        // CHECK CATEGORY
        // ===================================

        const category =
            await Category.findById(
                req.params.id
            );

        if (!category) {

            return res.status(404).json({

                message:
                    "Category not found"

            });

        }

        // ===================================
        // CHECK RELATED PRODUCTS
        // ===================================

        const productsUsingCategory =
            await Product.countDocuments({

                categoryId:
                    category._id

            });

        if (productsUsingCategory > 0) {

            return res.status(409).json({

                message:
                    "Category cannot be deleted because it is being used by products",

                productsCount:
                    productsUsingCategory

            });

        }

        // ===================================
        // DELETE CATEGORY
        // ===================================

        await Category.findByIdAndDelete(
            req.params.id
        );

        return res.status(200).json({

            message:
                "Category deleted successfully"

        });

    } catch (error) {

        console.error(
            "Delete category error:",
            error
        );

        return res.status(500).json({

            message:
                "Error deleting category",

            error: error.message

        });

    }

};