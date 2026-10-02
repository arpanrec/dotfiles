---@module 'hl'

-- https://wiki.hypr.land/Configuring/Variables/#input

hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        -- -1.0 - 1.0, 0 means no modification.
        touchpad = {
            natural_scroll = false,
        },
    },
})

-- See https://wiki.hypr.land/Configuring/Gestures

hl.gesture({
    ["fingers"] = 3,
    ["direction"] = "horizontal",
    ["action"] = "workspace",
})

-- Example per-device config

-- See https://wiki.hypr.land/Configuring/Keywords/#per-device-input-configs for more

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})
