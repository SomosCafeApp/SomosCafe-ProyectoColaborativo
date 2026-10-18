// Cumpleaños como "AAAA-MM-DD" (o null). Se guarda a las 12:00 UTC, así
// que el día no cambia por zona horaria.
export const formatBirthDate = (date) =>
    date ? new Date(date).toISOString().slice(0, 10) : null;
