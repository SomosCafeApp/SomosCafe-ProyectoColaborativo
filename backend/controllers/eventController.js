import Event from "../models/eventModel.js";

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
// GET EVENT BY ID
// ===================================
export const getEventById = async (req, res) => {

    try {

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
export const createEvent = async (req, res) => {

    try {

        const {
            name,
            description,
            image,
            location,
            startDate,
            endDate,
            isActive
        } = req.body;

        // ===================================
        // VALIDATE REQUIRED DATA
        // ===================================

        if (
            !name ||
            !startDate ||
            !endDate
        ) {

            return res.status(400).json({

                message:
                    "Name, startDate and endDate are required"

            });

        }

        // ===================================
        // VALIDATE DATES
        // ===================================

        const parsedStartDate =
            new Date(startDate);

        const parsedEndDate =
            new Date(endDate);

        if (
            isNaN(parsedStartDate.getTime()) ||
            isNaN(parsedEndDate.getTime())
        ) {

            return res.status(400).json({

                message:
                    "Invalid date format"

            });

        }

        if (
            parsedEndDate <
            parsedStartDate
        ) {

            return res.status(400).json({

                message:
                    "End date cannot be before start date"

            });

        }

        // ===================================
        // CREATE EVENT
        // ===================================

        const newEvent = new Event({

            name:
                name.trim(),

            description:
                description
                    ? description.trim()
                    : "",

            image:
                image
                    ? image.trim()
                    : "",

            location:
                location
                    ? location.trim()
                    : "",

            startDate:
                parsedStartDate,

            endDate:
                parsedEndDate,

            isActive:
                isActive !== undefined
                    ? isActive
                    : true

        });

        // ===================================
        // SAVE EVENT
        // ===================================

        await newEvent.save();

        return res.status(201).json({

            message:
                "Event created successfully",

            event: newEvent

        });

    } catch (error) {

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
export const updateEvent = async (req, res) => {

    try {

        const {
            name,
            description,
            image,
            location,
            startDate,
            endDate,
            isActive
        } = req.body;

        // ===================================
        // VALIDATE DATES IF PROVIDED
        // ===================================

        if (
            startDate &&
            isNaN(
                new Date(startDate).getTime()
            )
        ) {

            return res.status(400).json({

                message:
                    "Invalid start date"

            });

        }

        if (
            endDate &&
            isNaN(
                new Date(endDate).getTime()
            )
        ) {

            return res.status(400).json({

                message:
                    "Invalid end date"

            });

        }

        // ===================================
        // GET CURRENT EVENT
        // ===================================

        const currentEvent =
            await Event.findById(
                req.params.id
            );

        if (!currentEvent) {

            return res.status(404).json({

                message:
                    "Event not found"

            });

        }

        // ===================================
        // CALCULATE FINAL DATES
        // ===================================

        const finalStartDate =
            startDate
                ? new Date(startDate)
                : currentEvent.startDate;

        const finalEndDate =
            endDate
                ? new Date(endDate)
                : currentEvent.endDate;

        // ===================================
        // VALIDATE DATE ORDER
        // ===================================

        if (
            finalEndDate <
            finalStartDate
        ) {

            return res.status(400).json({

                message:
                    "End date cannot be before start date"

            });

        }

        // ===================================
        // UPDATE EVENT
        // ===================================

        const updatedEvent =
            await Event.findByIdAndUpdate(

                req.params.id,

                {
                    ...(name !== undefined && {
                        name:
                            name.trim()
                    }),

                    ...(description !== undefined && {
                        description:
                            description.trim()
                    }),

                    ...(image !== undefined && {
                        image:
                            image.trim()
                    }),

                    ...(location !== undefined && {
                        location:
                            location.trim()
                    }),

                    ...(startDate !== undefined && {
                        startDate:
                            finalStartDate
                    }),

                    ...(endDate !== undefined && {
                        endDate:
                            finalEndDate
                    }),

                    ...(isActive !== undefined && {
                        isActive
                    })

                },

                {
                    new: true,
                    runValidators: true
                }

            );

        return res.status(200).json({

            message:
                "Event updated successfully",

            event:
                updatedEvent

        });

    } catch (error) {

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
// DELETE EVENT
// ===================================
export const deleteEvent = async (req, res) => {

    try {

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