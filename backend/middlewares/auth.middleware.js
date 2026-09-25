import jwt from "jsonwebtoken";

// ===================================
// VERIFY JWT TOKEN
// ===================================

export const verifyToken = (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader) {
            return res.status(401).json({
                message: "Access token is required"
            });
        }

        if (!authHeader.startsWith("Bearer ")) {
            return res.status(401).json({
                message: "Invalid authorization format"
            });
        }

        const token = authHeader.split(" ")[1];

        if (!token) {
            return res.status(401).json({
                message: "Access token is required"
            });
        }

        const decoded = jwt.verify(
            token,
            process.env.JWT_SECRET
        );

        req.user = decoded;
        next();
    } catch (error) {
        console.error(
            "Token verification error:",
            error.message
        );

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

// ===================================
// OPTIONAL AUTH (no bloquea invitados)
// ===================================
// Si viene un token válido, adjunta req.user normalmente.
// Si no viene token (o es inválido/expiró), continúa igual
// pero con req.user = null, para rutas que deben funcionar
// tanto para usuarios logueados como anónimos (ej: el chat).

export const optionalAuth = (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith("Bearer ")) {
            req.user = null;
            return next();
        }

        const token = authHeader.split(" ")[1];

        if (!token) {
            req.user = null;
            return next();
        }

        const decoded = jwt.verify(
            token,
            process.env.JWT_SECRET
        );

        req.user = decoded;
        next();
    } catch (error) {
        // Token inválido/expirado: seguimos como invitado en vez de bloquear.
        req.user = null;
        next();
    }
};