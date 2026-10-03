#!/usr/bin/env bash
set -euo pipefail

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
