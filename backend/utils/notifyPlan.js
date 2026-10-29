// ===================================
// PLAN DE NOTIFICACIONES (lógica pura)
// ===================================
// Decide a quién SÍ se le crea una notificación. Sin base de datos:
// notify.js le pasa los datos ya leídos. Reglas:
//   - Los avisos de novedades se respetan según las preferencias del
//     usuario (promociones/cupones y novedades). Los avisos
//     importantes (pedidos, pagos, cuenta) nunca se filtran.
//   - Una misma novedad (dedupeKey) se avisa una sola vez por usuario.

// Tipo de notificación -> preferencia que la controla (o null si es
// un aviso importante que no se puede desactivar).
export const PREFERENCE_BY_TYPE = {
    PROMOTION: "promotions",
    REWARD: "promotions",
    EVENT: "news",
    PRODUCT: "news"
};

export const categoryForType = (type) =>
    PREFERENCE_BY_TYPE[type] || null;

// ¿Este usuario quiere recibir esta categoría? Sin preferencia
// guardada (cuentas anteriores) se asume que sí.
export const wantsCategory = (user, category) => {
    if (!category) return true;
    return user?.notificationPrefs?.[category] !== false;
};

// userIds: destinatarios candidatos.
// optedOutIds: Set de ids que desactivaron la categoría.
// alreadyNotifiedIds: Set de ids que ya recibieron esta novedad.
export const selectRecipients = ({
    userIds,
    optedOutIds = new Set(),
    alreadyNotifiedIds = new Set()
}) => {

    const unique = [...new Set((userIds || []).map(String))];

    return unique.filter(id =>
        !optedOutIds.has(id) && !alreadyNotifiedIds.has(id)
    );
};

// Clave estable por novedad: una notificación por vigencia. Si el
// admin cambia las fechas, es una novedad distinta y vuelve a avisar.
export const dedupeKeyFor = (kind, id, ...parts) =>
    [kind, String(id), ...parts.map(p =>
        p instanceof Date ? p.getTime() : String(p ?? "")
    )].join(":");
