---@module 'hl'

-- Refer to https://wiki.hypr.land/Configuring/Variables/

-- https://wiki.hypr.land/Configuring/Variables/#general

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 20,
        border_size = 2,
        -- https://wiki.hypr.land/Configuring/Variables/#variable-types for info about colors
        -- Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,
        -- Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on
        allow_tearing = false,
        layout = "dwindle",
        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
    },
})

-- https://wiki.hypr.land/Configuring/Variables/#decoration

hl.config({
    decoration = {
        rounding = 10,
        rounding_power = 2,
        -- Change transparency of focused and unfocused windows
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
        -- https://wiki.hypr.land/Configuring/Variables/#blur
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },
})

-- https://wiki.hypr.land/Configuring/Variables/#animations

hl.config({
    animations = {
        enabled = true,
        -- Default curves, see https://wiki.hypr.land/Configuring/Animations/#curves
        --        NAME,           X0,   Y0,   X1,   Y1
        -- Default animations, see https://wiki.hypr.land/Configuring/Animations/
        --           NAME,          ONOFF, SPEED, CURVE,        [STYLE]
        -- animation = workspaces,    1,     1.94,  almostLinear, fade
    },
})
hl.curve("easeOutQuint", {
    type = "bezier",
    points = { { 0.23, 1 }, { 0.32, 1 } },
})
hl.curve("easeInOutCubic", {
    type = "bezier",
    points = { { 0.65, 0.05 }, { 0.36, 1 } },
})
hl.curve("linear", {
    type = "bezier",
    points = { { 0, 0 }, { 1, 1 } },
})
hl.curve("almostLinear", {
    type = "bezier",
    points = { { 0.5, 0.5 }, { 0.75, 1 } },
})
hl.curve("quick", {
    type = "bezier",
    points = { { 0.15, 0 }, { 0.1, 1 } },
})
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })
hl.curve("customBezier", {
    type = "bezier",
    points = { { 0.19, 1 }, { 0.52, 0.35 } },
})
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "customBezier" })

-- See https://wiki.hypr.land/Configuring/Dwindle-Layout/ for more

hl.config({
    dwindle = {
        preserve_split = true,
        -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Master-Layout/ for more

hl.config({
    master = {
        new_status = "master",
    },
})

-- https://wiki.hypr.land/Configuring/Variables/#misc

hl.config({
    misc = {
        force_default_wallpaper = -1,
        -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = false,
        -- If true disables the random hyprland logo / anime girl background. :(
    },
})

hl.config({
    xwayland = {
        force_zero_scaling = true,
        -- Fix blur in X11 app like steam, vlc, onlyoffice etc.
    },
})

hl.config({
    cursor = {
        -- https://www.reddit.com/r/hyprland/comments/1dgisq3/comment/l8scapo/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1
        -- no_hardware_cursors = true
    },
})
