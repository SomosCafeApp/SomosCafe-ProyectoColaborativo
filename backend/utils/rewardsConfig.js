// ===================================
// REWARDS CONFIG
// ===================================
// Reglas de los puntos de recompensas. Si quieres cambiar cuánto vale
// un punto, es SOLO aquí (y el texto de earn_points_card.dart).

// Pesos en productos que se necesitan para ganar 1 punto.
export const PESOS_PER_POINT = 1000;

// Todo pedido entregado da al menos esto, aunque sea pequeño.
export const MIN_POINTS_PER_ORDER = 1;

// Días antes del vencimiento en que se avisa de un cupón por vencer.
export const COUPON_REMINDER_DAYS = 2;

// Puntos que gana el cliente cuando el pedido pasa a DELIVERED:
// 1 por cada PESOS_PER_POINT pagados en PRODUCTOS (ya con promociones
// y cupón; el envío no cuenta), mínimo MIN_POINTS_PER_ORDER.
export const pointsForOrder = (order) => {

    const paid = Math.max(
        0,
        (order.subtotal || 0) -
        (order.discount || 0) -
        (order.couponDiscount || 0)
    );

    return Math.max(
        MIN_POINTS_PER_ORDER,
        Math.floor(paid / PESOS_PER_POINT)
    );

};
