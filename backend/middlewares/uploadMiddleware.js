import multer from "multer";
import { CloudinaryStorage } from "multer-storage-cloudinary";

import cloudinary from "../config/cloudinary.js";

// ===================================
// CLOUDINARY STORAGE
// ===================================

const storage = new CloudinaryStorage({
  cloudinary,

  params: {
    folder: "somoscafeapp/productos",

    allowed_formats: ["jpg", "jpeg", "png", "avif", "webp"],

    transformation: [
      {
        width: 800,
        height: 800,
        crop: "limit",
      },
    ],
  },
});

// ===================================
// IMAGE FILTER
// ===================================

const imageFilter = (req, file, cb) => {
  const allowedTypes = ["image/jpeg", "image/png", "image/webp", "image/avif"];

  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(
      new Error("Only JPG, JPEG, PNG, WEBP and AVIF images are allowed"),
      false,
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
    fileSize: 5 * 1024 * 1024,
  },
});

// ===================================
// PAYMENT PROOF UPLOAD
// ===================================
// Comprobantes de transferencia (capturas de pantalla de la app
// bancaria). Van a su propia carpeta y NO se recortan a 800x800 como
// las fotos de producto: una captura reducida de más se vuelve
// ilegible y el admin no podría validar el pago.

const proofStorage = new CloudinaryStorage({
  cloudinary,

  params: {
    folder: "somoscafeapp/comprobantes",

    allowed_formats: ["jpg", "jpeg", "png", "avif", "webp"],

    transformation: [
      {
        width: 1600,
        height: 1600,
        crop: "limit",
      },
    ],
  },
});

const PROOF_MAX_SIZE_MB = 8;

const uploadProof = multer({
  storage: proofStorage,

  fileFilter: imageFilter,

  limits: {
    fileSize: PROOF_MAX_SIZE_MB * 1024 * 1024,
  },
});

// Igual que upload.single("imagen"), pero los errores de multer
// (archivo muy pesado o formato inválido) se devuelven como JSON
// para que la app pueda mostrar el motivo.
export const uploadProofImage = (req, res, next) => {
  uploadProof.single("imagen")(req, res, (error) => {
    if (!error) {
      return next();
    }

    const message =
      error.code === "LIMIT_FILE_SIZE"
        ? `Payment proof cannot exceed ${PROOF_MAX_SIZE_MB}MB`
        : error.message || "Invalid payment proof image";

    return res.status(400).json({ message });
  });
};

// ===================================
// EVENT IMAGE UPLOAD
// ===================================
// Imagen del evento (pop-up y detalle). Carpeta propia; se limita a
// 1200px para que el pop-up cargue rápido.

const eventStorage = new CloudinaryStorage({
  cloudinary,

  params: {
    folder: "somoscafeapp/eventos",

    allowed_formats: ["jpg", "jpeg", "png", "avif", "webp"],

    transformation: [
      {
        width: 1200,
        height: 1200,
        crop: "limit",
      },
    ],
  },
});

const uploadEvent = multer({
  storage: eventStorage,

  fileFilter: imageFilter,

  limits: {
    fileSize: 5 * 1024 * 1024,
  },
});

// Igual que upload.single("imagen"), pero los errores de multer se
// devuelven como JSON con un mensaje que la app sabe traducir
// ("Only JPG..." / "File too large").
export const uploadEventImage = (req, res, next) => {
  uploadEvent.single("imagen")(req, res, (error) => {
    if (!error) {
      return next();
    }

    const message =
      error.code === "LIMIT_FILE_SIZE"
        ? "File too large (max 5MB)"
        : error.message || "Invalid event image";

    return res.status(400).json({ message });
  });
};

// ===================================
// PROFILE PHOTO UPLOAD
// ===================================
// Foto de perfil del usuario. Carpeta propia; se recorta a un cuadrado
// de 400x400 centrado en la cara (si no hay, en el centro), suficiente
// para mostrarla como avatar sin gastar datos.

const avatarStorage = new CloudinaryStorage({
  cloudinary,

  params: {
    folder: "somoscafeapp/perfiles",

    allowed_formats: ["jpg", "jpeg", "png", "avif", "webp"],

    transformation: [
      {
        width: 400,
        height: 400,
        crop: "fill",
        gravity: "face",
      },
    ],
  },
});

const uploadAvatar = multer({
  storage: avatarStorage,

  fileFilter: imageFilter,

  limits: {
    fileSize: 5 * 1024 * 1024,
  },
});

// Igual que upload.single("imagen"), pero los errores de multer se
// devuelven como JSON con un mensaje que la app sabe traducir.
export const uploadAvatarImage = (req, res, next) => {
  uploadAvatar.single("imagen")(req, res, (error) => {
    if (!error) {
      return next();
    }

    const message =
      error.code === "LIMIT_FILE_SIZE"
        ? "File too large (max 5MB)"
        : error.message || "Invalid profile image";

    return res.status(400).json({ message });
  });
};
