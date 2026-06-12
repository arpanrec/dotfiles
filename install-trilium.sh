#!/usr/bin/env bash
set -xeuo pipefail

TRILIUM_LATEST_VERSION="$(
    curl -sSLf --connect-timeout 10 --max-time 60 \
        "https://api.github.com/repos/TriliumNext/Trilium/releases/latest" |
        jq -r ".tag_name"
)"

if [[ -z "${TRILIUM_LATEST_VERSION}" || "${TRILIUM_LATEST_VERSION}" == "null" ]]; then
    echo "Failed to get latest version."
    exit 1
fi

ARCH="$(uname -m)"

case "${ARCH}" in
x86_64)
    TRILIUM_ARCH="x64"
    ;;
aarch64 | arm64)
    TRILIUM_ARCH="arm64"
    ;;
*)
    echo "Unsupported architecture: ${ARCH}"
    exit 1
    ;;
esac

INSTALL_DIRECTORY="${HOME}/.local/share/trilium"
APPLICATION_DIRECTORY="${HOME}/.local/share/applications"
TMP_DOWNLOAD_DIRECTORY="${HOME}/.cache/dotfiles-tmp-download-dir"

APPIMAGE_NAME="TriliumNotes-${TRILIUM_LATEST_VERSION}-linux-${TRILIUM_ARCH}.AppImage"

mkdir -p \
    "${INSTALL_DIRECTORY}" \
    "${APPLICATION_DIRECTORY}" \
    "${TMP_DOWNLOAD_DIRECTORY}"

echo "Downloading Trilium ${TRILIUM_LATEST_VERSION} for ${TRILIUM_ARCH}"

if [[ ! -f "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_NAME}" ]]; then
    curl -fL --connect-timeout 10 --max-time 600 \
        "https://github.com/TriliumNext/Trilium/releases/download/${TRILIUM_LATEST_VERSION}/${APPIMAGE_NAME}" \
        -o "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_NAME}"
else
    echo "AppImage already exists"
fi

echo "Installing Trilium"

install -Dm755 \
    "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_NAME}" \
    "${INSTALL_DIRECTORY}/trilium.AppImage"

echo "Extracting icon"

"${INSTALL_DIRECTORY}/trilium.AppImage" \
    --appimage-extract \
    usr/share/icons/hicolor/512x512/apps/trilium.png >/dev/null 2>&1 || true

if [[ -f squashfs-root/usr/share/icons/hicolor/512x512/apps/trilium.png ]]; then
    mv \
        squashfs-root/usr/share/icons/hicolor/512x512/apps/trilium.png \
        "${INSTALL_DIRECTORY}/trilium.png"
fi

rm -rf squashfs-root

tee "${APPLICATION_DIRECTORY}/trilium.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=Trilium Notes
GenericName=Knowledge Base
Comment=Build your personal knowledge base
Path=${INSTALL_DIRECTORY}/
Exec=${INSTALL_DIRECTORY}/trilium.AppImage %U
Icon=${INSTALL_DIRECTORY}/trilium.png
Categories=Office;Utility;
StartupNotify=true
Keywords=Notes;Knowledge;Wiki;PKM;
EOF

echo "Trilium installed successfully!"
