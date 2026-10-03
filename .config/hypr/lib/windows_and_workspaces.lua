---@module 'hl'

-- See https://wiki.hypr.land/Configuring/Window-Rules/ for more

-- See https://wiki.hypr.land/Configuring/Workspace-Rules/ for workspace rules

hl.window_rule({
    name  = "suppress-maximize-events",
    match = {
        class = ".*",
    },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = {
        class = "hyprland-run",
    },
    move = { 20, "monitor_h-120" },
    float = true,
})

hl.window_rule({
    name  = "opacity-95-class",
    match = {
        class = "^(code|Kate|jetbrains-.*)$",
    },
    opacity = 0.95,
})

hl.window_rule({
    name  = "opacity-90-class",
    match = {
        class = "^(Postman|DBeaver|Bitwarden|.*qBittorrent|org.pulseaudio.pavucontrol|blueman-manager|steam|org.keepassxc.KeePassXC|com.github.hluk.copyq|com.nextcloud.desktopclient\\..*|org.kde.kleopatra|veracrypt|org.telegram.desktop.*|signal)$",
    },
    opacity = 0.85,
})

-- Transparent browser was a horrible idea.

-- windowrule {

--     name = opacity-firefox

--     match:class = ^(firefox)$

--     opacity = 0.85

-- }

hl.window_rule({
    name  = "chrome-pip",
    match = {
        title = "(Picture in picture)",
    },
    float = true,
    pin = true,
    no_shadow = true,
    size = { "(monitor_w*0.25)", "(monitor_h*0.25)" },
    move = { "(monitor_w*1)-window_w-20", "window_y" },
    no_initial_focus = true,
})

hl.window_rule({
    name  = "qbittorrent-preferences",
    match = {
        class = "org.qbittorrent.qBittorrent",
        title = "Preferences",
    },
    float = false,
    pin = false,
})

hl.window_rule({
    name  = "kdenlive-no-float",
    match = {
        class = "org.kde.kdenlive",
    },
    float = false,
    pin = false,
})
