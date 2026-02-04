#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${HOME}/.config/systemd/user/xdg-desktop-portal.service.d" \
    "${HOME}/.config/xdg-desktop-portal" \
    "${HOME}/.local/share/dbus-1/services"

tee "${HOME}/.config/systemd/user/xdg-desktop-portal.service.d/override.conf" <<EOF
[Service]
Environment="XDG_CURRENT_DESKTOP=Hyprland"

EOF
chmod 644 "${HOME}/.config/systemd/user/xdg-desktop-portal.service.d/override.conf"

tee "${HOME}/.config/xdg-desktop-portal/portals.conf" <<EOF
[preferred]

org.freedesktop.impl.portal.FileChooser=kde

EOF
chmod 644 "${HOME}/.config/xdg-desktop-portal/portals.conf"

tee "${HOME}/.local/share/dbus-1/services/org.freedesktop.secrets.service" <<EOF
[D-BUS Service]

Name=org.freedesktop.secrets
Exec=/usr/bin/kwalletd6

EOF
chmod 644 "${HOME}/.local/share/dbus-1/services/org.freedesktop.secrets.service"

echo "Creating XDG user directories"

xdg_dirs=(
  XDG_DESKTOP_DIR
  XDG_DOWNLOAD_DIR
  XDG_TEMPLATES_DIR
  XDG_PUBLICSHARE_DIR
  XDG_DOCUMENTS_DIR
  XDG_MUSIC_DIR
  XDG_PICTURES_DIR
  XDG_VIDEOS_DIR
)

for var in "${xdg_dirs[@]}"; do
    xdg_dir="${!var:-}"

    if [[ -z "${xdg_dir}" ]]; then
        echo "$var is not set."
        continue
    fi

    if [[ -d "${xdg_dir}" ]]; then
        echo "Exists: ${xdg_dir}"
    else
        mkdir -p "${xdg_dir}"
        echo "Created: ${xdg_dir}"
    fi
done

echo "XDG user directories setup complete"

systemctl --user daemon-reload


