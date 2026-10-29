import Product from "../models/productModel.js";
import Category from "../models/categoryModel.js";
import Cart from "../models/cartModel.js";
import Favorite from "../models/favoriteModel.js";
import Review from "../models/reviewModel.js";
import Inventory from "../models/inventoryModel.js";
import Promotion from "../models/promotionModel.js";
import Order from "../models/orderModel.js";
import { deleteCloudinaryImage } from "../utils/cloudinary.js";
import { announceProduct } from "../utils/announce.js";
import { getDiscountResolver, decorateProduct } from "../utils/promotions.js";

const CATEGORY_FIELDS = "name description image isActive";

const MAX_INGREDIENTS = 30;

// ===================================
// HELPERS
// ===================================

// Ingredientes: el admin los escribe como texto libre separado por
// comas ("Café, Leche, Canela"). También se aceptan una lista o un
// JSON ("[...]") por compatibilidad con clientes anteriores.
// Se recortan espacios, se quitan vacíos y duplicados.
const parseIngredients = (raw) => {

    let list = [];

    if (Array.isArray(raw)) {
        list = raw;
    } else if (typeof raw === "string") {

        const text = raw.trim();

        if (text.startsWith("[")) {
            try {
                const parsed = JSON.parse(text);
                list = Array.isArray(parsed) ? parsed : [text];
            } catch {
                list = text.split(",");
            }
        } else {
            list = text.split(",");
        }
    }

    const clean = [];
    const seen = new Set();

    for (const item of list) {

        const value = String(item).trim();

        if (!value) continue;

        const key = value.toLowerCase();

        if (seen.has(key)) continue;

        seen.add(key);
        clean.push(value);
    }

    return clean.slice(0, MAX_INGREDIENTS);
};

const parseBoolean = (value) =>
    value === true || value === "true";

// Si Multer ya subió la imagen a Cloudinary pero la operación
// falla, se borra para no dejar archivos huérfanos.
const discardUploadedImage = async (req) => {
    if (req.file?.path) {
        await deleteCloudinaryImage(req.file.path);
    }
};

// Valida una categoría opcional. Devuelve { status, message } si no
// sirve, o null si está bien (o no se envió).
const checkCategory = async (categoryId) => {

    if (!categoryId) return null;

    const category = await Category.findById(categoryId);

    if (!category) {
        return { status: 404, message: "Categoría no encontrada" };
    }

    if (!category.isActive) {
        return {
            status: 400,
            message: "La categoría seleccionada está inactiva"
        };
    }

    return null;
};

// ===================================
// GET ALL PRODUCTS (PUBLIC)
// ===================================
// Solo productos disponibles: los ocultos por el admin
// (isAvailable: false) no aparecen en el menú.
export const getProducts = async (req, res) => {

    try {

        const products = await Product.find({ isAvailable: true })
            .populate("categoryId", CATEGORY_FIELDS)
            .sort({ createdAt: -1 });

        // Listado público: aplica solo promociones para todos los
        // usuarios (las restringidas a usuarios específicos se
        // reflejan en el carrito y el pedido).
        const resolver = await getDiscountResolver();

        return res.status(200).json({
            message: "Productos obtenidos correctamente",
            products: products.map(
                product => decorateProduct(product, resolver)
            )
        });

    } catch (error) {

        console.error("Get products error:", error);

        return res.status(500).json({
            message: "Error al obtener los productos",
            error: error.message
        });

    }

};

// ===================================
// GET ALL PRODUCTS - ADMIN
// ===================================
// Incluye los ocultos, para poder volver a mostrarlos.
export const getAllProductsAdmin = async (req, res) => {

    try {

        const products = await Product.find()
            .populate("categoryId", CATEGORY_FIELDS)
            .sort({ createdAt: -1 });

        return res.status(200).json({
            message: "Productos obtenidos correctamente",
            products
        });

    } catch (error) {

        console.error("Get admin products error:", error);

        return res.status(500).json({
            message: "Error al obtener los productos",
            error: error.message
        });

    }

};

// ===================================
// GET PRODUCT BY ID
// ===================================
// Se devuelve aunque esté oculto (el cliente puede llegar desde un
// favorito); en ese caso viene con isAvailable: false.
export const getProductById = async (req, res) => {

    try {

        const product = await Product.findById(req.params.id)
            .populate("categoryId", CATEGORY_FIELDS);

        if (!product) {
            return res.status(404).json({
                message: "Producto no encontrado"
            });
        }

        const resolver = await getDiscountResolver();

        return res.status(200).json({
            message: "Producto obtenido correctamente",
            product: decorateProduct(product, resolver)
        });

    } catch (error) {

        console.error("Get product error:", error);

        return res.status(500).json({
            message: "Error al obtener el producto",
            error: error.message
        });

    }

};

// ===================================
// CREATE PRODUCT
// ===================================
// multipart/form-data: name, price, description, ingredients,
// categoryId, isAvailable + archivo "imagen" (a Cloudinary).
// La calificación NO se recibe: la calculan las reseñas.
export const createProduct = async (req, res) => {

    try {

        const {
            name,
            description,
            price,
            ingredients,
            categoryId,
            isAvailable
        } = req.body;

        const cleanName = (name || "").toString().trim();
        const numericPrice = Number(price);

        if (
            !cleanName ||
            price === undefined ||
            price === "" ||
            !Number.isFinite(numericPrice) ||
            numericPrice < 0
        ) {
            await discardUploadedImage(req);

            return res.status(400).json({
                message: "El nombre y un precio válido son obligatorios"
            });
        }

        if (!req.file) {
            return res.status(400).json({
                message: "La imagen del producto es obligatoria"
            });
        }

        const categoryError = await checkCategory(categoryId);

        if (categoryError) {
            await discardUploadedImage(req);

            return res.status(categoryError.status).json({
                message: categoryError.message
            });
        }

        const newProduct = new Product({
            name: cleanName,
            description: description
                ? description.toString().trim()
                : "",
            price: numericPrice,
            images: [req.file.path],
            ingredients: parseIngredients(ingredients),
            categoryId: categoryId || null,
            isAvailable:
                isAvailable === undefined
                    ? true
                    : parseBoolean(isAvailable)
        });

        await newProduct.save();

        // Ya guardado: avisa a los clientes (no se espera). Solo si
        // quedó disponible; uno creado oculto se anuncia al publicarlo.
        announceProduct(newProduct);

        await newProduct.populate("categoryId", CATEGORY_FIELDS);

        return res.status(201).json({
            message: "Producto creado correctamente",
            product: newProduct
        });

    } catch (error) {

        console.error("Create product error:", error);

        await discardUploadedImage(req);

        return res.status(500).json({
            message: "Error al crear el producto",
            error: error.message
        });

    }

};

// ===================================
// UPDATE PRODUCT
// ===================================
// Acepta multipart (con imagen nueva opcional) o JSON (por ejemplo
// { isAvailable: false } para ocultarlo del menú).
export const updateProduct = async (req, res) => {

    try {

        const product = await Product.findById(req.params.id);

        if (!product) {
            await discardUploadedImage(req);

            return res.status(404).json({
                message: "Producto no encontrado"
            });
        }

        const wasAvailable = product.isAvailable;

        const {
            name,
            description,
            price,
            ingredients,
            categoryId,
            isAvailable
        } = req.body;

        const categoryError = await checkCategory(categoryId);

        if (categoryError) {
            await discardUploadedImage(req);

            return res.status(categoryError.status).json({
                message: categoryError.message
            });
        }

        if (name !== undefined) {

            const cleanName = name.toString().trim();

            if (!cleanName) {
                await discardUploadedImage(req);

                return res.status(400).json({
                    message: "El nombre del producto no puede estar vacío"
                });
            }

            product.name = cleanName;
        }

        if (description !== undefined) {
            product.description = description.toString().trim();
        }

        if (price !== undefined && price !== "") {

            const numericPrice = Number(price);

            if (!Number.isFinite(numericPrice) || numericPrice < 0) {
                await discardUploadedImage(req);

                return res.status(400).json({
                    message: "Precio inválido"
                });
            }

            product.price = numericPrice;
        }

        if (categoryId !== undefined) {
            product.categoryId = categoryId || null;
        }

        if (isAvailable !== undefined) {
            product.isAvailable = parseBoolean(isAvailable);
        }

        if (ingredients !== undefined) {
            product.ingredients = parseIngredients(ingredients);
        }

        let oldImage = null;

        if (req.file) {
            oldImage = product.images?.[0] || null;
            product.images = [req.file.path];
        }

        await product.save();

        // Pasó de oculto a disponible por primera vez: es una novedad.
        if (!wasAvailable && product.isAvailable) {
            announceProduct(product);
        }

        // La imagen anterior se borra de Cloudinary solo si ningún
        // pedido la conserva en su historial.
        if (oldImage) {
            const usedInOrders = await Order.exists({
                "items.image": oldImage
            });

            if (!usedInOrders) {
                await deleteCloudinaryImage(oldImage);
            }
        }

        await product.populate("categoryId", CATEGORY_FIELDS);

        return res.status(200).json({
            message: "Producto actualizado correctamente",
            product
        });

    } catch (error) {

        console.error("Update product error:", error);

        await discardUploadedImage(req);

        return res.status(500).json({
            message: "Error al actualizar el producto",
            error: error.message
        });

    }

};

// ===================================
// DELETE PRODUCT (hard delete)
// ===================================
// Borra el producto de la base de datos y lo saca de lo que
// dependía de él: carritos, favoritos, reseñas, inventario y
// promociones. Los PEDIDOS ya hechos se conservan: guardan su propia
// copia de nombre, precio e imagen.
// Para ocultarlo del menú sin borrarlo: PUT con { isAvailable: false }.
export const deleteProduct = async (req, res) => {

    try {

        const product = await Product.findById(req.params.id);

        if (!product) {
            return res.status(404).json({
                message: "Producto no encontrado"
            });
        }

        const productId = product._id;
        const imageUrl = product.images?.[0] || null;

        const [cartResult] = await Promise.all([
            Cart.updateMany(
                { "items.productId": productId },
                { $pull: { items: { productId } } }
            ),
            Favorite.deleteMany({ productId }),
            Review.deleteMany({ productId }),
            Inventory.deleteMany({ productId }),
            Promotion.updateMany(
                { productIds: productId },
                { $pull: { productIds: productId } }
            )
        ]);

        await Product.findByIdAndDelete(productId);

        // La imagen se conserva si algún pedido la usa en su historial.
        if (imageUrl) {
            const usedInOrders = await Order.exists({
                "items.image": imageUrl
            });

            if (!usedInOrders) {
                await deleteCloudinaryImage(imageUrl);
            }
        }

        return res.status(200).json({
            message: "Producto eliminado correctamente",
            removedFromCarts: cartResult.modifiedCount
        });

    } catch (error) {

        console.error("Delete product error:", error);

        return res.status(500).json({
            message: "Error al eliminar el producto",
            error: error.message
        });

    }

};
