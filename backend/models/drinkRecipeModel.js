import mongoose from "mongoose";

// Receta del estudio de bebidas: una bebida con su personalización.
//  - Recientes: se registran solas al agregar la bebida al carrito.
//  - Guardadas: el usuario las guarda a propósito (isSaved) y puede
//    ponerles nombre.
// La misma receta (bebida + personalización) es un único documento.

const customizationSchema = new mongoose.Schema(
    {
        size: { type: String, required: true },
        type: { type: String, required: true },
        milk: { type: String, required: true },
        extraShots: { type: Number, default: 0 },
        toppings: { type: [String], default: [] },
        syrups: { type: [String], default: [] },
        sweeteners: { type: [String], default: [] },
        latteArt: { type: String, default: "" },
        // Cuánta leche se vertió (0..1): solo visual.
        milkLevel: { type: Number, default: 0.55, min: 0, max: 1 }
    },
    { _id: false }
);

const drinkRecipeSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
            index: true
        },

        productId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Product",
            required: true
        },

        // Clave estable de la personalización (utils/customization.js).
        key: { type: String, required: true },

        name: { type: String, trim: true, maxlength: 40, default: "" },

        customization: { type: customizationSchema, required: true },

        isSaved: { type: Boolean, default: false },

        lastUsedAt: { type: Date, default: Date.now }
    },
    { timestamps: true }
);

drinkRecipeSchema.index(
    { userId: 1, productId: 1, key: 1 },
    { unique: true }
);

export default mongoose.model("DrinkRecipe", drinkRecipeSchema);
