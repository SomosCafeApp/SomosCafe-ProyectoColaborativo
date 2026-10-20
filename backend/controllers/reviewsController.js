import Review from "../models/reviewModel.js";
import User from "../models/userModel.js";
import Product from "../models/productModel.js";

// ===================================
// COMMENT LENGTH RULES
// ===================================
// Toda reseña debe traer una descripción de máximo 300 caracteres
// (se valida sobre el texto ya sin espacios extra). No hay un
// mínimo más allá de "no vacío".

const MIN_COMMENT_LENGTH = 1;
const MAX_COMMENT_LENGTH = 300;

const validateCommentLength = (comment) => {

    const trimmed = (comment || "").trim();

    if (trimmed.length < MIN_COMMENT_LENGTH) {

        return "La reseña no puede estar vacía";

    }

    if (trimmed.length > MAX_COMMENT_LENGTH) {

        return `La reseña debe tener máximo ${MAX_COMMENT_LENGTH} caracteres (tiene ${trimmed.length})`;

    }

    return null;

};

// ===================================
// RECALCULATE PRODUCT RATING
// ===================================
// Recalcula el promedio de calificación y el total de reseñas
// visibles de un producto, y lo guarda directamente en Product
// para que listar productos (GET /products) no necesite hacer
// una consulta extra por cada uno.

const recalculateProductRating = async (productId) => {

    try {

        const visibleReviews = await Review.find({

            productId,

            isVisible: true

        });

        const totalReviews = visibleReviews.length;

        const averageRating =
            totalReviews > 0

                ? visibleReviews.reduce(
                    (sum, review) => sum + review.rating,
                    0
                ) / totalReviews

                : 0;

        await Product.findByIdAndUpdate(
            productId,
            {
                rating: Number(averageRating.toFixed(1)),
                reviewCount: totalReviews
            }
        );

    } catch (error) {

        console.error(
            "Recalculate product rating error:",
            error
        );

    }

};

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

                message: "Producto no encontrado"

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
                "Reseñas del producto obtenidas correctamente",

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
                "Error al obtener las reseñas del producto",

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

                message: "Usuario no encontrado"

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
                "Reseñas del usuario obtenidas correctamente",

            reviews

        });

    } catch (error) {

        console.error(
            "Get user reviews error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al obtener las reseñas del usuario",

            error: error.message

        });

    }

};


// ===================================
// CREATE REVIEW
// ===================================

export const createReview = async (req, res) => {

    try {

        // El autor de la reseña siempre es el usuario autenticado
        // (viene del token), nunca un valor que mande el cliente.
        const userId = req.user.id;

        const {
            productId,
            rating,
            comment
        } = req.body;

        // ===================================
        // VALIDATE REQUIRED DATA
        // ===================================

        if (
            !productId ||
            rating === undefined
        ) {

            return res.status(400).json({

                message:
                    "productId y rating son obligatorios"

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
                    "La calificación debe estar entre 1 y 5"

            });

        }

        // ===================================
        // VALIDATE COMMENT LENGTH
        // ===================================

        const commentError = validateCommentLength(comment);

        if (commentError) {

            return res.status(400).json({

                message: commentError

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

                message: "Usuario no encontrado"

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

                message: "Producto no encontrado"

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
                    "Ya reseñaste este producto"

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

        // ===================================
        // UPDATE PRODUCT RATING
        // ===================================

        await recalculateProductRating(productId);

        return res.status(201).json({

            message:
                "Reseña creada correctamente",

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
                    "Ya reseñaste este producto"

            });

        }

        return res.status(500).json({

            message:
                "Error al crear la reseña",

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
                    "La calificación debe estar entre 1 y 5"

            });

        }

        // ===================================
        // VALIDATE COMMENT LENGTH
        // ===================================

        if (comment !== undefined) {

            const commentError = validateCommentLength(comment);

            if (commentError) {

                return res.status(400).json({

                    message: commentError

                });

            }

        }

        // ===================================
        // FIND REVIEW
        // ===================================

        const review =
            await Review.findById(id);

        if (!review) {

            return res.status(404).json({

                message: "Reseña no encontrada"

            });

        }

        // ===================================
        // CHECK OWNERSHIP
        // ===================================
        // Solo el autor de la reseña o un admin pueden editarla.

        const isOwner =
            review.userId.toString() === req.user.id;

        const isAdmin =
            req.user.role === "ADMIN";

        if (!isOwner && !isAdmin) {

            return res.status(403).json({

                message:
                    "No tienes permiso para editar esta reseña"

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

        // ===================================
        // UPDATE PRODUCT RATING
        // ===================================

        await recalculateProductRating(review.productId);

        return res.status(200).json({

            message:
                "Reseña actualizada correctamente",

            review

        });

    } catch (error) {

        console.error(
            "Update review error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al actualizar la reseña",

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
        // FIND REVIEW
        // ===================================

        const review =
            await Review.findById(id);

        if (!review) {

            return res.status(404).json({

                message: "Reseña no encontrada"

            });

        }

        // ===================================
        // CHECK OWNERSHIP
        // ===================================
        // Solo el autor de la reseña o un admin pueden eliminarla.

        const isOwner =
            review.userId.toString() === req.user.id;

        const isAdmin =
            req.user.role === "ADMIN";

        if (!isOwner && !isAdmin) {

            return res.status(403).json({

                message:
                    "No tienes permiso para eliminar esta reseña"

            });

        }

        const productId = review.productId;

        // ===================================
        // DELETE REVIEW
        // ===================================

        await Review.findByIdAndDelete(id);

        // ===================================
        // UPDATE PRODUCT RATING
        // ===================================

        await recalculateProductRating(productId);

        return res.status(200).json({

            message:
                "Reseña eliminada correctamente"

        });

    } catch (error) {

        console.error(
            "Delete review error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al eliminar la reseña",

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

                message: "Reseña no encontrada"

            });

        }

        // ===================================
        // TOGGLE VISIBILITY
        // ===================================

        review.isVisible =
            !review.isVisible;

        await review.save();

        // ===================================
        // UPDATE PRODUCT RATING
        // ===================================

        await recalculateProductRating(review.productId);

        return res.status(200).json({

            message:
                review.isVisible

                    ? "La reseña ahora es visible"

                    : "La reseña ahora está oculta",

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
                "Error al cambiar la visibilidad de la reseña",

            error: error.message

        });

    }

};