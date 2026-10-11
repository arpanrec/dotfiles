#!/usr/bin/env bash
set -euo pipefail

CURRENT_ARCH="$(uname -m)"

case "${CURRENT_ARCH}" in
x86_64)
    DOWNLOAD_ARCH_KEY="x64"
    ;;
aarch64 | arm64)
    DOWNLOAD_ARCH_KEY="arm64"
    ;;
*)
    echo "Unsupported architecture: ${CURRENT_ARCH}"
    exit 1
    ;;
esac

ANTIGRAVITY_CLI_LATEST_VERSION="$(curl -sSfL --connect-timeout 10 --max-time 60 \
    "https://api.github.com/repos/google-antigravity/antigravity-cli/releases/latest" |
    jq -r ".tag_name")"

if [[ -z "${ANTIGRAVITY_CLI_LATEST_VERSION}" || "${ANTIGRAVITY_CLI_LATEST_VERSION}" == "null" ]]; then
    echo "Failed to get latest version."
    exit 1
fi

echo "Installing Antigravity CLI version ${ANTIGRAVITY_CLI_LATEST_VERSION}"

TMP_DOWNLOAD_DIRECTORY="${HOME}/.cache/dotfiles-tmp-download-dir"
INSTALL_DIRECTORY="${HOME}/.local/share/antigravity-cli"
ARCHIVE_NAME="agy_cli_linux_${DOWNLOAD_ARCH_KEY}.tar.gz"
ARCHIVE_PATH="${TMP_DOWNLOAD_DIRECTORY}/antigravity-cli-${ANTIGRAVITY_CLI_LATEST_VERSION}-${ARCHIVE_NAME}"

mkdir -p "${TMP_DOWNLOAD_DIRECTORY}" "${INSTALL_DIRECTORY}" "${HOME}/.local/bin"

echo "Downloading Antigravity CLI ${ANTIGRAVITY_CLI_LATEST_VERSION} for ${CURRENT_ARCH} architecture"

if [[ ! -f "${ARCHIVE_PATH}" ]]; then
    curl -fL --connect-timeout 10 --max-time 600 \
        "https://github.com/google-antigravity/antigravity-cli/releases/download/${ANTIGRAVITY_CLI_LATEST_VERSION}/${ARCHIVE_NAME}" \
        -o "${ARCHIVE_PATH}"
else
    echo "Archive already exists"
fi

rm -rf "${INSTALL_DIRECTORY}"
mkdir -p "${INSTALL_DIRECTORY}"

tar -xzf "${ARCHIVE_PATH}" -C "${INSTALL_DIRECTORY}"

if [[ ! -f "${INSTALL_DIRECTORY}/antigravity" ]]; then
    echo "Extraction failed: antigravity binary not found"
    exit 1
fi

chmod +x "${INSTALL_DIRECTORY}/antigravity"

rm -f "${HOME}/.local/bin/antigravity"
ln -s "${INSTALL_DIRECTORY}/antigravity" "${HOME}/.local/bin/antigravity"

echo "Antigravity CLI installed successfully!"
"${HOME}/.local/bin/antigravity" --version
