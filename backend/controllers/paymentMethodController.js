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
                "Métodos de pago obtenidos correctamente",

            paymentMethods

        });

    } catch (error) {

        console.error(
            "Get payment methods error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al obtener los métodos de pago",

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
                    "Método de pago no encontrado"

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
                    "No tienes autorización para acceder a este método de pago"

            });

        }

        return res.status(200).json({

            message:
                "Método de pago obtenido correctamente",

            paymentMethod

        });

    } catch (error) {

        console.error(
            "Get payment method error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al obtener el método de pago",

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
                    "Tipo de método de pago inválido"

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
                        "Los últimos cuatro dígitos deben ser exactamente 4 números"

                });

            }

            if (
                !expirationMonth ||
                !expirationYear
            ) {

                return res.status(400).json({

                    message:
                        "La fecha de vencimiento de la tarjeta es obligatoria"

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
                "Método de pago creado correctamente",

            paymentMethod

        });

    } catch (error) {

        console.error(
            "Create payment method error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al crear el método de pago",

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
                    "Método de pago no encontrado"

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
                    "No tienes autorización para actualizar este método de pago"

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
                            "Los últimos cuatro dígitos deben ser exactamente 4 números"

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
                "Método de pago actualizado correctamente",

            paymentMethod

        });

    } catch (error) {

        console.error(
            "Update payment method error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al actualizar el método de pago",

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
                    "Método de pago no encontrado"

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
                    "No tienes autorización para eliminar este método de pago"

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
                "Método de pago eliminado correctamente"

        });

    } catch (error) {

        console.error(
            "Delete payment method error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al eliminar el método de pago",

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
                    "Método de pago no encontrado"

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
                    "No tienes autorización para modificar este método de pago"

            });

        }

        if (
            !paymentMethod.isActive
        ) {

            return res.status(400).json({

                message:
                    "Un método de pago inactivo no se puede establecer como principal"

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
                "Método de pago principal actualizado correctamente",

            paymentMethod

        });

    } catch (error) {

        console.error(
            "Set default payment method error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al establecer el método de pago principal",

            error: error.message

        });

    }

};