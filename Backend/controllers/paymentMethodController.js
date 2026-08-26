import PaymentMethod from "../models/paymentMethodModel.js";

// ===================================
// GET USER PAYMENT METHODS
// ===================================
export const getPaymentMethods = async (req, res) => {

    try {

        const paymentMethods =
            await PaymentMethod.find({

                userId: req.user.id,

                isActive: true

            })
                .sort({
                    isDefault: -1,
                    createdAt: -1
                });

        return res.status(200).json({

            message:
                "Payment methods retrieved successfully",

            paymentMethods

        });

    } catch (error) {

        console.error(
            "Get payment methods error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving payment methods",

            error: error.message

        });

    }

};

// ===================================
// GET PAYMENT METHOD BY ID
// ===================================
export const getPaymentMethodById = async (req, res) => {

    try {

        const paymentMethod =
            await PaymentMethod.findById(
                req.params.id
            );

        if (!paymentMethod) {

            return res.status(404).json({

                message:
                    "Payment method not found"

            });

        }

        // ===================================
        // VERIFY OWNER
        // ===================================

        if (
            paymentMethod.userId.toString() !==
            req.user.id.toString()
        ) {

            return res.status(403).json({

                message:
                    "You are not authorized to access this payment method"

            });

        }

        return res.status(200).json({

            message:
                "Payment method retrieved successfully",

            paymentMethod

        });

    } catch (error) {

        console.error(
            "Get payment method error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving payment method",

            error: error.message

        });

    }

};

// ===================================
// CREATE PAYMENT METHOD
// ===================================
export const createPaymentMethod = async (req, res) => {

    try {

        const {
            type,
            provider,
            name,
            lastFourDigits,
            expirationMonth,
            expirationYear,
            token,
            isDefault
        } = req.body;

        // ===================================
        // VALIDATE TYPE
        // ===================================

        const validTypes = [

            "CARD",
            "CASH",
            "BANK_TRANSFER",
            "DIGITAL_WALLET"

        ];

        if (
            !validTypes.includes(type)
        ) {

            return res.status(400).json({

                message:
                    "Invalid payment method type"

            });

        }

        // ===================================
        // VALIDATE CARD DATA
        // ===================================

        if (type === "CARD") {

            if (
                !lastFourDigits ||
                !/^\d{4}$/.test(
                    lastFourDigits
                )
            ) {

                return res.status(400).json({

                    message:
                        "Last four digits must contain exactly 4 numbers"

                });

            }

            if (
                !expirationMonth ||
                !expirationYear
            ) {

                return res.status(400).json({

                    message:
                        "Card expiration date is required"

                });

            }

        }

        // ===================================
        // VALIDATE DEFAULT
        // ===================================

        if (isDefault) {

            await PaymentMethod.updateMany(

                {
                    userId: req.user.id,
                    isActive: true
                },

                {
                    $set: {
                        isDefault: false
                    }
                }

            );

        }

        // ===================================
        // CREATE PAYMENT METHOD
        // ===================================

        const paymentMethod =
            new PaymentMethod({

                userId:
                    req.user.id,

                type,

                provider:
                    provider || "",

                name:
                    name || "",

                lastFourDigits:
                    type === "CARD"
                        ? lastFourDigits
                        : "",

                expirationMonth:
                    type === "CARD"
                        ? expirationMonth
                        : null,

                expirationYear:
                    type === "CARD"
                        ? expirationYear
                        : null,

                token:
                    token || null,

                isDefault:
                    isDefault || false,

                isActive:
                    true

            });

        // ===================================
        // SAVE
        // ===================================

        await paymentMethod.save();

        return res.status(201).json({

            message:
                "Payment method created successfully",

            paymentMethod

        });

    } catch (error) {

        console.error(
            "Create payment method error:",
            error
        );

        return res.status(500).json({

            message:
                "Error creating payment method",

            error: error.message

        });

    }

};

// ===================================
// UPDATE PAYMENT METHOD
// ===================================
export const updatePaymentMethod = async (req, res) => {

    try {

        const paymentMethod =
            await PaymentMethod.findById(
                req.params.id
            );

        if (!paymentMethod) {

            return res.status(404).json({

                message:
                    "Payment method not found"

            });

        }

        // ===================================
        // VERIFY OWNER
        // ===================================

        if (
            paymentMethod.userId.toString() !==
            req.user.id.toString()
        ) {

            return res.status(403).json({

                message:
                    "You are not authorized to update this payment method"

            });

        }

        const {
            name,
            provider,
            lastFourDigits,
            expirationMonth,
            expirationYear,
            token,
            isDefault,
            isActive
        } = req.body;

        // ===================================
        // UPDATE BASIC DATA
        // ===================================

        if (name !== undefined) {

            paymentMethod.name =
                name;

        }

        if (provider !== undefined) {

            paymentMethod.provider =
                provider;

        }

        if (
            paymentMethod.type === "CARD"
        ) {

            if (
                lastFourDigits !== undefined
            ) {

                if (
                    !/^\d{4}$/.test(
                        lastFourDigits
                    )
                ) {

                    return res.status(400).json({

                        message:
                            "Last four digits must contain exactly 4 numbers"

                    });

                }

                paymentMethod.lastFourDigits =
                    lastFourDigits;

            }

            if (
                expirationMonth !== undefined
            ) {

                paymentMethod.expirationMonth =
                    expirationMonth;

            }

            if (
                expirationYear !== undefined
            ) {

                paymentMethod.expirationYear =
                    expirationYear;

            }

        }

        if (token !== undefined) {

            paymentMethod.token =
                token;

        }

        // ===================================
        // DEFAULT PAYMENT METHOD
        // ===================================

        if (isDefault === true) {

            await PaymentMethod.updateMany(

                {
                    userId:
                        req.user.id,

                    _id: {
                        $ne:
                            paymentMethod._id
                    },

                    isActive: true
                },

                {
                    $set: {
                        isDefault: false
                    }
                }

            );

            paymentMethod.isDefault =
                true;

        }

        if (isDefault === false) {

            paymentMethod.isDefault =
                false;

        }

        // ===================================
        // ACTIVE STATUS
        // ===================================

        if (isActive !== undefined) {

            paymentMethod.isActive =
                isActive;

        }

        // ===================================
        // SAVE
        // ===================================

        await paymentMethod.save();

        return res.status(200).json({

            message:
                "Payment method updated successfully",

            paymentMethod

        });

    } catch (error) {

        console.error(
            "Update payment method error:",
            error
        );

        return res.status(500).json({

            message:
                "Error updating payment method",

            error: error.message

        });

    }

};

// ===================================
// DELETE PAYMENT METHOD
// ===================================
export const deletePaymentMethod = async (req, res) => {

    try {

        const paymentMethod =
            await PaymentMethod.findById(
                req.params.id
            );

        if (!paymentMethod) {

            return res.status(404).json({

                message:
                    "Payment method not found"

            });

        }

        // ===================================
        // VERIFY OWNER
        // ===================================

        if (
            paymentMethod.userId.toString() !==
            req.user.id.toString()
        ) {

            return res.status(403).json({

                message:
                    "You are not authorized to delete this payment method"

            });

        }

        // ===================================
        // SOFT DELETE
        // ===================================

        paymentMethod.isActive =
            false;

        paymentMethod.isDefault =
            false;

        await paymentMethod.save();

        return res.status(200).json({

            message:
                "Payment method deleted successfully"

        });

    } catch (error) {

        console.error(
            "Delete payment method error:",
            error
        );

        return res.status(500).json({

            message:
                "Error deleting payment method",

            error: error.message

        });

    }

};

// ===================================
// SET DEFAULT PAYMENT METHOD
// ===================================
export const setDefaultPaymentMethod = async (req, res) => {

    try {

        const paymentMethod =
            await PaymentMethod.findById(
                req.params.id
            );

        if (!paymentMethod) {

            return res.status(404).json({

                message:
                    "Payment method not found"

            });

        }

        // ===================================
        // VERIFY OWNER
        // ===================================

        if (
            paymentMethod.userId.toString() !==
            req.user.id.toString()
        ) {

            return res.status(403).json({

                message:
                    "You are not authorized to modify this payment method"

            });

        }

        if (
            !paymentMethod.isActive
        ) {

            return res.status(400).json({

                message:
                    "Inactive payment method cannot be set as default"

            });

        }

        // ===================================
        // REMOVE CURRENT DEFAULT
        // ===================================

        await PaymentMethod.updateMany(

            {
                userId:
                    req.user.id,

                _id: {
                    $ne:
                        paymentMethod._id
                },

                isActive: true
            },

            {
                $set: {
                    isDefault: false
                }
            }

        );

        // ===================================
        // SET DEFAULT
        // ===================================

        paymentMethod.isDefault =
            true;

        await paymentMethod.save();

        return res.status(200).json({

            message:
                "Default payment method updated successfully",

            paymentMethod

        });

    } catch (error) {

        console.error(
            "Set default payment method error:",
            error
        );

        return res.status(500).json({

            message:
                "Error setting default payment method",

            error: error.message

        });

    }

};