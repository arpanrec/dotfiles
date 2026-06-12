#!/usr/bin/env bash
set -xeuo pipefail

JOPLIN_LATEST_VERSION="$(
    curl -sSLf --connect-timeout 10 --max-time 60 \
        "https://api.github.com/repos/laurent22/joplin/releases/latest" |
        jq -r ".tag_name"
)"

if [[ -z "${JOPLIN_LATEST_VERSION}" || "${JOPLIN_LATEST_VERSION}" == "null" ]]; then
    echo "Failed to get latest version."
    exit 1
fi

ARCH="$(uname -m)"

if [[ "${ARCH}" != "x86_64" ]]; then
    echo "Joplin Desktop AppImage is only available for x86_64."
    exit 1
fi

INSTALL_DIRECTORY="${HOME}/.local/share/joplin"
APPLICATION_DIRECTORY="${HOME}/.local/share/applications"
TMP_DOWNLOAD_DIRECTORY="${HOME}/.cache/dotfiles-tmp-download-dir"

APPIMAGE_NAME="Joplin-${JOPLIN_LATEST_VERSION#v}.AppImage"

mkdir -p "${INSTALL_DIRECTORY}" \
    "${APPLICATION_DIRECTORY}" \
    "${TMP_DOWNLOAD_DIRECTORY}"

echo "Downloading Joplin ${JOPLIN_LATEST_VERSION}"

if [[ ! -f "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_NAME}" ]]; then
    curl -fL --connect-timeout 10 --max-time 600 \
        "https://github.com/laurent22/joplin/releases/download/${JOPLIN_LATEST_VERSION}/${APPIMAGE_NAME}" \
        -o "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_NAME}"
else
    echo "AppImage already exists"
fi

echo "Installing Joplin"

cp "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_NAME}" \
    "${INSTALL_DIRECTORY}/joplin.AppImage"

chmod +x "${INSTALL_DIRECTORY}/joplin.AppImage"

echo "Extracting icon"

"${INSTALL_DIRECTORY}/joplin.AppImage" \
    --appimage-extract \
    usr/share/icons/hicolor/512x512/apps/joplin.png >/dev/null 2>&1 || true

if [[ -f squashfs-root/usr/share/icons/hicolor/512x512/apps/joplin.png ]]; then
    mv squashfs-root/usr/share/icons/hicolor/512x512/apps/joplin.png \
        "${INSTALL_DIRECTORY}/joplin.png"
fi

rm -rf squashfs-root

tee "${APPLICATION_DIRECTORY}/joplin.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=Joplin
GenericName=Note Taking Application
Comment=Open source note taking and to-do application
Path=${INSTALL_DIRECTORY}/
Exec=${INSTALL_DIRECTORY}/joplin.AppImage %U
Icon=${INSTALL_DIRECTORY}/joplin.png
Categories=Office;Utility;
StartupNotify=true
Keywords=Notes;Markdown;Todo;Knowledge;
EOF

echo "Joplin installed successfully!"
