// ===================================
// AVATARES DE SOMOS CAFÉ
// ===================================
// Única fuente de verdad de los avatares predefinidos. El cliente solo
// envía la CLAVE (por ejemplo "grano"); el dibujo vive en la app.
//
// avatarType:
//   "none"   -> sin avatar: la app muestra las iniciales.
//   "preset" -> avatar predefinido (avatarPreset = una de las claves).
//   "photo"  -> foto propia (profileImage = URL de Cloudinary o Google).

export const AVATAR_TYPES = ["none", "preset", "photo"];

export const AVATAR_PRESETS = [
    { key: "grano", name: "Grano de café" },
    { key: "taza", name: "Taza" },
    { key: "barista", name: "Barista" },
    { key: "latte", name: "Latte art" },
    { key: "cafetera", name: "Cafetera" }
];

export const AVATAR_PRESET_KEYS = AVATAR_PRESETS.map(a => a.key);

export const isValidPreset = (key) =>
    typeof key === "string" && AVATAR_PRESET_KEYS.includes(key);

// Resuelve el tipo real de avatar de un usuario. Las cuentas creadas
// antes de existir los avatares no tienen avatarType: si traen una
// foto se tratan como "photo"; si no, como "none".
export const resolveAvatarType = (user) => {

    if (user?.avatarType === "preset" && isValidPreset(user.avatarPreset)) {
        return "preset";
    }

    if (user?.avatarType === "photo" && user.profileImage) {
        return "photo";
    }

    if (user?.avatarType === "none") {
        return "none";
    }

    // Sin tipo guardado (cuenta anterior) o dato inconsistente.
    return user?.profileImage ? "photo" : "none";
};

// Campos de avatar que se agregan a TODA respuesta que describe a un
// usuario (login, registro, perfil, reseñas, comentarios, chat).
export const avatarFields = (user) => {

    const avatarType = resolveAvatarType(user);

    return {
        avatarType,
        avatarPreset: avatarType === "preset" ? user.avatarPreset : "",
        profileImage: avatarType === "photo" ? (user?.profileImage || "") : ""
    };
};
