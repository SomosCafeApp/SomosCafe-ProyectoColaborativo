import mongoose from "mongoose";

export const conectarDB = async () => {

    try {

        console.log("🌱 Conectando a MongoDB...");
        console.log("📦 Base de datos: SomosCafeApp");

        mongoose.set("strictQuery", true);

        await mongoose.connect(process.env.MONGO_URI, {
            dbName: "SomosCafeApp"
        });

        console.log("✅ MongoDB conectado correctamente");
        console.log("🗄️ Base de datos: SomosCafeApp");

    } catch (error) {

        console.log("❌ Error al conectar a MongoDB:", error.message);

        process.exit(1);

    }

};