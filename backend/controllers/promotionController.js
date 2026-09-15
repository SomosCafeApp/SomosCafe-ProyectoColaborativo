import Promotion from "../models/promotionModel.js";
import Product from "../models/productModel.js";
import User from "../models/userModel.js";

// ===================================
// GET ALL PROMOTIONS
// ===================================
export const getPromotions = async (req, res) => {

    try {

        const promotions =
            await Promotion.find()
                .populate(
                    "productIds",
                    "name price"
                )
                .populate(
                    "userIds",
                    "name lastName email"
                )
                .sort({
                    createdAt: -1
                });

        return res.status(200).json({

            message:
                "Promotions retrieved successfully",

            promotions

        });

    } catch (error) {

        console.error(
            "Get promotions error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving promotions",

            error: error.message

        });

    }

};

// ===================================
// GET PROMOTION BY ID
// ===================================
export const getPromotionById = async (req, res) => {

    try {

        const promotion =
            await Promotion.findById(
                req.params.id
            )
                .populate(
                    "productIds",
                    "name price"
                )
                .populate(
                    "userIds",
                    "name lastName email"
                );

        if (!promotion) {

            return res.status(404).json({

                message:
                    "Promotion not found"

            });

        }

        return res.status(200).json({

            message:
                "Promotion retrieved successfully",

            promotion

        });

    } catch (error) {

        console.error(
            "Get promotion error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving promotion",

            error: error.message

        });

    }

};

// ===================================
// CREATE PROMOTION
// ===================================
export const createPromotion = async (req, res) => {

    try {

        const {
            code,
            name,
            description,
            discountType,
            discountValue,
            minimumPurchase,
            maximumDiscount,
            productIds,
            userIds,
            usageLimit,
            startDate,
            endDate,
            isActive
        } = req.body;

        // ===================================
        // VALIDATE REQUIRED DATA
        // ===================================

        if (
            !code ||
            !name ||
            !discountType ||
            discountValue === undefined ||
            !startDate ||
            !endDate
        ) {

            return res.status(400).json({

                message:
                    "Code, name, discountType, discountValue, startDate and endDate are required"

            });

        }

        // ===================================
        // VALIDATE DISCOUNT TYPE
        // ===================================

        if (
            ![
                "percentage",
                "fixed"
            ].includes(discountType)
        ) {

            return res.status(400).json({

                message:
                    "Invalid discount type"

            });

        }

        // ===================================
        // VALIDATE PERCENTAGE
        // ===================================

        if (
            discountType === "percentage" &&
            discountValue > 100
        ) {

            return res.status(400).json({

                message:
                    "Percentage discount cannot exceed 100"

            });

        }

        // ===================================
        // VALIDATE DISCOUNT VALUE
        // ===================================

        if (discountValue <= 0) {

            return res.status(400).json({

                message:
                    "Discount value must be greater than zero"

            });

        }

        // ===================================
        // VALIDATE DATES
        // ===================================

        const start =
            new Date(startDate);

        const end =
            new Date(endDate);

        if (
            isNaN(start.getTime()) ||
            isNaN(end.getTime())
        ) {

            return res.status(400).json({

                message:
                    "Invalid promotion dates"

            });

        }

        if (end <= start) {

            return res.status(400).json({

                message:
                    "End date must be greater than start date"

            });

        }

        // ===================================
        // NORMALIZE CODE
        // ===================================

        const normalizedCode =
            code.trim().toUpperCase();

        // ===================================
        // CHECK DUPLICATE CODE
        // ===================================

        const existingPromotion =
            await Promotion.findOne({

                code: normalizedCode

            });

        if (existingPromotion) {

            return res.status(409).json({

                message:
                    "Promotion code already exists"

            });

        }

        // ===================================
        // VALIDATE PRODUCTS
        // ===================================

        if (
            productIds &&
            productIds.length > 0
        ) {

            const products =
                await Product.find({

                    _id: {
                        $in: productIds
                    }

                });

            if (
                products.length !==
                productIds.length
            ) {

                return res.status(400).json({

                    message:
                        "One or more products were not found"

                });

            }

        }

        // ===================================
        // VALIDATE USERS
        // ===================================

        if (
            userIds &&
            userIds.length > 0
        ) {

            const users =
                await User.find({

                    _id: {
                        $in: userIds
                    }

                });

            if (
                users.length !==
                userIds.length
            ) {

                return res.status(400).json({

                    message:
                        "One or more users were not found"

                });

            }

        }

        // ===================================
        // CREATE PROMOTION
        // ===================================

        const newPromotion =
            new Promotion({

                code: normalizedCode,

                name: name.trim(),

                description:
                    description || "",

                discountType,

                discountValue,

                minimumPurchase:
                    minimumPurchase || 0,

                maximumDiscount:
                    maximumDiscount !== undefined
                        ? maximumDiscount
                        : null,

                productIds:
                    productIds || [],

                userIds:
                    userIds || [],

                usageLimit:
                    usageLimit !== undefined
                        ? usageLimit
                        : null,

                usageCount: 0,

                startDate: start,

                endDate: end,

                isActive:
                    isActive !== undefined
                        ? isActive
                        : true

            });

        await newPromotion.save();

        return res.status(201).json({

            message:
                "Promotion created successfully",

            promotion: newPromotion

        });

    } catch (error) {

        console.error(
            "Create promotion error:",
            error
        );

        return res.status(500).json({

            message:
                "Error creating promotion",

            error: error.message

        });

    }

};

// ===================================
// UPDATE PROMOTION
// ===================================
export const updatePromotion = async (req, res) => {

    try {

        const {
            code,
            name,
            description,
            discountType,
            discountValue,
            minimumPurchase,
            maximumDiscount,
            productIds,
            userIds,
            usageLimit,
            startDate,
            endDate,
            isActive
        } = req.body;

        // ===================================
        // FIND PROMOTION
        // ===================================

        const promotion =
            await Promotion.findById(
                req.params.id
            );

        if (!promotion) {

            return res.status(404).json({

                message:
                    "Promotion not found"

            });

        }

        // ===================================
        // VALIDATE DISCOUNT TYPE
        // ===================================

        if (
            discountType &&
            ![
                "percentage",
                "fixed"
            ].includes(discountType)
        ) {

            return res.status(400).json({

                message:
                    "Invalid discount type"

            });

        }

        // ===================================
        // VALIDATE DISCOUNT VALUE
        // ===================================

        const finalDiscountType =
            discountType ||
            promotion.discountType;

        const finalDiscountValue =
            discountValue !== undefined
                ? discountValue
                : promotion.discountValue;

        if (
            finalDiscountValue <= 0
        ) {

            return res.status(400).json({

                message:
                    "Discount value must be greater than zero"

            });

        }

        if (
            finalDiscountType ===
                "percentage" &&
            finalDiscountValue > 100
        ) {

            return res.status(400).json({

                message:
                    "Percentage discount cannot exceed 100"

            });

        }

        // ===================================
        // VALIDATE DATES
        // ===================================

        const finalStartDate =
            startDate
                ? new Date(startDate)
                : promotion.startDate;

        const finalEndDate =
            endDate
                ? new Date(endDate)
                : promotion.endDate;

        if (
            isNaN(
                finalStartDate.getTime()
            ) ||
            isNaN(
                finalEndDate.getTime()
            )
        ) {

            return res.status(400).json({

                message:
                    "Invalid promotion dates"

            });

        }

        if (
            finalEndDate <=
            finalStartDate
        ) {

            return res.status(400).json({

                message:
                    "End date must be greater than start date"

            });

        }

        // ===================================
        // UPDATE CODE
        // ===================================

        if (code) {

            const normalizedCode =
                code.trim().toUpperCase();

            const duplicate =
                await Promotion.findOne({

                    code: normalizedCode,

                    _id: {
                        $ne: req.params.id
                    }

                });

            if (duplicate) {

                return res.status(409).json({

                    message:
                        "Promotion code already exists"

                });

            }

            promotion.code =
                normalizedCode;

        }

        // ===================================
        // UPDATE FIELDS
        // ===================================

        if (name !== undefined)
            promotion.name =
                name.trim();

        if (description !== undefined)
            promotion.description =
                description;

        if (discountType !== undefined)
            promotion.discountType =
                discountType;

        if (discountValue !== undefined)
            promotion.discountValue =
                discountValue;

        if (minimumPurchase !== undefined)
            promotion.minimumPurchase =
                minimumPurchase;

        if (maximumDiscount !== undefined)
            promotion.maximumDiscount =
                maximumDiscount;

        if (productIds !== undefined)
            promotion.productIds =
                productIds;

        if (userIds !== undefined)
            promotion.userIds =
                userIds;

        if (usageLimit !== undefined)
            promotion.usageLimit =
                usageLimit;

        if (startDate !== undefined)
            promotion.startDate =
                finalStartDate;

        if (endDate !== undefined)
            promotion.endDate =
                finalEndDate;

        if (isActive !== undefined)
            promotion.isActive =
                isActive;

        await promotion.save();

        return res.status(200).json({

            message:
                "Promotion updated successfully",

            promotion

        });

    } catch (error) {

        console.error(
            "Update promotion error:",
            error
        );

        return res.status(500).json({

            message:
                "Error updating promotion",

            error: error.message

        });

    }

};

// ===================================
// DELETE PROMOTION
// ===================================
export const deletePromotion = async (req, res) => {

    try {

        const promotion =
            await Promotion.findByIdAndDelete(
                req.params.id
            );

        if (!promotion) {

            return res.status(404).json({

                message:
                    "Promotion not found"

            });

        }

        return res.status(200).json({

            message:
                "Promotion deleted successfully"

        });

    } catch (error) {

        console.error(
            "Delete promotion error:",
            error
        );

        return res.status(500).json({

            message:
                "Error deleting promotion",

            error: error.message

        });

    }

};

// ===================================
// VALIDATE PROMOTION
// ===================================
export const validatePromotion = async (req, res) => {

    try {

        const {
            code,
            userId,
            subtotal
        } = req.body;

        // ===================================
        // VALIDATE REQUIRED DATA
        // ===================================

        if (
            !code ||
            !userId ||
            subtotal === undefined
        ) {

            return res.status(400).json({

                message:
                    "Code, userId and subtotal are required"

            });

        }

        // ===================================
        // FIND PROMOTION
        // ===================================

        const promotion =
            await Promotion.findOne({

                code:
                    code.trim().toUpperCase(),

                isActive: true

            });

        if (!promotion) {

            return res.status(404).json({

                message:
                    "Promotion not found or inactive"

            });

        }

        // ===================================
        // VALIDATE DATE
        // ===================================

        const now = new Date();

        if (
            now < promotion.startDate
        ) {

            return res.status(400).json({

                message:
                    "Promotion has not started yet"

            });

        }

        if (
            now > promotion.endDate
        ) {

            return res.status(400).json({

                message:
                    "Promotion has expired"

            });

        }

        // ===================================
        // VALIDATE USAGE LIMIT
        // ===================================

        if (
            promotion.usageLimit !== null &&
            promotion.usageCount >=
                promotion.usageLimit
        ) {

            return res.status(400).json({

                message:
                    "Promotion usage limit reached"

            });

        }

        // ===================================
        // VALIDATE USER
        // ===================================

        const user =
            await User.findById(userId);

        if (!user) {

            return res.status(404).json({

                message:
                    "User not found"

            });

        }

        // ===================================
        // VALIDATE SPECIFIC USERS
        // ===================================

        if (
            promotion.userIds.length > 0 &&
            !promotion.userIds.some(
                id =>
                    id.toString() ===
                    userId.toString()
            )
        ) {

            return res.status(403).json({

                message:
                    "Promotion is not available for this user"

            });

        }

        // ===================================
        // VALIDATE MINIMUM PURCHASE
        // ===================================

        if (
            subtotal <
            promotion.minimumPurchase
        ) {

            return res.status(400).json({

                message:
                    `Minimum purchase required: ${promotion.minimumPurchase}`

            });

        }

        // ===================================
        // CALCULATE DISCOUNT
        // ===================================

        let discount = 0;

        if (
            promotion.discountType ===
            "percentage"
        ) {

            discount =
                subtotal *
                (
                    promotion.discountValue /
                    100
                );

        } else {

            discount =
                promotion.discountValue;

        }

        // ===================================
        // APPLY MAXIMUM DISCOUNT
        // ===================================

        if (
            promotion.maximumDiscount !==
            null &&
            discount >
                promotion.maximumDiscount
        ) {

            discount =
                promotion.maximumDiscount;

        }

        // ===================================
        // PREVENT NEGATIVE TOTAL
        // ===================================

        discount =
            Math.min(
                discount,
                subtotal
            );

        const finalTotal =
            subtotal - discount;

        return res.status(200).json({

            message:
                "Promotion is valid",

            promotion: {

                id: promotion._id,

                code: promotion.code,

                name: promotion.name,

                discountType:
                    promotion.discountType,

                discountValue:
                    promotion.discountValue

            },

            subtotal,

            discount,

            finalTotal

        });

    } catch (error) {

        console.error(
            "Validate promotion error:",
            error
        );

        return res.status(500).json({

            message:
                "Error validating promotion",

            error: error.message

        });

    }

};