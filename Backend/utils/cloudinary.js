import cloudinary from "../config/cloudinary.js";

// ===================================
// EXTRACT CLOUDINARY PUBLIC ID
// ===================================

export const extractPublicId = (imageUrl) => {

    if (!imageUrl) {
        return null;
    }

    const match = imageUrl.match(
        /\/upload\/(?:v\d+\/)?(.+)\.[a-zA-Z0-9]+$/
    );

    return match
        ? match[1]
        : null;

};

// ===================================
// DELETE IMAGE FROM CLOUDINARY
// ===================================

export const deleteCloudinaryImage = async (imageUrl) => {

    const publicId = extractPublicId(imageUrl);

    if (!publicId) {
        return;
    }

    try {

        await cloudinary.uploader.destroy(
            publicId
        );

        console.log(
            `Cloudinary image deleted: ${publicId}`
        );

    } catch (error) {

        console.error(
            "Error deleting Cloudinary image:",
            error.message
        );

    }

};