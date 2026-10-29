import test from "node:test";
import assert from "node:assert/strict";

import {
    AVATAR_PRESET_KEYS,
    isValidPreset,
    resolveAvatarType,
    avatarFields
} from "../utils/avatars.js";

test("hay exactamente cinco avatares predefinidos", () => {
    assert.equal(AVATAR_PRESET_KEYS.length, 5);
    assert.equal(new Set(AVATAR_PRESET_KEYS).size, 5);
});

test("solo acepta claves del catálogo", () => {
    assert.equal(isValidPreset("grano"), true);
    assert.equal(isValidPreset("hacker"), false);
    assert.equal(isValidPreset(""), false);
    assert.equal(isValidPreset(null), false);
    assert.equal(isValidPreset({ $ne: "" }), false);
});

test("cuenta anterior con foto se trata como foto", () => {
    const user = { profileImage: "https://img/x.jpg" };
    assert.equal(resolveAvatarType(user), "photo");
    assert.deepEqual(avatarFields(user), {
        avatarType: "photo",
        avatarPreset: "",
        profileImage: "https://img/x.jpg"
    });
});

test("cuenta anterior sin foto no tiene avatar", () => {
    assert.equal(resolveAvatarType({ profileImage: "" }), "none");
    assert.equal(resolveAvatarType({}), "none");
});

test("avatar predefinido no expone la foto", () => {
    const user = {
        avatarType: "preset",
        avatarPreset: "taza",
        profileImage: "https://img/old.jpg"
    };
    assert.deepEqual(avatarFields(user), {
        avatarType: "preset",
        avatarPreset: "taza",
        profileImage: ""
    });
});

test("preset inválido guardado cae al estado coherente", () => {
    assert.equal(
        resolveAvatarType({ avatarType: "preset", avatarPreset: "zzz" }),
        "none"
    );
    assert.equal(
        resolveAvatarType({
            avatarType: "preset",
            avatarPreset: "zzz",
            profileImage: "https://img/y.jpg"
        }),
        "photo"
    );
});

test("foto sin URL no cuenta como foto", () => {
    assert.equal(
        resolveAvatarType({ avatarType: "photo", profileImage: "" }),
        "none"
    );
});
