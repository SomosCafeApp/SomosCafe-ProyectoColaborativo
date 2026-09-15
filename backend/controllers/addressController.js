import Address from "../models/addressModel.js";

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
            isDefault
        } = req.body;

        // ===================================
        // VALIDATE REQUIRED DATA
        // ===================================

        if (
            !label ||
            !recipientName ||
            !phone ||
            !address ||
            !city
        ) {

            return res.status(400).json({

                message:
                    "Label, recipientName, phone, address and city are required"

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

            city:
                city.trim(),

            neighborhood:
                neighborhood
                    ? neighborhood.trim()
                    : "",

            additionalInfo:
                additionalInfo
                    ? additionalInfo.trim()
                    : "",

            isDefault:
                shouldBeDefault

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
                "Address created successfully",

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
                "Error creating address",

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
                "Addresses retrieved successfully",

            addresses

        });

    } catch (error) {

        console.error(
            "Get addresses error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving addresses",

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
                    "Address not found"

            });

        }

        return res.status(200).json({

            message:
                "Address retrieved successfully",

            address

        });

    } catch (error) {

        console.error(
            "Get address error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving address",

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
            isDefault
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
                    "Address not found"

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
                    "Label cannot be empty"

            });

        }

        if (
            recipientName !== undefined &&
            !recipientName.trim()
        ) {

            return res.status(400).json({

                message:
                    "Recipient name cannot be empty"

            });

        }

        if (
            phone !== undefined &&
            !phone.trim()
        ) {

            return res.status(400).json({

                message:
                    "Phone cannot be empty"

            });

        }

        if (
            address !== undefined &&
            !address.trim()
        ) {

            return res.status(400).json({

                message:
                    "Address cannot be empty"

            });

        }

        if (
            city !== undefined &&
            !city.trim()
        ) {

            return res.status(400).json({

                message:
                    "City cannot be empty"

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

        // ===================================
        // SAVE
        // ===================================

        await existingAddress.save();

        return res.status(200).json({

            message:
                "Address updated successfully",

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
                "Error updating address",

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
                    "Address not found"

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
                "Address deleted successfully"

        });

    } catch (error) {

        console.error(
            "Delete address error:",
            error
        );

        return res.status(500).json({

            message:
                "Error deleting address",

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
                    "Address not found"

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
                "Default address updated successfully",

            address

        });

    } catch (error) {

        console.error(
            "Set default address error:",
            error
        );

        return res.status(500).json({

            message:
                "Error setting default address",

            error:
                error.message

        });

    }

};