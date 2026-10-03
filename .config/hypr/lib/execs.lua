---@module 'hl'

-- exec-once = blueman-applet # Moved to waybar for active status

-- kded6 needs to be started after waybar, or else waybar tray will not showup.

-- https://github.com/Alexays/Waybar/issues/3468#issuecomment-2444272406

-- exec-once = waybar && kded6

-- exec-once = systemctl --user start hyprpolkitagent

-- https://wiki.hypr.land/Useful-Utilities/Clipboard-Managers/#cliphist

-- Stores only text data

-- Stores only image data

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/lib/pam_kwallet_init")
    hl.exec_cmd("kwalletd6")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("waybar")
    hl.exec_cmd("copyq --start-server")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dunst")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("~/.config/hypr/set-gpg-pinentry-program.sh")
    hl.exec_cmd("~/.config/hypr/fix-xdg-portals.sh && systemctl --user start xdg-user-dirs.service")
    hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland")
    hl.exec_cmd("systemctl --user start pipewire")
    hl.exec_cmd("systemctl --user start wireplumber")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("konsole")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("kanshi")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("wl-clip-persist --clipboard regular")
    hl.exec_cmd("nextcloud")
    hl.exec_cmd("~/.config/hypr/set-defaults.sh")
end)
