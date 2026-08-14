import jwt from "jsonwebtoken";

// ===================================
// VERIFY JWT TOKEN
// ===================================
export const verifyToken = (req, res, next) => {

    try {

        const authHeader =
            req.headers.authorization;

        if (!authHeader) {

            return res.status(401).json({

                message: "Access token is required"

            });

        }

        const token =
            authHeader.startsWith("Bearer ")
                ? authHeader.split(" ")[1]
                : null;

        if (!token) {

            return res.status(401).json({

                message: "Invalid authorization format"

            });

        }

        const decoded = jwt.verify(

            token,
            process.env.JWT_SECRET

        );

        req.user = decoded;

        next();

    } catch (error) {

        return res.status(401).json({

            message: "Invalid or expired token"

        });

    }

};

// ===================================
// ADMIN ONLY
// ===================================
export const adminOnly = (req, res, next) => {

    if (!req.user) {

        return res.status(401).json({

            message: "Authentication required"

        });

    }

    if (req.user.role !== "ADMIN") {

        return res.status(403).json({

            message: "Admin access required"

        });

    }

    next();

};