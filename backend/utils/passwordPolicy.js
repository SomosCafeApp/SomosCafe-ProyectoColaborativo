// Misma política que usa recoveryController.js y que valida la app:
// mínimo 6 caracteres, número, mayúscula, minúscula y carácter especial.
// Devuelve el mensaje del primer requisito que falla, o null si es válida.
export const validatePasswordPolicy = (password) => {

    if (typeof password !== "string" || password.length < 6) {
        return "Password must contain at least 6 characters";
    }

    if (password.length > 100) {
        return "Password cannot exceed 100 characters";
    }

    if (!/[0-9]/.test(password)) {
        return "Password must contain at least one number";
    }

    if (!/[A-Z]/.test(password)) {
        return "Password must contain at least one uppercase letter";
    }

    if (!/[a-z]/.test(password)) {
        return "Password must contain at least one lowercase letter";
    }

    if (!/[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]/.test(password)) {
        return "Password must contain at least one special character";
    }

    return null;

};
