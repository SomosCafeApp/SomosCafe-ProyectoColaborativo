import Promotion from "../models/promotionModel.js";
import Product from "../models/productModel.js";
import User from "../models/userModel.js";
import { decorateProduct, buildDiscountResolver } from "../utils/promotions.js";
import {
    notifyUsers,
    notifyAllCustomers,
    formatMoney,
    formatDate
} from "../utils/notify.js";

// ===================================
// NOTIFY NEW PROMOTION (push + pantalla de notificaciones)
// ===================================
// Se usa al crear una promoción y cuando una promoción pasa de
// inactiva a activa. Solo avisa si está activa y no ha vencido. Si
// está dirigida a usuarios concretos (userIds) solo les avisa a
// ellos; si no, a todos los clientes. Nunca lanza error y no hay que
// esperarla (no retrasa la respuesta).
const notifyNewPromotion = (promotion) => {

    if (
        !promotion.isActive ||
        promotion.endDate <= new Date()
    ) {
        return;
    }

    const discountText =
        promotion.discountType === "percentage"
            ? `${promotion.discountValue}% de descuento`
            : `${formatMoney(promotion.discountValue)} de descuento`;

    const startsLater =
        promotion.startDate > new Date()
            ? ` Disponible desde el ${formatDate(promotion.startDate)}.`
            : " ¡Aprovéchala!";

    const payload = {
        title: "Nueva promoción",
        message: `${promotion.name}: ${discountText}.${startsLater}`,
        type: "PROMOTION",
        relatedId: promotion._id
    };

    if (promotion.userIds.length > 0) {
        notifyUsers(promotion.userIds, payload);
    } else {
        notifyAllCustomers(payload);
    }
};

// ===================================
// GET ALL PROMOTIONS
// ===================================
export const getPromotions = async (req, res) => {

    try {

        const promotions =
            await Promotion.find()
                .populate(
                    "productIds",
                    "name price images"
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
                "Promociones obtenidas correctamente",

            promotions

        });

    } catch (error) {

        console.error(
            "Get promotions error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al obtener las promociones",

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
                    "name price images"
                )
                .populate(
                    "userIds",
                    "name lastName email"
                );

        if (!promotion) {

            return res.status(404).json({

                message:
                    "Promoción no encontrada"

            });

        }

        return res.status(200).json({

            message:
                "Promoción obtenida correctamente",

            promotion

        });

    } catch (error) {

        console.error(
            "Get promotion error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al obtener la promoción",

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
                    "Code, name, discountType, discountValue, startDate y endDate son obligatorios"

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
                    "Tipo de descuento inválido"

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
                    "El descuento porcentual no puede superar 100"

            });

        }

        // ===================================
        // VALIDATE DISCOUNT VALUE
        // ===================================

        if (discountValue <= 0) {

            return res.status(400).json({

                message:
                    "El valor del descuento debe ser mayor que cero"

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
                    "Fechas de la promoción inválidas"

            });

        }

        if (end <= start) {

            return res.status(400).json({

                message:
                    "La fecha de fin debe ser posterior a la fecha de inicio"

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
                    "El código de la promoción ya existe"

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
                        "Uno o más productos no fueron encontrados"

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
                        "Uno o más usuarios no fueron encontrados"

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

        notifyNewPromotion(newPromotion);

        return res.status(201).json({

            message:
                "Promoción creada correctamente",

            promotion: newPromotion

        });

    } catch (error) {

        console.error(
            "Create promotion error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al crear la promoción",

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
                    "Promoción no encontrada"

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
                    "Tipo de descuento inválido"

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
                    "El valor del descuento debe ser mayor que cero"

            });

        }

        if (
            finalDiscountType ===
                "percentage" &&
            finalDiscountValue > 100
        ) {

            return res.status(400).json({

                message:
                    "El descuento porcentual no puede superar 100"

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
                    "Fechas de la promoción inválidas"

            });

        }

        if (
            finalEndDate <=
            finalStartDate
        ) {

            return res.status(400).json({

                message:
                    "La fecha de fin debe ser posterior a la fecha de inicio"

            });

        }

        // ===================================
        // VALIDATE PRODUCTS
        // ===================================

        if (
            productIds !== undefined &&
            productIds.length > 0
        ) {
            const found =
                await Product.countDocuments({
                    _id: { $in: productIds }
                });

            if (found !== productIds.length) {
                return res.status(400).json({
                    message:
                        "Uno o más productos no fueron encontrados"
                });
            }
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
                        "El código de la promoción ya existe"

                });

            }

            promotion.code =
                normalizedCode;

        }

        // Estado previo, para avisar solo si pasa de inactiva a activa.
        const wasActive = promotion.isActive;

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

        // Una promoción deshabilitada no puede seguir siendo la del día.
        if (promotion.isActive === false)
            promotion.isPromoOfTheDay = false;

        await promotion.save();

        // Editar una promoción que ya estaba activa NO avisa (evita
        // spam); solo cuando se activa.
        if (!wasActive && promotion.isActive) {
            notifyNewPromotion(promotion);
        }

        return res.status(200).json({

            message:
                "Promoción actualizada correctamente",

            promotion

        });

    } catch (error) {

        console.error(
            "Update promotion error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al actualizar la promoción",

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
                    "Promoción no encontrada"

            });

        }

        return res.status(200).json({

            message:
                "Promoción eliminada correctamente"

        });

    } catch (error) {

        console.error(
            "Delete promotion error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al eliminar la promoción",

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
                    "Code, userId y subtotal son obligatorios"

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
                    "Promoción no encontrada o inactiva"

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
                    "La promoción aún no ha comenzado"

            });

        }

        if (
            now > promotion.endDate
        ) {

            return res.status(400).json({

                message:
                    "La promoción ya venció"

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
                    "Se alcanzó el límite de uso de la promoción"

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
                    "Usuario no encontrado"

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
                    "La promoción no está disponible para este usuario"

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
                    `Compra mínima requerida: ${promotion.minimumPurchase}`

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
                "La promoción es válida",

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
                "Error al validar la promoción",

            error: error.message

        });

    }

};

// ===================================
// GET PROMO OF THE DAY (PUBLIC)
// ===================================
// La usa el home. Devuelve null si no hay promo marcada o si la
// marcada está deshabilitada / fuera de fechas / es solo para
// usuarios específicos.
export const getPromoOfTheDay = async (req, res) => {

    try {

        const now = new Date();

        const promotion = await Promotion.findOne({
            isPromoOfTheDay: true,
            isActive: true,
            startDate: { $lte: now },
            endDate: { $gte: now },
            userIds: { $size: 0 }
        }).populate(
            "productIds",
            "name price images isAvailable"
        );

        if (!promotion) {
            return res.status(200).json({
                message: "No hay promoción del día",
                promotion: null
            });
        }

        const resolver = buildDiscountResolver([promotion]);

        const products = promotion.productIds
            .filter(product => product.isAvailable)
            .map(product => {
                const decorated =
                    decorateProduct(product, resolver);

                return {
                    _id: decorated._id,
                    name: decorated.name,
                    price: decorated.price,
                    image: decorated.images?.[0] || "",
                    discountedPrice:
                        decorated.discountedPrice ??
                        decorated.price
                };
            });

        return res.status(200).json({
            message: "Promoción del día obtenida correctamente",
            promotion: {
                _id: promotion._id,
                code: promotion.code,
                name: promotion.name,
                description: promotion.description,
                discountType: promotion.discountType,
                discountValue: promotion.discountValue,
                maximumDiscount: promotion.maximumDiscount,
                endDate: promotion.endDate,
                products
            }
        });

    } catch (error) {

        console.error("Get promo of the day error:", error);

        return res.status(500).json({
            message: "Error al obtener la promoción del día",
            error: error.message
        });

    }

};

// ===================================
// SET / UNSET PROMO OF THE DAY (ADMIN)
// ===================================
// Body: { isPromoOfTheDay: true | false }
// Al marcar una, se desmarca la anterior (solo hay una).
export const setPromoOfTheDay = async (req, res) => {

    try {

        const { isPromoOfTheDay } = req.body;

        if (typeof isPromoOfTheDay !== "boolean") {
            return res.status(400).json({
                message: "isPromoOfTheDay debe ser true o false"
            });
        }

        const promotion =
            await Promotion.findById(req.params.id);

        if (!promotion) {
            return res.status(404).json({
                message: "Promoción no encontrada"
            });
        }

        if (isPromoOfTheDay) {

            if (!promotion.isActive) {
                return res.status(400).json({
                    message:
                        "Activa la promoción antes de convertirla en la promoción del día"
                });
            }

            // Primero se libera la anterior: el índice parcial único
            // no permite dos marcadas al mismo tiempo.
            await Promotion.updateMany(
                {
                    _id: { $ne: promotion._id },
                    isPromoOfTheDay: true
                },
                { $set: { isPromoOfTheDay: false } }
            );
        }

        promotion.isPromoOfTheDay = isPromoOfTheDay;

        await promotion.save();

        return res.status(200).json({
            message: isPromoOfTheDay
                ? "Promoción establecida como promoción del día"
                : "La promoción ya no es la promoción del día",
            promotion
        });

    } catch (error) {

        console.error("Set promo of the day error:", error);

        return res.status(500).json({
            message: "Error al actualizar la promoción del día",
            error: error.message
        });

    }

};
