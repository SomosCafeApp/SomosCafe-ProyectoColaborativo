import mongoose from "mongoose";

// Minutos que tiene el cliente para cancelar su pedido.
export const CANCEL_WINDOW_MINUTES = 10;

export const ORDER_STATUSES = [
    "PENDING",
    "CONFIRMED",
    "PREPARING",
    "READY",
    "OUT_FOR_DELIVERY",
    "DELIVERED",
    "CANCELLED"
];

// PICKUP = "En local" ($0 de envío) · DELIVERY = "Envío" (+$5.000)
export const DELIVERY_TYPES = ["PICKUP", "DELIVERY"];

export const DELIVERY_FEE = 5000;

const customizationSchema = new mongoose.Schema(
    {
        size: { type: String, required: true },
        type: { type: String, required: true },
        milk: { type: String, required: true },
        extraShots: { type: Number, default: 0, min: 0 },
        toppings: { type: [String], default: [] }
    },
    {
        _id: false
    }
);

const orderItemSchema = new mongoose.Schema(
    {
        productId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Product",
            required: true
        },

        name: {
            type: String,
            required: true,
            trim: true
        },

        image: {
            type: String,
            default: ""
        },

        // Precio base del producto al momento de la compra.
        price: {
            type: Number,
            required: true,
            min: 0
        },

        // Extra por unidad que suma la personalización.
        customizationPrice: {
            type: Number,
            default: 0,
            min: 0
        },

        customization: {
            type: customizationSchema,
            default: undefined
        },

        quantity: {
            type: Number,
            required: true,
            min: 1
        },

        // Descuento de promoción por unidad (sobre el precio base).
        discountPerUnit: {
            type: Number,
            default: 0,
            min: 0
        },

        // Descuento total de la línea: discountPerUnit * quantity.
        discount: {
            type: Number,
            default: 0,
            min: 0
        },

        promotionId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Promotion",
            default: null
        },

        promotionName: {
            type: String,
            default: ""
        },

        // (price + customizationPrice) * quantity, ANTES del descuento.
        // Lo que paga el cliente por la línea es subtotal - discount.
        subtotal: {
            type: Number,
            required: true,
            min: 0
        }
    },
    {
        _id: false
    }
);

// Foto de la dirección al momento del pedido: si el usuario la edita
// o la borra después, el pedido conserva lo que se entregó.
const addressSnapshotSchema = new mongoose.Schema(
    {
        label: { type: String, default: "" },
        recipientName: { type: String, default: "" },
        phone: { type: String, default: "" },
        address: { type: String, default: "" },
        city: { type: String, default: "" },
        neighborhood: { type: String, default: "" },
        additionalInfo: { type: String, default: "" }
    },
    {
        _id: false
    }
);

// Foto del método de pago (nunca datos sensibles: solo lo visible).
const paymentSnapshotSchema = new mongoose.Schema(
    {
        type: { type: String, default: "" },
        provider: { type: String, default: "" },
        name: { type: String, default: "" },
        lastFourDigits: { type: String, default: "" }
    },
    {
        _id: false
    }
);

const orderSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true
        },

        // Obligatoria solo cuando deliveryType === "DELIVERY".
        addressId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Address",
            default: null
        },

        addressSnapshot: {
            type: addressSnapshotSchema,
            default: undefined
        },

        deliveryType: {
            type: String,
            enum: DELIVERY_TYPES,
            default: "DELIVERY"
        },

        recipientName: {
            type: String,
            trim: true,
            default: ""
        },

        recipientPhone: {
            type: String,
            trim: true,
            default: ""
        },

        items: {
            type: [orderItemSchema],
            required: true,
            validate: {
                validator: function (items) {
                    return items.length > 0;
                },
                message: "Order must contain at least one item"
            }
        },

        subtotal: {
            type: Number,
            required: true,
            min: 0
        },

        shippingCost: {
            type: Number,
            default: 0,
            min: 0
        },

        discount: {
            type: Number,
            default: 0,
            min: 0
        },

        total: {
            type: Number,
            required: true,
            min: 0
        },

        status: {
            type: String,
            enum: ORDER_STATUSES,
            default: "PENDING"
        },

        paymentStatus: {
            type: String,
            enum: [
                "PENDING",
                "PAID",
                "FAILED",
                "REFUNDED"
            ],
            default: "PENDING"
        },

        paymentMethodId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "PaymentMethod",
            default: null
        },

        paymentSnapshot: {
            type: paymentSnapshotSchema,
            default: undefined
        },

        notes: {
            type: String,
            trim: true,
            default: ""
        },

        estimatedDelivery: {
            type: Date,
            default: null
        },

        deliveredAt: {
            type: Date,
            default: null
        },

        cancelledAt: {
            type: Date,
            default: null
        }
    },
    {
        timestamps: true,
        collection: "orders"
    }
);

// ===================================
// CANCELLATION WINDOW (fuente de verdad: el servidor)
// ===================================

// Estados desde los que el cliente aún puede cancelar (los mismos que
// ya permitía cancelOrder antes de agregar la ventana de tiempo).
export const USER_CANCELLABLE_STATUSES = ["PENDING", "CONFIRMED"];

orderSchema.methods.cancelDeadline = function () {
    return new Date(
        this.createdAt.getTime() +
        CANCEL_WINDOW_MINUTES * 60 * 1000
    );
};

orderSchema.methods.cancelSecondsRemaining = function () {

    if (!this.createdAt) return 0;

    if (!USER_CANCELLABLE_STATUSES.includes(this.status)) return 0;

    const remainingMs =
        this.cancelDeadline().getTime() - Date.now();

    return Math.max(0, Math.ceil(remainingMs / 1000));
};

// Se calcula al serializar para que el cliente muestre el contador
// sin depender de que el reloj del teléfono esté bien sincronizado.
orderSchema.set("toJSON", {
    transform: (doc, ret) => {
        ret.cancelSecondsRemaining = doc.cancelSecondsRemaining();
        return ret;
    }
});

const Order = mongoose.model(
    "Order",
    orderSchema
);

export default Order;
