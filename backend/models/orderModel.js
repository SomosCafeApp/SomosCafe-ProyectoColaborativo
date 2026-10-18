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

// CASH = se paga al domiciliario o en la cafetería al recoger.
// TRANSFER = se paga por QR y el cliente sube el comprobante.
export const PAYMENT_METHODS = ["CASH", "TRANSFER"];

export const PAYMENT_STATUSES = [
    // Efectivo: se cobra al entregar / en el local.
    "PENDING",
    // Transferencia: falta que el cliente suba el comprobante.
    "AWAITING_PROOF",
    // Transferencia: comprobante subido, el admin debe revisarlo.
    "PROOF_SUBMITTED",
    // Transferencia: el admin validó el pago.
    "VALIDATED",
    // Transferencia: el admin lo invalidó (el pedido se cancela).
    "INVALIDATED"
];

// El cliente solo puede cancelar mientras no haya enviado un
// comprobante: después el dinero ya se movió y solo el admin decide.
export const USER_CANCELLABLE_PAYMENT_STATUSES = [
    "PENDING",
    "AWAITING_PROOF"
];

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

// Comprobante de pago (captura de la transferencia) que sube el cliente.
const paymentProofSchema = new mongoose.Schema(
    {
        url: { type: String, required: true },
        uploadedAt: { type: Date, default: Date.now }
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

        // Descuento total por promociones de producto.
        discount: {
            type: Number,
            default: 0,
            min: 0
        },

        // Cupón de recompensas usado en el pedido (UserCoupon). Su
        // descuento va aparte del de promociones y se calcula sobre
        // los productos (nunca sobre el envío).
        couponId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "UserCoupon",
            default: null
        },

        couponName: {
            type: String,
            default: ""
        },

        couponDiscount: {
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

        paymentMethod: {
            type: String,
            enum: PAYMENT_METHODS,
            default: "CASH"
        },

        paymentStatus: {
            type: String,
            enum: PAYMENT_STATUSES,
            default: "PENDING"
        },

        paymentProof: {
            type: paymentProofSchema,
            default: undefined
        },

        // Cuándo el admin validó o invalidó el pago.
        paymentReviewedAt: {
            type: Date,
            default: null
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

    if (
        !USER_CANCELLABLE_PAYMENT_STATUSES.includes(
            this.paymentStatus
        )
    ) return 0;

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
