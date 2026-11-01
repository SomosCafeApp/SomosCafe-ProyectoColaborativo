import test from "node:test";
import assert from "node:assert/strict";

import {
    buildMessage,
    ANDROID_CHANNEL_ID,
    ANDROID_NOTIFICATION_ICON,
    ANDROID_NOTIFICATION_COLOR
} from "../utils/push.js";

const types = ["NEWS", "PROMOTION", "COUPON", "EVENT", "ORDER_STATUS", "GENERAL"];

test("todo push lleva el icono y color de marca de Android", () => {
    for (const type of types) {
        const m = buildMessage("tok", { _id: "1", type, title: "T", message: "M", relatedId: "abc" });
        assert.equal(m.android.notification.icon, ANDROID_NOTIFICATION_ICON);
        assert.equal(m.android.notification.color, ANDROID_NOTIFICATION_COLOR);
        assert.equal(m.android.notification.channelId, ANDROID_CHANNEL_ID);
        assert.equal(m.data.type, type);
        assert.equal(m.data.relatedId, "abc");
    }
});

test("el icono es el drawable de la app y el color es hexadecimal", () => {
    assert.equal(ANDROID_NOTIFICATION_ICON, "notification_icon");
    assert.match(ANDROID_NOTIFICATION_COLOR, /^#[0-9A-F]{6}$/i);
});

test("los valores de data son strings (FCM lo exige) y relatedId puede faltar", () => {
    const m = buildMessage("tok", { _id: 7, title: "T", message: "M" });
    assert.equal(m.data.notificationId, "7");
    assert.equal(m.data.type, "GENERAL");
    assert.equal(m.data.relatedId, "");
    for (const v of Object.values(m.data)) assert.equal(typeof v, "string");
});
