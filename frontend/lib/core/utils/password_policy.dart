/// Misma política que exige el backend (utils/passwordPolicy.js):
/// mínimo 6 caracteres, mayúscula, minúscula, número y carácter especial.
final RegExp _passwordPolicy = RegExp(
  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};:\x27"\\|,.<>/?]).{6,}$',
);

bool isValidPassword(String password) => _passwordPolicy.hasMatch(password);

const String passwordPolicyHint = 'Mín. 6 caracteres, mayúscula, minúscula, número y carácter especial';
