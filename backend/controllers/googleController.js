import { OAuth2Client } from "google-auth-library";
import jwt from "jsonwebtoken";
import User from "../models/userModel.js";

// ===================================
// CLIENTE DE GOOGLE
// ===================================

const client = new OAuth2Client(
    process.env.GOOGLE_CLIENT_ID
);

// ===================================
// CONFIGURACIÓN
// ===================================

const GOOGLE_USER_INFO_URL =
    "https://www.googleapis.com/oauth2/v3/userinfo";

// ===================================
// OBTENER INFORMACIÓN DEL USUARIO
// ===================================

const getGoogleUserData = async (idToken) => {

    // ===================================
    // DETECTAR TIPO DE TOKEN
    // ===================================

    // Los ID tokens de Google normalmente
    // tienen formato JWT:
    //
    // header.payload.signature
    //
    // Los access tokens pueden tener otro formato.

    const isJwt =
        idToken.split(".").length === 3 &&
        !idToken.startsWith("ya29.");

    // ===================================
    // GOOGLE ID TOKEN
    // ===================================

    if (isJwt) {

        const ticket =
            await client.verifyIdToken({

                idToken,

                audience:
                    process.env.GOOGLE_CLIENT_ID

            });

        const payload =
            ticket.getPayload();

        if (!payload) {

            throw new Error(
                "Google token payload not found"
            );

        }

        return {

            googleId:
                payload.sub,

            email:
                payload.email,

            name:
                payload.given_name ||
                payload.name ||
                "User",

            lastName:
                payload.family_name ||
                "",

            profileImage:
                payload.picture ||
                ""

        };

    }

    // ===================================
    // GOOGLE ACCESS TOKEN
    // ===================================

    const response =
        await fetch(
            GOOGLE_USER_INFO_URL,
            {
                headers: {
                    Authorization:
                        `Bearer ${idToken}`
                }
            }
        );

    if (!response.ok) {

        throw new Error(
            "Invalid or expired Google access token"
        );

    }

    const userData =
        await response.json();

    if (!userData.sub) {

        throw new Error(
            "Google user ID was not provided"
        );

    }

    return {

        googleId:
            userData.sub,

        email:
            userData.email,

        name:
            userData.given_name ||
            userData.name ||
            "User",

        lastName:
            userData.family_name ||
            "",

        profileImage:
            userData.picture ||
            ""

    };

};

// ===================================
// LOGIN WITH GOOGLE
// ===================================

export const loginWithGoogle =
    async (req, res) => {

        try {

            // ===================================
            // 1. VALIDAR TOKEN
            // ===================================

            const {
                idToken
            } = req.body;

            if (
                !idToken ||
                typeof idToken !== "string"
            ) {

                return res.status(400).json({

                    message:
                        "Google ID token is required"

                });

            }

            // ===================================
            // 2. VALIDAR CONFIGURACIÓN
            // ===================================

            if (
                !process.env.GOOGLE_CLIENT_ID
            ) {

                console.error(
                    "GOOGLE_CLIENT_ID is not configured"
                );

                return res.status(500).json({

                    message:
                        "Google authentication is not configured"

                });

            }

            if (
                !process.env.JWT_SECRET
            ) {

                console.error(
                    "JWT_SECRET is not configured"
                );

                return res.status(500).json({

                    message:
                        "Authentication service is not configured"

                });

            }

            // ===================================
            // 3. OBTENER DATOS DE GOOGLE
            // ===================================

            const googleUser =
                await getGoogleUserData(
                    idToken
                );

            // ===================================
            // 4. VALIDAR EMAIL
            // ===================================

            if (
                !googleUser.email
            ) {

                return res.status(400).json({

                    message:
                        "Google did not provide a valid email"

                });

            }

            // ===================================
            // 5. NORMALIZAR EMAIL
            // ===================================

            const normalizedEmail =
                googleUser.email
                    .trim()
                    .toLowerCase();

            // ===================================
            // 6. BUSCAR USUARIO POR EMAIL
            // ===================================

            let user =
                await User.findOne({

                    email:
                        normalizedEmail

                });

            // ===================================
            // 7. USUARIO EXISTENTE
            // ===================================

            if (user) {

                // ===================================
                // CUENTA DESACTIVADA
                // ===================================

                if (!user.isActive) {

                    return res.status(403).json({

                        message:
                            "User account is inactive"

                    });

                }

                // ===================================
                // VALIDAR GOOGLE ID EXISTENTE
                // ===================================

                if (
                    user.googleId &&
                    user.googleId !==
                        googleUser.googleId
                ) {

                    return res.status(409).json({

                        message:
                            "This email is already linked to another Google account"

                    });

                }

                // ===================================
                // VINCULAR CUENTA CON GOOGLE
                // ===================================

                if (!user.googleId) {

                    user.googleId =
                        googleUser.googleId;

                }

                // ===================================
                // VERIFICAR EMAIL
                // ===================================

                // Google ya verificó la identidad
                // asociada al correo electrónico.

                if (!user.isEmailVerified) {

                    user.isEmailVerified =
                        true;

                }

                // ===================================
                // ACTUALIZAR FOTO
                // ===================================

                if (
                    googleUser.profileImage &&
                    !user.profileImage
                ) {

                    user.profileImage =
                        googleUser.profileImage;

                }

                // ===================================
                // GUARDAR CAMBIOS
                // ===================================

                await user.save();

            }

            // ===================================
            // 8. CREAR NUEVO USUARIO
            // ===================================

            else {

                user =
                    await User.create({

                        name:
                            googleUser.name,

                        lastName:
                            googleUser.lastName,

                        email:
                            normalizedEmail,

                        // Los usuarios de Google
                        // no utilizan contraseña local.

                        password:
                            null,

                        googleId:
                            googleUser.googleId,

                        profileImage:
                            googleUser.profileImage,

                        role:
                            "USER",

                        points:
                            0,

                        // Google ya autenticó
                        // el correo del usuario.

                        isEmailVerified:
                            true,

                        isActive:
                            true

                    });

            }

            // ===================================
            // 9. GENERAR JWT PROPIO
            // ===================================

            const token =
                jwt.sign(

                    {

                        id:
                            user._id,

                        userId:
                            user._id,

                        email:
                            user.email,

                        role:
                            user.role

                    },

                    process.env.JWT_SECRET,

                    {

                        expiresIn:
                            "1h"

                    }

                );

            // ===================================
            // 10. RESPUESTA
            // ===================================

            return res.status(200).json({

                message:
                    "Google login successful",

                token,

                user: {

                    id:
                        user._id,

                    name:
                        user.name,

                    lastName:
                        user.lastName,

                    email:
                        user.email,

                    role:
                        user.role,

                    phone:
                        user.phone,

                    points:
                        user.points,

                    profileImage:
                        user.profileImage,

                    isEmailVerified:
                        user.isEmailVerified,

                    isActive:
                        user.isActive

                }

            });

        } catch (error) {

            console.error(
                "Google authentication error:",
                error
            );

            // ===================================
            // TOKEN INVÁLIDO
            // ===================================

            if (
                error.message?.includes(
                    "Token used too late"
                ) ||
                error.message?.includes(
                    "Invalid token"
                ) ||
                error.message?.toLowerCase().includes(
                    "invalid"
                ) ||
                error.message?.toLowerCase().includes(
                    "expired"
                )
            ) {

                return res.status(401).json({

                    message:
                        "Invalid or expired Google token"

                });

            }

            // ===================================
            // ERROR GENERAL
            // ===================================

            return res.status(500).json({

                message:
                    "Error authenticating with Google"

            });

        }

    };