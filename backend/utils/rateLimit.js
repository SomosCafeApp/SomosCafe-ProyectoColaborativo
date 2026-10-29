// ===================================
// LIMITADOR DE SOLICITUDES (en memoria)
// ===================================
// Ventana deslizante simple por clave (usuario o IP). Suficiente para
// frenar abuso del ChatBot en un solo servidor; si algún día se corre
// en varias instancias habría que moverlo a Redis.

export const createRateLimiter = ({
    windowMs,
    max,
    now = () => Date.now()
}) => {

    const hits = new Map();

    const sweep = (time) => {
        if (hits.size < 5000) return;
        for (const [key, list] of hits) {
            if (list.every(t => time - t >= windowMs)) hits.delete(key);
        }
    };

    // Devuelve { allowed, retryAfterMs }.
    const check = (key) => {

        const time = now();

        sweep(time);

        const recent = (hits.get(key) || []).filter(t => time - t < windowMs);

        if (recent.length >= max) {
            hits.set(key, recent);
            return {
                allowed: false,
                retryAfterMs: windowMs - (time - recent[0])
            };
        }

        recent.push(time);
        hits.set(key, recent);

        return { allowed: true, retryAfterMs: 0 };
    };

    return { check };
};

// Middleware de Express. La clave es el usuario (si hay sesión) o la IP.
export const rateLimitMiddleware = ({ windowMs, max, message }) => {

    const limiter = createRateLimiter({ windowMs, max });

    return (req, res, next) => {

        const key =
            req.user?.id ||
            req.user?.userId ||
            req.ip ||
            req.socket?.remoteAddress ||
            "anon";

        const { allowed, retryAfterMs } = limiter.check(String(key));

        if (!allowed) {
            res.set("Retry-After", String(Math.ceil(retryAfterMs / 1000)));
            return res.status(429).json({
                message: message ||
                    "Estás enviando mensajes muy rápido. Espera unos segundos e inténtalo de nuevo."
            });
        }

        next();
    };
};
