import mongoose from "mongoose";

import Event from "../models/eventModel.js";
import { deleteCloudinaryImage } from "../utils/cloudinary.js";
import {
    notifyAllCustomers,
    formatDate
} from "../utils/notify.js";

// ===================================
// HELPERS
// ===================================

// multipart envía todo como texto ("true"), JSON envía booleanos.
const parseBoolean = (value) =>
    value === true || value === "true";

const cleanText = (value) =>
    value === undefined || value === null
        ? ""
        : String(value).trim();

// Si Multer ya subió la imagen a Cloudinary pero la operación
// falla, se borra para no dejar archivos huérfanos.
const discardUploadedImage = async (req) => {
    if (req.file?.path) {
        await deleteCloudinaryImage(req.file.path);
    }
};

// Solo un evento activo a la vez (es el que sale como pop-up).
const deactivateOthers = (exceptId) =>
    Event.updateMany(
        { _id: { $ne: exceptId }, isActive: true },
        { $set: { isActive: false } }
    );

const hasEnded = (endDate) =>
    new Date(endDate) < new Date();

// ===================================
// NOTIFY EVENT (push + pantalla de notificaciones)
// ===================================
// Avisa a todos los clientes de un evento. Se usa al crear un evento
// activo y cuando un evento pasa de inactivo a activo (reactivación).
// Solo avisa si está activo y no ha terminado. Nunca lanza error y no
// hay que esperarla (no retrasa la respuesta).
const notifyEvent = (event, title) => {

    if (
        !event.isActive ||
        hasEnded(event.endDate)
    ) {
        return;
    }

    const where =
        event.location
            ? ` en ${event.location}`
            : "";

    notifyAllCustomers({
        title,
        message:
            `${event.name}${where} ` +
            `(${formatDate(event.startDate)}). ` +
            "¡Te esperamos!",
        type: "EVENT",
        relatedId: event._id
    });

};

// ===================================
// GET ALL EVENTS
// ===================================
export const getEvents = async (req, res) => {

    try {

        const events = await Event.find()
            .sort({
                startDate: 1
            });

        return res.status(200).json({

            message:
                "Events retrieved successfully",

            events

        });

    } catch (error) {

        console.error(
            "Get events error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving events",

            error: error.message

        });

    }

};

// ===================================
// GET ACTIVE EVENT (pop-up de inicio)
// ===================================
// Público. Devuelve el evento activo que no haya terminado, o
// `event: null` si no hay (la app simplemente no muestra pop-up).
export const getActiveEvent = async (req, res) => {

    try {

        const event = await Event.findOne({
            isActive: true,
            endDate: { $gte: new Date() }
        }).sort({ startDate: 1 });

        return res.status(200).json({

            message:
                "Active event retrieved successfully",

            event: event || null

        });

    } catch (error) {

        console.error(
            "Get active event error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving active event",

            error: error.message

        });

    }

};

// ===================================
// GET EVENT BY ID
// ===================================
export const getEventById = async (req, res) => {

    try {

        if (!mongoose.isValidObjectId(req.params.id)) {

            return res.status(400).json({

                message:
                    "Invalid event id"

            });

        }

        const event =
            await Event.findById(
                req.params.id
            );

        if (!event) {

            return res.status(404).json({

                message:
                    "Event not found"

            });

        }

        return res.status(200).json({

            message:
                "Event retrieved successfully",

            event

        });

    } catch (error) {

        console.error(
            "Get event error:",
            error
        );

        return res.status(500).json({

            message:
                "Error retrieving event",

            error: error.message

        });

    }

};

// ===================================
// CREATE EVENT
// ===================================
// Acepta multipart (imagen en el campo "imagen") o JSON (con una
// URL en `image`).
export const createEvent = async (req, res) => {

    try {

        // En multipart sin campos, req.body puede llegar undefined.
        const body = req.body || {};

        const name = cleanText(body.name);

        // ===================================
        // VALIDATE REQUIRED DATA
        // ===================================

        if (
            !name ||
            !body.startDate ||
            !body.endDate
        ) {

            await discardUploadedImage(req);

            return res.status(400).json({

                message:
                    "Name, startDate and endDate are required"

            });

        }

        // ===================================
        // VALIDATE DATES
        // ===================================

        const parsedStartDate =
            new Date(body.startDate);

        const parsedEndDate =
            new Date(body.endDate);

        if (
            isNaN(parsedStartDate.getTime()) ||
            isNaN(parsedEndDate.getTime())
        ) {

            await discardUploadedImage(req);

            return res.status(400).json({

                message:
                    "Invalid date format"

            });

        }

        if (
            parsedEndDate <
            parsedStartDate
        ) {

            await discardUploadedImage(req);

            return res.status(400).json({

                message:
                    "End date cannot be before start date"

            });

        }

        const isActive =
            body.isActive !== undefined
                ? parseBoolean(body.isActive)
                : true;

        // Un evento que ya terminó no puede quedar activo.
        if (
            isActive &&
            hasEnded(parsedEndDate)
        ) {

            await discardUploadedImage(req);

            return res.status(400).json({

                message:
                    "Event has already ended"

            });

        }

        // ===================================
        // CREATE EVENT
        // ===================================

        const newEvent = new Event({

            name,

            description:
                cleanText(body.description),

            image:
                req.file?.path ||
                cleanText(body.image),

            location:
                cleanText(body.location),

            startDate:
                parsedStartDate,

            endDate:
                parsedEndDate,

            isActive

        });

        // ===================================
        // SAVE EVENT
        // ===================================

        await newEvent.save();

        if (newEvent.isActive) {
            await deactivateOthers(newEvent._id);
        }

        notifyEvent(newEvent, "Nuevo evento");

        return res.status(201).json({

            message:
                "Event created successfully",

            event: newEvent

        });

    } catch (error) {

        await discardUploadedImage(req);

        console.error(
            "Create event error:",
            error
        );

        return res.status(500).json({

            message:
                "Error creating event",

            error: error.message

        });

    }

};

// ===================================
// UPDATE EVENT
// ===================================
// Acepta multipart o JSON. Si llega una imagen nueva reemplaza la
// anterior (que se borra de Cloudinary); si no, se conserva.
export const updateEvent = async (req, res) => {

    try {

        const body = req.body || {};

        if (!mongoose.isValidObjectId(req.params.id)) {

            await discardUploadedImage(req);

            return res.status(400).json({

                message:
                    "Invalid event id"

            });

        }

        // ===================================
        // GET CURRENT EVENT
        // ===================================

        const event =
            await Event.findById(
                req.params.id
            );

        if (!event) {

            await discardUploadedImage(req);

            return res.status(404).json({

                message:
                    "Event not found"

            });

        }

        // ===================================
        // VALIDATE FIELDS
        // ===================================

        if (
            body.name !== undefined &&
            !cleanText(body.name)
        ) {

            await discardUploadedImage(req);

            return res.status(400).json({

                message:
                    "Event name cannot be empty"

            });

        }

        const finalStartDate =
            body.startDate
                ? new Date(body.startDate)
                : event.startDate;

        const finalEndDate =
            body.endDate
                ? new Date(body.endDate)
                : event.endDate;

        if (
            isNaN(finalStartDate.getTime()) ||
            isNaN(finalEndDate.getTime())
        ) {

            await discardUploadedImage(req);

            return res.status(400).json({

                message:
                    "Invalid date format"

            });

        }

        if (
            finalEndDate <
            finalStartDate
        ) {

            await discardUploadedImage(req);

            return res.status(400).json({

                message:
                    "End date cannot be before start date"

            });

        }

        const wantsActive =
            body.isActive !== undefined
                ? parseBoolean(body.isActive)
                : event.isActive;

        // Un evento activo no puede quedar con fecha final pasada.
        if (
            wantsActive &&
            hasEnded(finalEndDate)
        ) {

            await discardUploadedImage(req);

            return res.status(400).json({

                message:
                    "Event has already ended"

            });

        }

        // ===================================
        // UPDATE EVENT
        // ===================================

        const oldImage = event.image;
        const wasActive = event.isActive;

        if (body.name !== undefined)
            event.name = cleanText(body.name);

        if (body.description !== undefined)
            event.description = cleanText(body.description);

        if (body.location !== undefined)
            event.location = cleanText(body.location);

        if (body.startDate)
            event.startDate = finalStartDate;

        if (body.endDate)
            event.endDate = finalEndDate;

        if (body.isActive !== undefined)
            event.isActive = wantsActive;

        if (req.file?.path) {
            event.image = req.file.path;
        } else if (body.image !== undefined) {
            event.image = cleanText(body.image);
        }

        await event.save();

        if (event.isActive) {
            await deactivateOthers(event._id);
        }

        // Editar un evento que ya estaba activo NO avisa (evita spam);
        // solo cuando se reactiva.
        if (!wasActive && event.isActive) {
            notifyEvent(event, "Evento disponible");
        }

        // La imagen anterior se borra solo cuando ya se guardó la nueva.
        if (oldImage && oldImage !== event.image) {
            await deleteCloudinaryImage(oldImage);
        }

        return res.status(200).json({

            message:
                "Event updated successfully",

            event

        });

    } catch (error) {

        await discardUploadedImage(req);

        console.error(
            "Update event error:",
            error
        );

        return res.status(500).json({

            message:
                "Error updating event",

            error: error.message

        });

    }

};

// ===================================
// SET EVENT ACTIVE (PATCH /:id/active)
// ===================================
// Activar un evento desactiva el que estuviera activo.
export const setEventActive = async (req, res) => {

    try {

        const body = req.body || {};

        if (!mongoose.isValidObjectId(req.params.id)) {

            return res.status(400).json({

                message:
                    "Invalid event id"

            });

        }

        if (typeof body.isActive !== "boolean") {

            return res.status(400).json({

                message:
                    "isActive (boolean) is required"

            });

        }

        const event =
            await Event.findById(
                req.params.id
            );

        if (!event) {

            return res.status(404).json({

                message:
                    "Event not found"

            });

        }

        if (
            body.isActive &&
            hasEnded(event.endDate)
        ) {

            return res.status(400).json({

                message:
                    "Event has already ended"

            });

        }

        const wasActive = event.isActive;

        event.isActive = body.isActive;

        await event.save();

        if (event.isActive) {
            await deactivateOthers(event._id);
        }

        // Solo avisa cuando pasa de inactivo a activo (reactivación);
        // volver a enviar "activar" sobre uno ya activo no avisa.
        if (!wasActive && event.isActive) {
            notifyEvent(event, "Evento disponible");
        }

        return res.status(200).json({

            message:
                event.isActive
                    ? "Event activated successfully"
                    : "Event deactivated successfully",

            event

        });

    } catch (error) {

        console.error(
            "Set event active error:",
            error
        );

        return res.status(500).json({

            message:
                "Error updating event status",

            error: error.message

        });

    }

};

// ===================================
// DELETE EVENT
// ===================================
export const deleteEvent = async (req, res) => {

    try {

        if (!mongoose.isValidObjectId(req.params.id)) {

            return res.status(400).json({

                message:
                    "Invalid event id"

            });

        }

        const deletedEvent =
            await Event.findByIdAndDelete(
                req.params.id
            );

        if (!deletedEvent) {

            return res.status(404).json({

                message:
                    "Event not found"

            });

        }

        // Borra la imagen de Cloudinary (si falla solo se registra).
        if (deletedEvent.image) {
            await deleteCloudinaryImage(deletedEvent.image);
        }

        return res.status(200).json({

            message:
                "Event deleted successfully"

        });

    } catch (error) {

        console.error(
            "Delete event error:",
            error
        );

        return res.status(500).json({

            message:
                "Error deleting event",

            error: error.message

        });

    }

};
