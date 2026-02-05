#!/usr/bin/env bash
set -xeuo pipefail

CURRENT_ARCH="$(uname -m)"

case "${CURRENT_ARCH}" in
x86_64)
    DOWNLOAD_ARCH_KEY=""
    ;;
*)
    echo "Unsupported architecture: ${CURRENT_ARCH}"
    exit 1
    ;;
esac

TMP_DOWNLOAD_DIRECTORY="${HOME}/.tmp/from_dotfiles_bin"
LATEST_VERSION="11.83.2"
POSTMAN_ZIP_FILE_NAME="Postman-${LATEST_VERSION}${DOWNLOAD_ARCH_KEY}.tar.gz"
POSTMAN_INSTALL_DIRECTORY="${HOME}/.local/share/Postman"
DOWNLOAD_URI="https://dl.pstmn.io/download/version/${LATEST_VERSION}/linux"

rm -rf "${POSTMAN_INSTALL_DIRECTORY}"
mkdir -p "${POSTMAN_INSTALL_DIRECTORY}" "${HOME}/.local/share/applications" "${TMP_DOWNLOAD_DIRECTORY}"

if [[ ! -f "${TMP_DOWNLOAD_DIRECTORY}/${POSTMAN_ZIP_FILE_NAME}" ]]; then
    echo "Downloading app image."
    curl -fL "${DOWNLOAD_URI}" -o "${TMP_DOWNLOAD_DIRECTORY}/${POSTMAN_ZIP_FILE_NAME}"
else
    echo "AppImage File already exists"
fi
tar -zxvf "${TMP_DOWNLOAD_DIRECTORY}/${POSTMAN_ZIP_FILE_NAME}" -C "${POSTMAN_INSTALL_DIRECTORY}" --strip-components=1

tee "${HOME}/.local/share/applications/postman.desktop" <<EOF
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=${POSTMAN_INSTALL_DIRECTORY}/Postman %u
Icon=${POSTMAN_INSTALL_DIRECTORY}/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
EOF
