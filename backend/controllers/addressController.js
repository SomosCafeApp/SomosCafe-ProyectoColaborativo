import Address from "../models/addressModel.js";

// La app solo opera en Garzón, Huila.
const DEFAULT_CITY = "Garzón";

// ===================================
// CREATE ADDRESS
// ===================================

export const createAddress = async (req, res) => {

    try {

        const {
            label,
            recipientName,
            phone,
            address,
            city,
            neighborhood,
            additionalInfo,
            isDefault,
            latitude,
            longitude
        } = req.body;

        // ===================================
        // VALIDATE REQUIRED DATA
        // ===================================

        if (
            !label ||
            !recipientName ||
            !phone ||
            !address
        ) {

            return res.status(400).json({

                message:
                    "Label, recipientName, phone y address son obligatorios"

            });

        }

        // ===================================
        // CHECK IF THIS IS THE FIRST ADDRESS
        // ===================================

        const existingAddresses =
            await Address.countDocuments({

                userId: req.user.id

            });

        // ===================================
        // DETERMINE DEFAULT ADDRESS
        // ===================================

        let shouldBeDefault =
            isDefault === true;

        // First address becomes default
        if (existingAddresses === 0) {

            shouldBeDefault = true;

        }

        // ===================================
        // IF DEFAULT, REMOVE PREVIOUS DEFAULT
        // ===================================

        if (shouldBeDefault) {

            await Address.updateMany(

                {
                    userId: req.user.id
                },

                {
                    $set: {
                        isDefault: false
                    }
                }

            );

        }

        // ===================================
        // CREATE ADDRESS
        // ===================================

        const newAddress = new Address({

            userId: req.user.id,

            label:
                label.trim(),

            recipientName:
                recipientName.trim(),

            phone:
                phone.trim(),

            address:
                address.trim(),

            // Si el cliente no envía ciudad se usa la predeterminada.
            city:
                (typeof city === "string" && city.trim())
                    ? city.trim()
                    : DEFAULT_CITY,

            neighborhood:
                neighborhood
                    ? neighborhood.trim()
                    : "",

            additionalInfo:
                additionalInfo
                    ? additionalInfo.trim()
                    : "",

            isDefault:
                shouldBeDefault,

            latitude:
                typeof latitude === "number"
                    ? latitude
                    : undefined,

            longitude:
                typeof longitude === "number"
                    ? longitude
                    : undefined

        });

        // ===================================
        // SAVE
        // ===================================

        await newAddress.save();

        // ===================================
        // RESPONSE
        // ===================================

        return res.status(201).json({

            message:
                "Dirección creada correctamente",

            address:
                newAddress

        });

    } catch (error) {

        console.error(
            "Create address error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al crear la dirección",

            error:
                error.message

        });

    }

};


// ===================================
// GET USER ADDRESSES
// ===================================

export const getAddresses = async (req, res) => {

    try {

        const addresses =
            await Address.find({

                userId: req.user.id

            }).sort({

                isDefault: -1,

                createdAt: -1

            });

        return res.status(200).json({

            message:
                "Direcciones obtenidas correctamente",

            addresses

        });

    } catch (error) {

        console.error(
            "Get addresses error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al obtener las direcciones",

            error:
                error.message

        });

    }

};


// ===================================
// GET ADDRESS BY ID
// ===================================

export const getAddressById = async (req, res) => {

    try {

        const address =
            await Address.findOne({

                _id: req.params.id,

                userId: req.user.id

            });

        if (!address) {

            return res.status(404).json({

                message:
                    "Dirección no encontrada"

            });

        }

        return res.status(200).json({

            message:
                "Dirección obtenida correctamente",

            address

        });

    } catch (error) {

        console.error(
            "Get address error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al obtener la dirección",

            error:
                error.message

        });

    }

};


// ===================================
// UPDATE ADDRESS
// ===================================

export const updateAddress = async (req, res) => {

    try {

        const {
            label,
            recipientName,
            phone,
            address,
            city,
            neighborhood,
            additionalInfo,
            isDefault,
            latitude,
            longitude
        } = req.body;

        // ===================================
        // FIND USER ADDRESS
        // ===================================

        const existingAddress =
            await Address.findOne({

                _id: req.params.id,

                userId: req.user.id

            });

        if (!existingAddress) {

            return res.status(404).json({

                message:
                    "Dirección no encontrada"

            });

        }

        // ===================================
        // VALIDATE REQUIRED DATA
        // ===================================

        if (
            label !== undefined &&
            !label.trim()
        ) {

            return res.status(400).json({

                message:
                    "La etiqueta no puede estar vacía"

            });

        }

        if (
            recipientName !== undefined &&
            !recipientName.trim()
        ) {

            return res.status(400).json({

                message:
                    "El nombre del destinatario no puede estar vacío"

            });

        }

        if (
            phone !== undefined &&
            !phone.trim()
        ) {

            return res.status(400).json({

                message:
                    "El teléfono no puede estar vacío"

            });

        }

        if (
            address !== undefined &&
            !address.trim()
        ) {

            return res.status(400).json({

                message:
                    "La dirección no puede estar vacía"

            });

        }

        if (
            city !== undefined &&
            !city.trim()
        ) {

            return res.status(400).json({

                message:
                    "La ciudad no puede estar vacía"

            });

        }

        // ===================================
        // UPDATE DEFAULT ADDRESS
        // ===================================

        if (isDefault === true) {

            await Address.updateMany(

                {
                    userId: req.user.id,

                    _id: {
                        $ne: req.params.id
                    }
                },

                {
                    $set: {
                        isDefault: false
                    }
                }

            );

        }

        // ===================================
        // UPDATE FIELDS
        // ===================================

        if (label !== undefined) {

            existingAddress.label =
                label.trim();

        }

        if (recipientName !== undefined) {

            existingAddress.recipientName =
                recipientName.trim();

        }

        if (phone !== undefined) {

            existingAddress.phone =
                phone.trim();

        }

        if (address !== undefined) {

            existingAddress.address =
                address.trim();

        }

        if (city !== undefined) {

            existingAddress.city =
                city.trim();

        }

        if (neighborhood !== undefined) {

            existingAddress.neighborhood =
                neighborhood.trim();

        }

        if (additionalInfo !== undefined) {

            existingAddress.additionalInfo =
                additionalInfo.trim();

        }

        if (isDefault !== undefined) {

            existingAddress.isDefault =
                isDefault;

        }

        if (typeof latitude === "number") {

            existingAddress.latitude =
                latitude;

        }

        if (typeof longitude === "number") {

            existingAddress.longitude =
                longitude;

        }

        // ===================================
        // SAVE
        // ===================================

        await existingAddress.save();

        return res.status(200).json({

            message:
                "Dirección actualizada correctamente",

            address:
                existingAddress

        });

    } catch (error) {

        console.error(
            "Update address error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al actualizar la dirección",

            error:
                error.message

        });

    }

};


// ===================================
// DELETE ADDRESS
// ===================================

export const deleteAddress = async (req, res) => {

    try {

        const address =
            await Address.findOne({

                _id: req.params.id,

                userId: req.user.id

            });

        if (!address) {

            return res.status(404).json({

                message:
                    "Dirección no encontrada"

            });

        }

        const wasDefault =
            address.isDefault;

        // ===================================
        // DELETE
        // ===================================

        await Address.findByIdAndDelete(
            req.params.id
        );

        // ===================================
        // ASSIGN NEW DEFAULT ADDRESS
        // ===================================

        if (wasDefault) {

            const nextAddress =
                await Address.findOne({

                    userId: req.user.id

                }).sort({

                    createdAt: -1

                });

            if (nextAddress) {

                nextAddress.isDefault = true;

                await nextAddress.save();

            }

        }

        return res.status(200).json({

            message:
                "Dirección eliminada correctamente"

        });

    } catch (error) {

        console.error(
            "Delete address error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al eliminar la dirección",

            error:
                error.message

        });

    }

};


// ===================================
// SET DEFAULT ADDRESS
// ===================================

export const setDefaultAddress = async (req, res) => {

    try {

        // ===================================
        // FIND ADDRESS
        // ===================================

        const address =
            await Address.findOne({

                _id: req.params.id,

                userId: req.user.id

            });

        if (!address) {

            return res.status(404).json({

                message:
                    "Dirección no encontrada"

            });

        }

        // ===================================
        // REMOVE PREVIOUS DEFAULT
        // ===================================

        await Address.updateMany(

            {
                userId: req.user.id
            },

            {
                $set: {
                    isDefault: false
                }
            }

        );

        // ===================================
        // SET NEW DEFAULT
        // ===================================

        address.isDefault = true;

        await address.save();

        return res.status(200).json({

            message:
                "Dirección principal actualizada correctamente",

            address

        });

    } catch (error) {

        console.error(
            "Set default address error:",
            error
        );

        return res.status(500).json({

            message:
                "Error al establecer la dirección principal",

            error:
                error.message

        });

    }

};