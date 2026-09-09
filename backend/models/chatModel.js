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
      required: true,
      index: true
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