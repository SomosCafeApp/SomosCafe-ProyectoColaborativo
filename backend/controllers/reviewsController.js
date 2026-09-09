import Review from "../models/reviewModel.js";
import User from "../models/userModel.js";
import Product from "../models/productModel.js";

// ===================================
// GET PRODUCT REVIEWS
// ===================================

export const getProductReviews = async (req, res) => {

    try {

        const { productId } = req.params;

        // ===================================
        // CHECK PRODUCT
        // ===================================

        const product = await Product.findById(
            productId
        );

        if (!product) {

            return res.status(404).json({

                message: "Product not found"

            });

        }

        // ===================================
        // GET REVIEWS
        // ===================================

        const reviews = await Review.find({

            productId,

            isVisible: true

        })
            .populate(
                "userId",
                "name lastName profileImage"
            )
            .sort({

                createdAt: -1

            });

        // ===================================
        // CALCULATE AVERAGE
        // ===================================

        const totalReviews =
            reviews.length;

        const averageRating =
            totalReviews > 0

                ? reviews.reduce(
                    (sum, review) =>
                        sum + review.rating,
                    0
                ) / totalReviews

                : 0;

        return res.status(200).json({

            message:
                "Product reviews retrieved successfully",

            productId,

            totalReviews,

            averageRating:
                Number(
                    averageRating.toFixed(1)
                ),

            reviews

        });

    } catch (error) {

        console.error(
            "Get product reviews error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving product reviews",

            error: error.message

        });

    }

};


// ===================================
// GET USER REVIEWS
// ===================================

export const getUserReviews = async (req, res) => {

    try {

        const { userId } = req.params;

        // ===================================
        // CHECK USER
        // ===================================

        const user = await User.findById(
            userId
        );

        if (!user) {

            return res.status(404).json({

                message: "User not found"

            });

        }

        // ===================================
        // GET REVIEWS
        // ===================================

        const reviews = await Review.find({

            userId

        })
            .populate(
                "productId",
                "name images price"
            )
            .sort({

                createdAt: -1

            });

        return res.status(200).json({

            message:
                "User reviews retrieved successfully",

            reviews

        });

    } catch (error) {

        console.error(
            "Get user reviews error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving user reviews",

            error: error.message

        });

    }

};


// ===================================
// CREATE REVIEW
// ===================================

export const createReview = async (req, res) => {

    try {

        const {
            userId,
            productId,
            rating,
            comment
        } = req.body;

        // ===================================
        // VALIDATE REQUIRED DATA
        // ===================================

        if (
            !userId ||
            !productId ||
            rating === undefined
        ) {

            return res.status(400).json({

                message:
                    "userId, productId and rating are required"

            });

        }

        // ===================================
        // VALIDATE RATING
        // ===================================

        if (
            rating < 1 ||
            rating > 5
        ) {

            return res.status(400).json({

                message:
                    "Rating must be between 1 and 5"

            });

        }

        // ===================================
        // CHECK USER
        // ===================================

        const user = await User.findById(
            userId
        );

        if (!user) {

            return res.status(404).json({

                message: "User not found"

            });

        }

        // ===================================
        // CHECK PRODUCT
        // ===================================

        const product = await Product.findById(
            productId
        );

        if (!product) {

            return res.status(404).json({

                message: "Product not found"

            });

        }

        // ===================================
        // CHECK EXISTING REVIEW
        // ===================================

        const existingReview =
            await Review.findOne({

                userId,

                productId

            });

        if (existingReview) {

            return res.status(409).json({

                message:
                    "You have already reviewed this product"

            });

        }

        // ===================================
        // CREATE REVIEW
        // ===================================

        const newReview = new Review({

            userId,

            productId,

            rating,

            comment:
                comment
                    ? comment.trim()
                    : "",

            isVisible: true

        });

        await newReview.save();

        // ===================================
        // POPULATE RESPONSE
        // ===================================

        await newReview.populate(
            "userId",
            "name lastName profileImage"
        );

        await newReview.populate(
            "productId",
            "name images price"
        );

        return res.status(201).json({

            message:
                "Review created successfully",

            review: newReview

        });

    } catch (error) {

        console.error(
            "Create review error:",
            error
        );

        // ===================================
        // DUPLICATE REVIEW
        // ===================================

        if (
            error.code === 11000
        ) {

            return res.status(409).json({

                message:
                    "You have already reviewed this product"

            });

        }

        return res.status(500).json({

            message:
                "Error creating review",

            error: error.message

        });

    }

};


// ===================================
// UPDATE REVIEW
// ===================================

export const updateReview = async (req, res) => {

    try {

        const { id } = req.params;

        const {
            rating,
            comment
        } = req.body;

        // ===================================
        // VALIDATE RATING
        // ===================================

        if (
            rating !== undefined &&
            (
                rating < 1 ||
                rating > 5
            )
        ) {

            return res.status(400).json({

                message:
                    "Rating must be between 1 and 5"

            });

        }

        // ===================================
        // FIND REVIEW
        // ===================================

        const review =
            await Review.findById(id);

        if (!review) {

            return res.status(404).json({

                message: "Review not found"

            });

        }

        // ===================================
        // UPDATE DATA
        // ===================================

        if (rating !== undefined) {

            review.rating = rating;

        }

        if (comment !== undefined) {

            review.comment =
                comment.trim();

        }

        await review.save();

        // ===================================
        // POPULATE
        // ===================================

        await review.populate(
            "userId",
            "name lastName profileImage"
        );

        await review.populate(
            "productId",
            "name images price"
        );

        return res.status(200).json({

            message:
                "Review updated successfully",

            review

        });

    } catch (error) {

        console.error(
            "Update review error:",
            error
        );

        return res.status(500).json({

            message:
                "Error updating review",

            error: error.message

        });

    }

};


// ===================================
// DELETE REVIEW
// ===================================

export const deleteReview = async (req, res) => {

    try {

        const { id } = req.params;

        // ===================================
        // DELETE REVIEW
        // ===================================

        const deletedReview =
            await Review.findByIdAndDelete(id);

        if (!deletedReview) {

            return res.status(404).json({

                message: "Review not found"

            });

        }

        return res.status(200).json({

            message:
                "Review deleted successfully"

        });

    } catch (error) {

        console.error(
            "Delete review error:",
            error
        );

        return res.status(500).json({

            message:
                "Error deleting review",

            error: error.message

        });

    }

};


// ===================================
// HIDE / SHOW REVIEW
// ===================================

export const toggleReviewVisibility = async (req, res) => {

    try {

        const { id } = req.params;

        // ===================================
        // FIND REVIEW
        // ===================================

        const review =
            await Review.findById(id);

        if (!review) {

            return res.status(404).json({

                message: "Review not found"

            });

        }

        // ===================================
        // TOGGLE VISIBILITY
        // ===================================

        review.isVisible =
            !review.isVisible;

        await review.save();

        return res.status(200).json({

            message:
                review.isVisible

                    ? "Review is now visible"

                    : "Review is now hidden",

            isVisible:
                review.isVisible

        });

    } catch (error) {

        console.error(
            "Toggle review visibility error:",
            error
        );

        return res.status(500).json({

            message:
                "Error changing review visibility",

            error: error.message

        });

    }

};