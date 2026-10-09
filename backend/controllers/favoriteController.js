import Favorite from "../models/favoriteModel.js";
import Product from "../models/productModel.js";
import { getDiscountResolver, decorateProduct } from "../utils/promotions.js";

// ===================================
// GET USER FAVORITES
// ===================================
export const getFavorites = async (req, res) => {

    try {

        const favorites =
            await Favorite.find({
                userId: req.user.id
            })
            .populate({
                path: "productId",
                populate: {
                    path: "categoryId",
                    select: "name"
                }
            })
            .sort({
                createdAt: -1
            });

        const resolver =
            await getDiscountResolver(req.user.id);

        const decorated = favorites.map(favorite => {
            const plain = favorite.toObject();
            plain.productId =
                decorateProduct(favorite.productId, resolver);
            return plain;
        });

        return res.status(200).json({

            message:
                "Favorites retrieved successfully",

            favorites: decorated

        });

    } catch (error) {

        console.error(
            "Get favorites error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving favorites",

            error: error.message

        });

    }

};

// ===================================
// ADD FAVORITE
// ===================================
export const addFavorite = async (req, res) => {

    try {

        const {
            productId
        } = req.body;

        // ===================================
        // VALIDATE PRODUCT ID
        // ===================================

        if (!productId) {

            return res.status(400).json({

                message:
                    "Product ID is required"

            });

        }

        // ===================================
        // VERIFY PRODUCT EXISTS
        // ===================================

        const product =
            await Product.findById(
                productId
            );

        if (!product) {

            return res.status(404).json({

                message:
                    "Product not found"

            });

        }

        // ===================================
        // CHECK EXISTING FAVORITE
        // ===================================

        const existingFavorite =
            await Favorite.findOne({

                userId:
                    req.user.id,

                productId

            });

        if (existingFavorite) {

            return res.status(409).json({

                message:
                    "Product is already in favorites"

            });

        }

        // ===================================
        // CREATE FAVORITE
        // ===================================

        const favorite =
            new Favorite({

                userId:
                    req.user.id,

                productId

            });

        // ===================================
        // SAVE
        // ===================================

        await favorite.save();

        // ===================================
        // UPDATE PRODUCT FAVORITES COUNT
        // ===================================

        await Product.findByIdAndUpdate(
            productId,
            {
                $inc: {
                    favoritesCount: 1
                }
            }
        );

        // ===================================
        // POPULATE PRODUCT
        // ===================================

        await favorite.populate({
            path: "productId",
            populate: {
                path: "categoryId",
                select: "name"
            }
        });

        return res.status(201).json({

            message:
                "Product added to favorites",

            favorite

        });

    } catch (error) {

        console.error(
            "Add favorite error:",
            error
        );

        return res.status(500).json({

            message:
                "Error adding favorite",

            error: error.message

        });

    }

};

// ===================================
// REMOVE FAVORITE
// ===================================
export const removeFavorite = async (req, res) => {

    try {

        const {
            productId
        } = req.params;

        // ===================================
        // DELETE USER FAVORITE
        // ===================================

        const deletedFavorite =
            await Favorite.findOneAndDelete({

                userId:
                    req.user.id,

                productId

            });

        if (!deletedFavorite) {

            return res.status(404).json({

                message:
                    "Favorite not found"

            });

        }

        // ===================================
        // UPDATE PRODUCT FAVORITES COUNT
        // ===================================
        // Nunca debe quedar en negativo (por si hay datos
        // desincronizados de antes de este cambio).

        const product =
            await Product.findById(productId);

        if (product && product.favoritesCount > 0) {

            product.favoritesCount -= 1;

            await product.save();

        }

        return res.status(200).json({

            message:
                "Product removed from favorites"

        });

    } catch (error) {

        console.error(
            "Remove favorite error:",
            error
        );

        return res.status(500).json({

            message:
                "Error removing favorite",

            error: error.message

        });

    }

};