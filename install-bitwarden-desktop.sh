#!/usr/bin/env bash
set -xeuo pipefail

CURRENT_ARCH="$(uname -m)"

case "${CURRENT_ARCH}" in
x86_64)
    DOWNLOAD_ARCH_KEY="x86_64"
    ;;
*)
    echo "Unsupported architecture: ${CURRENT_ARCH}"
    exit 1
    ;;
esac

TMP_DOWNLOAD_DIRECTORY="${HOME}/.tmp/from_dotfiles_bin"
LATEST_VERSION="2026.1.0"
APPIMAGE_FILE_NAME="Bitwarden-${LATEST_VERSION}-${DOWNLOAD_ARCH_KEY}.AppImage"
APPIMAGE_INSTALL_DIRECTORY="${HOME}/.local/share/bitwarden-desktop"
DOWNLOAD_URI="https://github.com/bitwarden/clients/releases/download/desktop-v${LATEST_VERSION}/${APPIMAGE_FILE_NAME}"

mkdir -p "${APPIMAGE_INSTALL_DIRECTORY}" "${HOME}/.local/share/applications" "${TMP_DOWNLOAD_DIRECTORY}"

if [[ ! -f "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_FILE_NAME}" ]]; then
    echo "Downloading app image."
    curl -fL "${DOWNLOAD_URI}" -o "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_FILE_NAME}"
else
    echo "AppImage File already exists"
fi
rm -f "${APPIMAGE_INSTALL_DIRECTORY}/bitwarden-desktop.AppImage"
cp "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_FILE_NAME}" "${APPIMAGE_INSTALL_DIRECTORY}/bitwarden-desktop.AppImage"
chmod +x "${APPIMAGE_INSTALL_DIRECTORY}/bitwarden-desktop.AppImage"

if [[ ! -f "${APPIMAGE_INSTALL_DIRECTORY}/bitwarden-desktop.png" ]]; then
    echo "Downloading icon file."
    curl -fL "https://bitwarden.com/favicon.png" -o "${APPIMAGE_INSTALL_DIRECTORY}/bitwarden-desktop.png"
fi

tee "${HOME}/.local/share/applications/bitwarden.desktop" <<EOF
[Desktop Entry]
Name=Bitwarden
GenericName=Password Manager
Comment=A secure and free password manager for all of your devices.
Exec=${APPIMAGE_INSTALL_DIRECTORY}/bitwarden-desktop.AppImage --enable-features=UseOzonePlatform --ozone-platform=wayland --password-store=kwallet6 %u
Terminal=false
MimeType=x-scheme-handler/bitwarden
Type=Application
Icon=${APPIMAGE_INSTALL_DIRECTORY}/bitwarden-desktop.png
Categories=Utility;
StartupWMClass=Bitwarden
EOF
