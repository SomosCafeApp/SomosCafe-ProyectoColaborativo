import mongoose from "mongoose";

import DrinkRecipe from "../models/drinkRecipeModel.js";
import Product from "../models/productModel.js";
import {
    resolveCustomization,
    customizationPrice,
    customizationKey,
    isCustomizableProduct
} from "../utils/customization.js";

// ===================================
// RECETAS DEL ESTUDIO DE BEBIDAS
// ===================================

const MAX_RECENT = 10;
const MAX_SAVED = 30;

const isValidId = (id) => mongoose.Types.ObjectId.isValid(id);

const findProduct = (id) =>
    Product.findById(id).populate("categoryId", "name").lean();

// Forma que ve la app. Se revalida contra el menú actual: si un
// ingrediente o el producto ya no existen, la receta se marca como
// no disponible en vez de fallar.
const formatRecipe = (recipe, product) => {

    const base = {
        id: recipe._id,
        name: recipe.name || "",
        isSaved: recipe.isSaved,
        lastUsedAt: recipe.lastUsedAt,
        productId: recipe.productId,
        customization: recipe.customization
    };

    if (!product) {
        return { ...base, product: null, available: false, extraPrice: 0 };
    }

    const check = resolveCustomization(product, recipe.customization);

    return {
        ...base,
        product: {
            id: product._id,
            name: product.name,
            price: product.price,
            image: product.images?.[0] || null,
            isAvailable: product.isAvailable
        },
        available: product.isAvailable === true && !check.error,
        extraPrice: check.error
            ? 0
            : customizationPrice(check.customization)
    };
};

const loadFormatted = async (recipes) => {

    const ids = [...new Set(recipes.map(r => String(r.productId)))];

    const products = await Product.find({ _id: { $in: ids } })
        .populate("categoryId", "name")
        .lean();

    const byId = new Map(products.map(p => [String(p._id), p]));

    return recipes.map(r => formatRecipe(r, byId.get(String(r.productId))));
};

// Deja solo las últimas MAX_RECENT recetas no guardadas.
const trimRecents = async (userId) => {

    const old = await DrinkRecipe.find({ userId, isSaved: false })
        .sort({ lastUsedAt: -1 })
        .skip(MAX_RECENT)
        .select("_id")
        .lean();

    if (old.length > 0) {
        await DrinkRecipe.deleteMany({ _id: { $in: old.map(r => r._id) } });
    }
};

// ===================================
// GET /recipes  → { recent, saved }
// ===================================

export const getRecipes = async (req, res) => {

    try {

        const [recent, saved] = await Promise.all([
            DrinkRecipe.find({ userId: req.user.id })
                .sort({ lastUsedAt: -1 })
                .limit(MAX_RECENT)
                .lean(),
            DrinkRecipe.find({ userId: req.user.id, isSaved: true })
                .sort({ updatedAt: -1 })
                .limit(MAX_SAVED)
                .lean()
        ]);

        const formatted = await loadFormatted([...recent, ...saved]);
        const byId = new Map(formatted.map(r => [String(r.id), r]));

        return res.status(200).json({
            recent: recent.map(r => byId.get(String(r._id))),
            saved: saved.map(r => byId.get(String(r._id)))
        });

    } catch (error) {
        console.error("Get recipes error:", error);
        return res.status(500).json({
            message: "Error al obtener las recetas",
            error: error.message
        });
    }
};

// ===================================
// GET /recipes/last/:productId → última personalización usada
// ===================================

export const getLastRecipe = async (req, res) => {

    try {

        const { productId } = req.params;

        if (!isValidId(productId)) {
            return res.status(400).json({ message: "ID de producto inválido" });
        }

        const recipe = await DrinkRecipe.findOne({
            userId: req.user.id,
            productId
        }).sort({ lastUsedAt: -1 }).lean();

        if (!recipe) {
            return res.status(200).json({ recipe: null });
        }

        const product = await findProduct(productId);

        return res.status(200).json({
            recipe: formatRecipe(recipe, product)
        });

    } catch (error) {
        console.error("Get last recipe error:", error);
        return res.status(500).json({
            message: "Error al obtener la última receta",
            error: error.message
        });
    }
};

// ===================================
// POST /recipes
// body: { productId, customization, milkLevel?, saved?, name? }
// saved=true guarda la receta; saved=false solo la registra como
// reciente (se usa al agregar al carrito).
// ===================================

export const upsertRecipe = async (req, res) => {

    try {

        const { productId, customization, saved, name } = req.body;

        if (!isValidId(productId)) {
            return res.status(400).json({ message: "ID de producto inválido" });
        }

        const product = await findProduct(productId);

        if (!product) {
            return res.status(404).json({ message: "Producto no encontrado" });
        }

        if (!isCustomizableProduct(product)) {
            return res.status(400).json({
                message: "Este producto no se puede personalizar"
            });
        }

        const result = resolveCustomization(product, customization);

        if (result.error) {
            return res.status(400).json({ message: result.error });
        }

        const rawLevel = Number(customization?.milkLevel);
        const milkLevel = Number.isFinite(rawLevel)
            ? Math.min(1, Math.max(0, rawLevel))
            : 0.55;

        const key = customizationKey(result.customization);
        const filter = { userId: req.user.id, productId, key };
        const existing = await DrinkRecipe.findOne(filter);

        const wantsSave = saved === true;

        if (wantsSave && !existing?.isSaved) {
            const total = await DrinkRecipe.countDocuments({
                userId: req.user.id,
                isSaved: true
            });

            if (total >= MAX_SAVED) {
                return res.status(400).json({
                    message: `Solo puedes guardar hasta ${MAX_SAVED} recetas`
                });
            }
        }

        const cleanName = typeof name === "string"
            ? name.trim().slice(0, 40)
            : undefined;

        const update = {
            customization: { ...result.customization, milkLevel },
            lastUsedAt: new Date()
        };

        if (wantsSave) {
            update.isSaved = true;
            if (cleanName !== undefined) update.name = cleanName;
        }

        const recipe = await DrinkRecipe.findOneAndUpdate(
            filter,
            { $set: update, $setOnInsert: { userId: req.user.id, productId, key } },
            { upsert: true, new: true, setDefaultsOnInsert: true }
        ).lean();

        await trimRecents(req.user.id);

        const [formatted] = await loadFormatted([recipe]);

        return res.status(200).json({
            message: wantsSave
                ? "Receta guardada correctamente"
                : "Receta registrada",
            recipe: formatted
        });

    } catch (error) {
        console.error("Upsert recipe error:", error);
        return res.status(500).json({
            message: "Error al guardar la receta",
            error: error.message
        });
    }
};

// ===================================
// PATCH /recipes/:id  body: { saved?, name? }
// ===================================

export const updateRecipe = async (req, res) => {

    try {

        const { id } = req.params;

        if (!isValidId(id)) {
            return res.status(400).json({ message: "ID de receta inválido" });
        }

        const recipe = await DrinkRecipe.findOne({
            _id: id,
            userId: req.user.id
        });

        if (!recipe) {
            return res.status(404).json({ message: "Receta no encontrada" });
        }

        if (req.body.saved === true && !recipe.isSaved) {
            const total = await DrinkRecipe.countDocuments({
                userId: req.user.id,
                isSaved: true
            });

            if (total >= MAX_SAVED) {
                return res.status(400).json({
                    message: `Solo puedes guardar hasta ${MAX_SAVED} recetas`
                });
            }
        }

        if (typeof req.body.saved === "boolean") {
            recipe.isSaved = req.body.saved;
        }

        if (typeof req.body.name === "string") {
            recipe.name = req.body.name.trim().slice(0, 40);
        }

        await recipe.save();
        await trimRecents(req.user.id);

        const [formatted] = await loadFormatted([recipe.toObject()]);

        return res.status(200).json({
            message: "Receta actualizada correctamente",
            recipe: formatted
        });

    } catch (error) {
        console.error("Update recipe error:", error);
        return res.status(500).json({
            message: "Error al actualizar la receta",
            error: error.message
        });
    }
};

// ===================================
// DELETE /recipes/:id
// ===================================

export const deleteRecipe = async (req, res) => {

    try {

        const { id } = req.params;

        if (!isValidId(id)) {
            return res.status(400).json({ message: "ID de receta inválido" });
        }

        const deleted = await DrinkRecipe.findOneAndDelete({
            _id: id,
            userId: req.user.id
        });

        if (!deleted) {
            return res.status(404).json({ message: "Receta no encontrada" });
        }

        return res.status(200).json({ message: "Receta eliminada correctamente" });

    } catch (error) {
        console.error("Delete recipe error:", error);
        return res.status(500).json({
            message: "Error al eliminar la receta",
            error: error.message
        });
    }
};
