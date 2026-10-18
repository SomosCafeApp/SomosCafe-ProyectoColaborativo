import Coupon from "../models/couponModel.js";
import UserCoupon from "../models/userCouponModel.js";
import User from "../models/userModel.js";

import { notifyUsers, formatDate } from "../utils/notify.js";
import { couponDiscountText, grantBirthdayCoupon } from "../utils/coupons.js";
import { COUPON_REMINDER_DAYS } from "../utils/rewardsConfig.js";

// ===================================
// REWARDS JOBS
// ===================================
// Tareas automáticas de recompensas (sin cron externo):
//   1. Avisar de cupones por vencer.
//   2. Regalar el cupón de cumpleaños.
// Corren al arrancar el servidor y luego cada 6 horas. Son idempotentes
// (cada aviso / regalo se marca antes de enviarse), así que repetirlas
// o correrlas en dos servidores a la vez no duplica nada.
//
// OJO: si el hosting duerme el servidor por inactividad, las tareas se
// ejecutan cuando despierta.

const DAY_MS = 24 * 60 * 60 * 1000;
const HOUR_MS = 60 * 60 * 1000;
const RUN_EVERY_MS = 6 * HOUR_MS;
const FIRST_RUN_DELAY_MS = 30 * 1000;
const BATCH_LIMIT = 500;

// ---------- 1. Cupones por vencer ----------
export const sendExpiringCouponReminders = async () => {

    const now = new Date();

    const candidates = await UserCoupon.find({
        status: "AVAILABLE",
        reminderSentAt: null,
        expiresAt: {
            $gt: now,
            $lte: new Date(now.getTime() + COUPON_REMINDER_DAYS * DAY_MS)
        }
    }).limit(BATCH_LIMIT);

    for (const coupon of candidates) {

        // Se marca ANTES de avisar: si dos ejecuciones coinciden, solo
        // una lo logra y el cliente recibe un único aviso.
        const claimed = await UserCoupon.findOneAndUpdate(
            {
                _id: coupon._id,
                status: "AVAILABLE",
                reminderSentAt: null
            },
            { $set: { reminderSentAt: new Date() } }
        );

        if (!claimed) continue;

        const hoursLeft =
            (coupon.expiresAt.getTime() - now.getTime()) / HOUR_MS;

        const when =
            hoursLeft <= 24
                ? "vence en menos de 24 horas"
                : `vence el ${formatDate(coupon.expiresAt)}`;

        await notifyUsers([coupon.userId], {
            title: "Tu cupón está por vencer ⏰",
            message:
                `Tu cupón "${coupon.name}" ` +
                `(${couponDiscountText(coupon)}) ${when}. ` +
                "¡Úsalo en tu próximo pedido!",
            type: "REWARD",
            relatedId: coupon._id
        });

    }

};

// Fecha de hoy en Colombia (el cumpleaños se mide en hora local).
const bogotaToday = () => {

    const parts = new Intl.DateTimeFormat("en-CA", {
        timeZone: "America/Bogota",
        year: "numeric",
        month: "2-digit",
        day: "2-digit"
    }).formatToParts(new Date());

    const pick = (type) =>
        Number(parts.find(part => part.type === type).value);

    return {
        year: pick("year"),
        month: pick("month"),
        day: pick("day")
    };

};

const isLeapYear = (year) =>
    (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;

// ---------- 2. Cupón de cumpleaños ----------
export const grantTodaysBirthdayCoupons = async () => {

    const hasBirthdayCoupon = await Coupon.exists({
        kind: "BIRTHDAY",
        isActive: true
    });

    if (!hasBirthdayCoupon) return;

    const { year, month, day } = bogotaToday();

    // Quienes nacieron un 29 de febrero lo celebran el 28 en años
    // no bisiestos.
    const days = [day];
    if (month === 2 && day === 28 && !isLeapYear(year)) days.push(29);

    const users = await User.find({
        role: "USER",
        isActive: true,
        birthDate: { $ne: null },
        $expr: {
            $and: [
                {
                    $eq: [
                        { $month: { date: "$birthDate", timezone: "UTC" } },
                        month
                    ]
                },
                {
                    $in: [
                        { $dayOfMonth: { date: "$birthDate", timezone: "UTC" } },
                        days
                    ]
                }
            ]
        }
    }).select("_id").limit(BATCH_LIMIT).lean();

    for (const user of users) {
        await grantBirthdayCoupon(user._id, year);
    }

};

let running = false;

export const runRewardsJobs = async () => {

    if (running) return;
    running = true;

    try {

        await sendExpiringCouponReminders();
        await grantTodaysBirthdayCoupons();

    } catch (error) {

        console.error("Rewards jobs error:", error);

    } finally {

        running = false;

    }

};

export const startRewardsJobs = () => {

    setTimeout(runRewardsJobs, FIRST_RUN_DELAY_MS).unref();

    setInterval(runRewardsJobs, RUN_EVERY_MS).unref();

};
