#!/usr/bin/env bash
set -xeuo pipefail

BRUNO_LATEST_VERSION="$(
    curl -sSLf --connect-timeout 10 --max-time 60 \
        "https://api.github.com/repos/usebruno/bruno/releases/latest" |
        jq -r ".tag_name"
)"

if [[ -z "${BRUNO_LATEST_VERSION}" || "${BRUNO_LATEST_VERSION}" == "null" ]]; then
    echo "Failed to get latest version."
    exit 1
fi

ARCH="$(uname -m)"

case "${ARCH}" in
x86_64)
    BRUNO_ARCH="x86_64"
    ;;
aarch64 | arm64)
    BRUNO_ARCH="arm64"
    ;;
*)
    echo "Unsupported architecture: ${ARCH}"
    exit 1
    ;;
esac

INSTALL_DIRECTORY="${HOME}/.local/share/bruno"
APPLICATION_DIRECTORY="${HOME}/.local/share/applications"
TMP_DOWNLOAD_DIRECTORY="${HOME}/.cache/dotfiles-tmp-download-dir"

APPIMAGE_NAME="bruno_${BRUNO_LATEST_VERSION#v}_${BRUNO_ARCH}_linux.AppImage"

mkdir -p \
    "${INSTALL_DIRECTORY}" \
    "${APPLICATION_DIRECTORY}" \
    "${TMP_DOWNLOAD_DIRECTORY}"

echo "Downloading Bruno ${BRUNO_LATEST_VERSION} for ${BRUNO_ARCH} architecture"

if [[ ! -f "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_NAME}" ]]; then
    curl -fL --connect-timeout 10 --max-time 600 \
        "https://github.com/usebruno/bruno/releases/download/${BRUNO_LATEST_VERSION}/${APPIMAGE_NAME}" \
        -o "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_NAME}"
else
    echo "AppImage already exists"
fi

echo "Installing Bruno"

cp \
    "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_NAME}" \
    "${INSTALL_DIRECTORY}/bruno.AppImage"

chmod +x "${INSTALL_DIRECTORY}/bruno.AppImage"

tee "${APPLICATION_DIRECTORY}/bruno.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=Bruno
GenericName=API Client
Comment=Opensource IDE For Exploring and Testing API's
Path=${INSTALL_DIRECTORY}/
Exec=${INSTALL_DIRECTORY}/bruno.AppImage %U
Icon=${INSTALL_DIRECTORY}/bruno.png
Categories=Development;Network;
StartupNotify=true
Keywords=API;REST;GraphQL;HTTP;
EOF

echo "Extracting icon"

"${INSTALL_DIRECTORY}/bruno.AppImage" \
    --appimage-extract \
    usr/share/icons/hicolor/512x512/apps/bruno.png >/dev/null 2>&1 || true

if [[ -f squashfs-root/usr/share/icons/hicolor/512x512/apps/bruno.png ]]; then
    mv squashfs-root/usr/share/icons/hicolor/512x512/apps/bruno.png \
        "${INSTALL_DIRECTORY}/bruno.png"
fi

rm -rf squashfs-root

echo "Bruno installed successfully!"
