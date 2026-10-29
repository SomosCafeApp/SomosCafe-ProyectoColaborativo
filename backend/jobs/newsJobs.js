import Promotion from "../models/promotionModel.js";

import { announcePromotion } from "../utils/announce.js";

// ===================================
// NEWS JOBS
// ===================================
// Anuncia las promociones programadas el día en que empiezan: una
// promoción creada hoy con inicio la próxima semana NO avisa al crearse
// (todavía no debe publicarse); este trabajo la anuncia al llegar su
// fecha de inicio.
//
// Solo toma promociones con launchNotifiedAt en null EXPLÍCITO (las
// creadas con esta versión): las anteriores no tienen el campo y no se
// reanuncian. Es idempotente: announcePromotion marca la fecha y además
// usa una clave de novedad por usuario, así que correrlo dos veces o en
// dos servidores a la vez no duplica avisos.

const RUN_EVERY_MS = 5 * 60 * 1000;
const FIRST_RUN_DELAY_MS = 20 * 1000;
const BATCH_LIMIT = 50;

export const announceScheduledPromotions = async () => {

    const now = new Date();

    const due = await Promotion.find({
        isActive: true,
        launchNotifiedAt: { $type: "null" },
        startDate: { $lte: now },
        endDate: { $gt: now }
    }).limit(BATCH_LIMIT);

    let announced = 0;

    for (const promotion of due) {
        if (await announcePromotion(promotion)) announced++;
    }

    return announced;
};

const run = async () => {

    try {

        const count = await announceScheduledPromotions();

        if (count > 0) {
            console.log(`📣 Promociones programadas anunciadas: ${count}`);
        }

    } catch (error) {

        console.error("News jobs error:", error);

    }
};

export const startNewsJobs = () => {

    setTimeout(run, FIRST_RUN_DELAY_MS).unref();

    setInterval(run, RUN_EVERY_MS).unref();

};
