import multer from "multer";
import { CloudinaryStorage } from "multer-storage-cloudinary";

import cloudinary from "../config/cloudinary.js";

// ===================================
// CLOUDINARY STORAGE
// ===================================

const storage = new CloudinaryStorage({

    cloudinary,

    params: {

        folder: "cafe-mistico/productos",

        allowed_formats: [
            "jpg",
            "jpeg",
            "png",
            "avif",
            "webp"
        ],

        transformation: [
            {
                width: 800,
                height: 800,
                crop: "limit"
            }
        ]

    }

});

// ===================================
// IMAGE FILTER
// ===================================

const imageFilter = (req, file, cb) => {

    const allowedTypes = [
        "image/jpeg",
        "image/png",
        "image/webp",
        "image/avif"
    ];

    if (allowedTypes.includes(file.mimetype)) {

        cb(null, true);

    } else {

        cb(
            new Error(
                "Only JPG, JPEG, PNG, WEBP and AVIF images are allowed"
            ),
            false
        );

    }

};

// ===================================
// MULTER UPLOAD
// ===================================

export const upload = multer({

    storage,

    fileFilter: imageFilter,

    limits: {
        fileSize: 5 * 1024 * 1024
    }

});