#!/usr/bin/env bash
set -euo pipefail

CURRENT_ARCH="$(uname -m)"

case "${CURRENT_ARCH}" in
x86_64)
    DOWNLOAD_ARCH_KEY="x86_64"
    ;;
aarch64)
    DOWNLOAD_ARCH_KEY="arm64"
    ;;
*)
    echo "Unsupported architecture: ${CURRENT_ARCH}"
    exit 1
    ;;
esac

if [[ -z "${DRAWIO_LATEST_VERSION:-}" ]]; then
    DRAWIO_LATEST_VERSION="$(
        curl -sSLf --connect-timeout 10 --max-time 60 \
            "https://api.github.com/repos/jgraph/drawio-desktop/releases/latest" |
            jq -r ".tag_name"
    )"
fi

if [[ -z "${DRAWIO_LATEST_VERSION}" || "${DRAWIO_LATEST_VERSION}" == "null" ]]; then
    echo "Failed to get latest version."
    exit 1
fi

echo "Latest draw.io Desktop release: ${DRAWIO_LATEST_VERSION}"

DRAWIO_VERSION="${DRAWIO_LATEST_VERSION#v}"

INSTALL_DIRECTORY="${HOME}/.local/share/drawio-desktop"
APPLICATION_DIRECTORY="${HOME}/.local/share/applications"
TMP_DOWNLOAD_DIRECTORY="${HOME}/.cache/dotfiles-tmp-download-dir"

APPIMAGE_NAME="drawio-${DOWNLOAD_ARCH_KEY}-${DRAWIO_VERSION}.AppImage"

mkdir -p \
    "${INSTALL_DIRECTORY}" \
    "${APPLICATION_DIRECTORY}" \
    "${TMP_DOWNLOAD_DIRECTORY}"

echo "Downloading draw.io Desktop ${DRAWIO_LATEST_VERSION}"

if [[ ! -f "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_NAME}" ]]; then
    curl -fL --connect-timeout 10 --max-time 600 \
        "https://github.com/jgraph/drawio-desktop/releases/download/${DRAWIO_LATEST_VERSION}/${APPIMAGE_NAME}" \
        -o "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_NAME}"
else
    echo "AppImage already exists"
fi

echo "Installing draw.io Desktop"

install -Dm755 \
    "${TMP_DOWNLOAD_DIRECTORY}/${APPIMAGE_NAME}" \
    "${INSTALL_DIRECTORY}/drawio-desktop.AppImage"

echo "Extracting icon"

(
    cd "${INSTALL_DIRECTORY}"
    ./drawio-desktop.AppImage \
        --appimage-extract \
        usr/share/icons/hicolor/512x512/apps/drawio.png >/dev/null 2>&1 || true
)

if [[ -f "${INSTALL_DIRECTORY}/squashfs-root/usr/share/icons/hicolor/512x512/apps/drawio.png" ]]; then
    mv \
        "${INSTALL_DIRECTORY}/squashfs-root/usr/share/icons/hicolor/512x512/apps/drawio.png" \
        "${INSTALL_DIRECTORY}/drawio-desktop.png"
fi

rm -rf "${INSTALL_DIRECTORY}/squashfs-root"

tee "${APPLICATION_DIRECTORY}/drawio-desktop.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=draw.io
GenericName=Diagram Editor
Comment=Create diagrams, flowcharts, and mockups
Path=${INSTALL_DIRECTORY}/
Exec=${INSTALL_DIRECTORY}/drawio-desktop.AppImage %U
Icon=${INSTALL_DIRECTORY}/drawio-desktop.png
Categories=Graphics;Office;
StartupNotify=true
StartupWMClass=draw-io
MimeType=application/vnd.jgraph.mxfile;
Keywords=Diagram;Flowchart;UML;Mockup;
EOF

echo "draw.io Desktop installed successfully!"
