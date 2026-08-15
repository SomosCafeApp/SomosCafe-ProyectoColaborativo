import mongoose from "mongoose";

export const conectarDB = async () => {

    try {

        console.log("🌱 Conectando a MongoDB...");
        console.log("📦 Base de datos: somoscafeDB");

        mongoose.set("strictQuery", true);

        await mongoose.connect(process.env.MONGO_URI, {
            dbName: "somoscafeDB"
        });

        console.log("✅ MongoDB conectado correctamente");
        console.log("🗄️ Base de datos: somoscafeDB");

    } catch (error) {

        console.log(
            "❌ Error al conectar a MongoDB:",
            error.message
        );

        process.exit(1);

    }

};