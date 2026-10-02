---@module 'hl'

-- See https://wiki.hypr.land/Configuring/Keywords/

local my_programs = require("lib.my_programs")

local mainMod = "SUPER"

-- Sets "Windows" key as main modifier

hl.bind("PRINT", hl.dsp.exec_cmd("hyprpicker -r -z & sleep 0.1; hyprshot -m region --clipboard-only"))

-- Example binds, see https://wiki.hypr.land/Configuring/Binds/ for more

hl.bind(mainMod .. " + " .. "Q", hl.dsp.exec_cmd(my_programs.terminal))

hl.bind(mainMod .. " + " .. "W", hl.dsp.window.close())

hl.bind(mainMod .. " + " .. "M",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))

hl.bind(mainMod .. " + " .. "E", hl.dsp.exec_cmd(my_programs.fileManager))

hl.bind(mainMod .. " + " .. "L", hl.dsp.exec_cmd("hyprlock"))

hl.bind(mainMod .. " + " .. "V", hl.dsp.window.float())

hl.bind(mainMod .. " + " .. "SPACE", hl.dsp.exec_cmd(my_programs.menu))

-- Using copyq from tray instate.

-- bind = $mainMod SHIFT, SPACE, exec, cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy

hl.bind(mainMod .. " + " .. "P", hl.dsp.window.pseudo())

-- dwindle

-- bind = $mainMod, J, togglesplit, # dwindle

hl.bind(mainMod .. " + " .. "J", hl.dsp.layout("togglesplit"))

-- Move focus with mainMod + arrow keys

hl.bind(mainMod .. " + " .. "left", hl.dsp.focus({ direction = "left" }))

hl.bind(mainMod .. " + " .. "right", hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + " .. "up", hl.dsp.focus({ direction = "up" }))

hl.bind(mainMod .. " + " .. "down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]

hl.bind(mainMod .. " + " .. 1, hl.dsp.focus({ workspace = 1 }))

hl.bind(mainMod .. " + " .. 2, hl.dsp.focus({ workspace = 2 }))

hl.bind(mainMod .. " + " .. 3, hl.dsp.focus({ workspace = 3 }))

hl.bind(mainMod .. " + " .. 4, hl.dsp.focus({ workspace = 4 }))

hl.bind(mainMod .. " + " .. 5, hl.dsp.focus({ workspace = 5 }))

hl.bind(mainMod .. " + " .. 6, hl.dsp.focus({ workspace = 6 }))

hl.bind(mainMod .. " + " .. 7, hl.dsp.focus({ workspace = 7 }))

hl.bind(mainMod .. " + " .. 8, hl.dsp.focus({ workspace = 8 }))

hl.bind(mainMod .. " + " .. 9, hl.dsp.focus({ workspace = 9 }))

hl.bind(mainMod .. " + " .. 0, hl.dsp.focus({ workspace = 10 }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 1, hl.dsp.window.move({ workspace = 1 }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 2, hl.dsp.window.move({ workspace = 2 }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 3, hl.dsp.window.move({ workspace = 3 }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 4, hl.dsp.window.move({ workspace = 4 }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 5, hl.dsp.window.move({ workspace = 5 }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 6, hl.dsp.window.move({ workspace = 6 }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 7, hl.dsp.window.move({ workspace = 7 }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 8, hl.dsp.window.move({ workspace = 8 }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 9, hl.dsp.window.move({ workspace = 9 }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 0, hl.dsp.window.move({ workspace = 10 }))

-- Example special workspace (scratchpad)

hl.bind(mainMod .. " + " .. "S", hl.dsp.workspace.toggle_special("magic"))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll

hl.bind(mainMod .. " + " .. "mouse_down", hl.dsp.focus({ workspace = "e+1" }))

hl.bind(mainMod .. " + " .. "mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging

hl.bind(mainMod .. " + " .. "mouse:272", hl.dsp.window.drag(), { mouse = true })

hl.bind(mainMod .. " + " .. "mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { repeating = true, locked = true })

hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { repeating = true, locked = true })

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { repeating = true, locked = true })

hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { repeating = true, locked = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { repeating = true, locked = true })

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { repeating = true, locked = true })

-- Requires playerctl

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })

hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Move workspace to another monitor

hl.bind("CTRL + ALT" .. " + " .. mainMod .. " + " .. "SHIFT" .. " + " .. "comma",
    hl.dsp.workspace.move({ monitor = "l" }))

hl.bind("CTRL + ALT" .. " + " .. mainMod .. " + " .. "SHIFT" .. " + " .. "period",
    hl.dsp.workspace.move({ monitor = "r" }))

hl.bind(mainMod .. " + " .. "F", hl.dsp.window.fullscreen_state({ internal = 2, client = 0, action = "toggle" }))

-- From old bindings

hl.bind(mainMod .. " + " .. "Tab", hl.dsp.focus({ workspace = "e+1" }))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "Tab", hl.dsp.focus({ workspace = "e-1" }))

hl.bind("ALT + Tab", hl.dsp.window.cycle_next())

hl.bind("ALT + Tab", hl.dsp.window.bring_to_top())

hl.bind("ALT + SHIFT + Tab", hl.dsp.window.cycle_next({ next = false }))

hl.bind("ALT + F4", hl.dsp.window.close())
