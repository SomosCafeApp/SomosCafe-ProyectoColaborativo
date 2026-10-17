import "dotenv/config";

import mongoose from "mongoose";

// ===================================
// MIGRACIÓN: esquema de pagos viejo → nuevo
// ===================================
// Limpia de MongoDB lo que dejó el sistema de métodos de pago
// anterior (tarjetas/billeteras guardadas):
//
//   1. Borra la colección "paymentMethods".
//   2. En los pedidos existentes quita paymentMethodId y
//      paymentSnapshot.
//   3. Los pedidos viejos pasan a paymentMethod "CASH" y los estados
//      PAID / FAILED / REFUNDED pasan a "PENDING" (ya no existen).
//
// Es OPCIONAL (la app funciona sin correrlo: los pedidos viejos
// simplemente se muestran como "efectivo") y DESTRUCTIVA para la
// colección paymentMethods, por eso por defecto solo SIMULA:
//
//   node scripts/migratePaymentSchema.js            → muestra qué haría
//   node scripts/migratePaymentSchema.js --confirm  → lo aplica

const APPLY = process.argv.includes("--confirm");

const LEGACY_PAYMENT_STATUSES = ["PAID", "FAILED", "REFUNDED"];

const run = async () => {

    await mongoose.connect(process.env.MONGO_URI, {
        dbName: "somoscafeDB"
    });

    const db = mongoose.connection.db;

    // Colección nativa: el esquema de mongoose (strict) descartaría
    // los $unset de campos que ya no existen en el modelo.
    const orders = db.collection("orders");

    const legacyFields = {
        $or: [
            { paymentMethodId: { $exists: true } },
            { paymentSnapshot: { $exists: true } }
        ]
    };

    const noMethod = { paymentMethod: { $exists: false } };

    const legacyStatus = {
        paymentStatus: { $in: LEGACY_PAYMENT_STATUSES }
    };

    const collections = await db
        .listCollections({ name: "paymentMethods" })
        .toArray();

    const saved = collections.length > 0
        ? await db.collection("paymentMethods").countDocuments()
        : 0;

    console.log(APPLY ? "▶ APLICANDO migración" : "▶ SIMULACIÓN (usa --confirm para aplicar)");
    console.log(`  paymentMethods guardados a borrar : ${saved}`);
    console.log(`  pedidos con campos viejos a limpiar: ${await orders.countDocuments(legacyFields)}`);
    console.log(`  pedidos sin paymentMethod → CASH   : ${await orders.countDocuments(noMethod)}`);
    console.log(`  pedidos con estado de pago viejo   : ${await orders.countDocuments(legacyStatus)}`);

    if (APPLY) {

        await orders.updateMany(
            legacyFields,
            { $unset: { paymentMethodId: "", paymentSnapshot: "" } }
        );

        await orders.updateMany(
            noMethod,
            { $set: { paymentMethod: "CASH" } }
        );

        await orders.updateMany(
            legacyStatus,
            { $set: { paymentStatus: "PENDING" } }
        );

        if (collections.length > 0) {
            await db.dropCollection("paymentMethods");
        }

        console.log("✅ Migración aplicada");
    }

    await mongoose.disconnect();
};

run().catch(async (error) => {
    console.error("❌ Error en la migración:", error.message);
    await mongoose.disconnect().catch(() => {});
    process.exit(1);
});
