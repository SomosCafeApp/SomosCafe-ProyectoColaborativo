import mongoose from "mongoose";

const chatMessageSchema = new mongoose.Schema(
  {
    role: {
      type: String,
      enum: ["user", "assistant"],
      required: true
    },

    content: {
      type: String,
      required: true,
      trim: true
    },

    // IDs de los productos que el asistente recomendó en este mensaje
    // (se muestran como tarjetas). El contenido siempre es texto plano.
    products: {
      type: [mongoose.Schema.Types.ObjectId],
      ref: "Product",
      default: []
    },

    // true cuando el asistente ofreció pasar a WhatsApp (la app
    // muestra el botón en ese mensaje).
    whatsapp: {
      type: Boolean,
      default: false
    }
  },
  {
    _id: true,
    timestamps: true
  }
);

const chatSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: false,
      index: true
    },

    // true cuando el chat fue iniciado por alguien sin sesión iniciada.
    isAnonymous: {
      type: Boolean,
      default: false
    },

    title: {
      type: String,
      trim: true,
      default: "Nueva conversación"
    },

    messages: {
      type: [chatMessageSchema],
      default: []
    },

    // Contexto de la conversación (producto elegido, cantidad, tamaño,
    // temperatura, qué se está esperando). Lo gestiona el planificador.
    state: {
      type: mongoose.Schema.Types.Mixed,
      default: {}
    },

    // Propuesta de acción esperando confirmación del cliente
    // (agregar al carrito / vaciar carrito). Un solo uso, con vencimiento.
    pending: {
      type: mongoose.Schema.Types.Mixed,
      default: null
    },

    isActive: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true,
    collection: "chats"
  }
);

const Chat = mongoose.model("Chat", chatSchema);

export default Chat;