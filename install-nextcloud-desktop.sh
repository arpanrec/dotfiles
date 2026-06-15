#!/usr/bin/env bash
set -xeuo pipefail

ARCH="$(uname -m)"

if [[ "${ARCH}" != "x86_64" ]]; then
    echo "Nextcloud Desktop AppImage is only available for x86_64. Current: ${ARCH}"
    exit 1
fi

if [[ -z "${NEXTCLOUD_DESKTOP_LATEST_VERSION:-}" ]]; then
    NEXTCLOUD_DESKTOP_LATEST_VERSION="$(
        curl -sSLf --connect-timeout 10 --max-time 60 \
            "https://api.github.com/repos/nextcloud-releases/desktop/releases/latest" |
            jq -r ".tag_name"
    )"
fi

if [[ -z "${NEXTCLOUD_DESKTOP_LATEST_VERSION}" || "${NEXTCLOUD_DESKTOP_LATEST_VERSION}" == "null" ]]; then
    echo "Failed to get latest version."
    exit 1
fi

echo "Latest Nextcloud Desktop release: ${NEXTCLOUD_DESKTOP_LATEST_VERSION}"

INSTALL_DIRECTORY="${HOME}/.local/share/nextcloud-desktop"
APPLICATION_DIRECTORY="${HOME}/.local/share/applications"
TMP_DOWNLOAD_DIRECTORY="${HOME}/.cache/dotfiles-tmp-download-dir"

APPIMAGE_NAME="Nextcloud-${NEXTCLOUD_DESKTOP_LATEST_VERSION#v}-x86_64.AppImage"

mkdir -p \
    "${INSTALL_DIRECTORY}" \
    "${APPLICATION_DIRECTORY}" \
    "${TMP_DOWNLOAD_DIRECTORY}"

echo "Downloading Nextcloud Desktop ${NEXTCLOUD_DESKTOP_LATEST_VERSION}"

if [[ ! -f "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_NAME}" ]]; then
    curl -fL --connect-timeout 10 --max-time 600 \
        "https://github.com/nextcloud-releases/desktop/releases/download/${NEXTCLOUD_DESKTOP_LATEST_VERSION}/${APPIMAGE_NAME}" \
        -o "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_NAME}"
else
    echo "AppImage already exists"
fi

echo "Installing Nextcloud Desktop"

install -Dm755 \
    "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_NAME}" \
    "${INSTALL_DIRECTORY}/nextcloud-desktop.AppImage"

echo "Extracting icon"

"${INSTALL_DIRECTORY}/nextcloud-desktop.AppImage" \
    --appimage-extract \
    usr/share/icons/hicolor/512x512/apps/Nextcloud.png >/dev/null 2>&1 || true

if [[ -f squashfs-root/usr/share/icons/hicolor/512x512/apps/Nextcloud.png ]]; then
    mv \
        squashfs-root/usr/share/icons/hicolor/512x512/apps/Nextcloud.png \
        "${INSTALL_DIRECTORY}/nextcloud-desktop.png"
fi

rm -rf squashfs-root

tee "${APPLICATION_DIRECTORY}/nextcloud-desktop.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=Nextcloud
GenericName=File Sync Client
Comment=Sync your files with your Nextcloud server
Path=${INSTALL_DIRECTORY}/
Exec=${INSTALL_DIRECTORY}/nextcloud-desktop.AppImage %U
Icon=${INSTALL_DIRECTORY}/nextcloud-desktop.png
Categories=Network;FileTransfer;
StartupNotify=true
MimeType=x-scheme-handler/nc;
Keywords=Nextcloud;Sync;Cloud;Files;
EOF

echo "Nextcloud Desktop installed successfully!"
