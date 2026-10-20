// Misma política que usa recoveryController.js y que valida la app:
// mínimo 6 caracteres, número, mayúscula, minúscula y carácter especial.
// Devuelve el mensaje del primer requisito que falla, o null si es válida.
export const validatePasswordPolicy = (password) => {

    if (typeof password !== "string" || password.length < 6) {
        return "La contraseña debe tener al menos 6 caracteres";
    }

    if (password.length > 100) {
        return "La contraseña no puede superar los 100 caracteres";
    }

    if (!/[0-9]/.test(password)) {
        return "La contraseña debe contener al menos un número";
    }

    if (!/[A-Z]/.test(password)) {
        return "La contraseña debe contener al menos una letra mayúscula";
    }

    if (!/[a-z]/.test(password)) {
        return "La contraseña debe contener al menos una letra minúscula";
    }

    if (!/[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]/.test(password)) {
        return "La contraseña debe contener al menos un carácter especial";
    }

    return null;

};