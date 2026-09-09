import Point from "../models/pointsModel.js";
import User from "../models/userModel.js";

// ===================================
// GET USER POINT BALANCE
// ===================================
export const getUserPoints = async (req, res) => {

    try {

        const { userId } = req.params;

        // FIND USER
        const user = await User.findById(
            userId
        ).select(
            "name lastName email points"
        );

        if (!user) {

            return res.status(404).json({

                message: "User not found"

            });

        }

        return res.status(200).json({

            message:
                "User points retrieved successfully",

            points: user.points

        });

    } catch (error) {

        console.error(
            "Get user points error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving user points",

            error: error.message

        });

    }

};

// ===================================
// GET USER POINT HISTORY
// ===================================
export const getPointHistory = async (req, res) => {

    try {

        const { userId } = req.params;

        // CHECK USER
        const user = await User.findById(
            userId
        );

        if (!user) {

            return res.status(404).json({

                message: "User not found"

            });

        }

        // GET HISTORY
        const points = await Point.find({

            userId

        })
            .populate(
                "orderId",
                "_id totalAmount status"
            )
            .sort({
                createdAt: -1
            });

        return res.status(200).json({

            message:
                "Point history retrieved successfully",

            points

        });

    } catch (error) {

        console.error(
            "Get point history error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving point history",

            error: error.message

        });

    }

};

// ===================================
// ADD POINTS
// ===================================
export const addPoints = async (req, res) => {

    try {

        const {
            userId,
            orderId,
            amount,
            type,
            description
        } = req.body;

        // VALIDATE REQUIRED DATA
        if (
            !userId ||
            amount === undefined
        ) {

            return res.status(400).json({

                message:
                    "userId and amount are required"

            });

        }

        // VALIDATE AMOUNT
        if (amount <= 0) {

            return res.status(400).json({

                message:
                    "Points amount must be greater than zero"

            });

        }

        // VALIDATE TYPE
        const validTypes = [
            "purchase",
            "bonus",
            "redeemed",
            "adjustment"
        ];

        const pointType =
            type || "purchase";

        if (
            !validTypes.includes(pointType)
        ) {

            return res.status(400).json({

                message:
                    "Invalid point type"

            });

        }

        // FIND USER
        const user = await User.findById(
            userId
        );

        if (!user) {

            return res.status(404).json({

                message: "User not found"

            });

        }

        // UPDATE USER BALANCE
        user.points += amount;

        await user.save();

        // CREATE POINT HISTORY
        const newPoint = new Point({

            userId,

            orderId:
                orderId || null,

            amount,

            type: pointType,

            description:
                description || ""

        });

        await newPoint.save();

        return res.status(201).json({

            message:
                "Points added successfully",

            pointsAdded: amount,

            currentBalance:
                user.points,

            point: newPoint

        });

    } catch (error) {

        console.error(
            "Add points error:",
            error
        );

        return res.status(500).json({

            message:
                "Error adding points",

            error: error.message

        });

    }

};

// ===================================
// REDEEM POINTS
// ===================================
export const redeemPoints = async (req, res) => {

    try {

        const {
            userId,
            amount,
            description
        } = req.body;

        // VALIDATE REQUIRED DATA
        if (
            !userId ||
            amount === undefined
        ) {

            return res.status(400).json({

                message:
                    "userId and amount are required"

            });

        }

        // VALIDATE AMOUNT
        if (amount <= 0) {

            return res.status(400).json({

                message:
                    "Points amount must be greater than zero"

            });

        }

        // FIND USER
        const user = await User.findById(
            userId
        );

        if (!user) {

            return res.status(404).json({

                message: "User not found"

            });

        }

        // CHECK BALANCE
        if (user.points < amount) {

            return res.status(400).json({

                message:
                    "Insufficient points"

            });

        }

        // SUBTRACT POINTS
        user.points -= amount;

        await user.save();

        // CREATE REDEMPTION HISTORY
        const newPoint = new Point({

            userId,

            amount: -amount,

            type: "redeemed",

            description:
                description ||
                "Points redeemed"

        });

        await newPoint.save();

        return res.status(201).json({

            message:
                "Points redeemed successfully",

            pointsRedeemed: amount,

            currentBalance:
                user.points,

            point: newPoint

        });

    } catch (error) {

        console.error(
            "Redeem points error:",
            error
        );

        return res.status(500).json({

            message:
                "Error redeeming points",

            error: error.message

        });

    }

};

// ===================================
// ADJUST USER POINTS
// ===================================
export const adjustPoints = async (req, res) => {

    try {

        const {
            userId,
            amount,
            description
        } = req.body;

        // VALIDATE REQUIRED DATA
        if (
            !userId ||
            amount === undefined
        ) {

            return res.status(400).json({

                message:
                    "userId and amount are required"

            });

        }

        // FIND USER
        const user = await User.findById(
            userId
        );

        if (!user) {

            return res.status(404).json({

                message: "User not found"

            });

        }

        // CALCULATE NEW BALANCE
        const newBalance =
            user.points + amount;

        // PREVENT NEGATIVE BALANCE
        if (newBalance < 0) {

            return res.status(400).json({

                message:
                    "User points cannot be negative"

            });

        }

        // UPDATE USER
        user.points =
            newBalance;

        await user.save();

        // CREATE HISTORY
        const newPoint = new Point({

            userId,

            amount,

            type: "adjustment",

            description:
                description ||
                "Points balance adjustment"

        });

        await newPoint.save();

        return res.status(201).json({

            message:
                "Points adjusted successfully",

            adjustment: amount,

            currentBalance:
                user.points,

            point: newPoint

        });

    } catch (error) {

        console.error(
            "Adjust points error:",
            error
        );

        return res.status(500).json({

            message:
                "Error adjusting points",

            error: error.message

        });

    }

};