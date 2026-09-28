#!/usr/bin/env bash
set -euo pipefail

required_cmds=(
    curl
    jq
    tar
)

for cmd in "${required_cmds[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Required command '$cmd' is not installed or not in PATH"
        exit 1
    fi
done

CURRENT_ARCH="$(uname -m)"

case "${CURRENT_ARCH}" in
x86_64)
    DOWNLOAD_ARCH_KEY="x64"
    ;;
aarch64 | arm64)
    DOWNLOAD_ARCH_KEY="arm"
    ;;
*)
    echo "Unsupported architecture: ${CURRENT_ARCH}"
    exit 1
    ;;
esac

echo "Fetching latest Antigravity IDE release info..."
DOWNLOAD_URL="$(curl -sSL --compressed --connect-timeout 10 --max-time 30 "https://antigravity.google/download" |
    grep -oE "https://[^\"' ]+/linux-${DOWNLOAD_ARCH_KEY}/Antigravity%20IDE\.tar\.gz" | head -n 1)"

if [[ -z "${DOWNLOAD_URL}" ]]; then
    echo "Failed to resolve download URL for architecture: ${CURRENT_ARCH}"
    exit 1
fi

ANTIGRAVITY_IDE_LATEST_VERSION="$(echo "${DOWNLOAD_URL}" | grep -oE "stable/[^/]+" | cut -d/ -f2)"

echo "Installing Antigravity IDE version ${ANTIGRAVITY_IDE_LATEST_VERSION}"

TMP_DOWNLOAD_DIRECTORY="${HOME}/.cache/dotfiles-tmp-download-dir"
INSTALL_DIRECTORY="${HOME}/.local/share/antigravity-ide"
TARBALL_FILE="${TMP_DOWNLOAD_DIRECTORY}/antigravity-ide-${ANTIGRAVITY_IDE_LATEST_VERSION}-linux-${DOWNLOAD_ARCH_KEY}.tar.gz"

rm -rf "${INSTALL_DIRECTORY}"
mkdir -p "${TMP_DOWNLOAD_DIRECTORY}" "${INSTALL_DIRECTORY}" "${HOME}/.local/share/applications" "${HOME}/.local/bin"

echo "Downloading Antigravity IDE version ${ANTIGRAVITY_IDE_LATEST_VERSION} for ${CURRENT_ARCH} architecture to ${TMP_DOWNLOAD_DIRECTORY}"

if [[ ! -f "${TARBALL_FILE}" ]]; then
    curl -fL --connect-timeout 10 --max-time 600 "${DOWNLOAD_URL}" -o "${TARBALL_FILE}"
else
    echo "Tarball file already exists"
fi

tar -xzvf "${TARBALL_FILE}" \
    -C "${INSTALL_DIRECTORY}" \
    --strip-components=1

tee "${HOME}/.local/share/applications/antigravity-ide.desktop" <<EOF
[Desktop Entry]
Version=1.0
Name=Antigravity IDE
Comment=Experience liftoff
GenericName=Text Editor
Exec=${INSTALL_DIRECTORY}/bin/antigravity-ide %F
Icon=${INSTALL_DIRECTORY}/resources/app/resources/linux/code.png
Type=Application
StartupNotify=false
StartupWMClass=antigravity-ide
Categories=TextEditor;Development;IDE;
MimeType=application/x-antigravity-ide-workspace;
Actions=new-empty-window;
Keywords=vscode;antigravity;ide;

[Desktop Action new-empty-window]
Name=New Empty Window
Exec=${INSTALL_DIRECTORY}/bin/antigravity-ide --new-window %F
Icon=${INSTALL_DIRECTORY}/resources/app/resources/linux/code.png
EOF

tee "${HOME}/.local/share/applications/antigravity-ide-url-handler.desktop" <<EOF
[Desktop Entry]
Name=Antigravity IDE - URL Handler
Comment=Experience liftoff
GenericName=Text Editor
Exec=${INSTALL_DIRECTORY}/bin/antigravity-ide --open-url %U
Icon=${INSTALL_DIRECTORY}/resources/app/resources/linux/code.png
Type=Application
NoDisplay=true
StartupNotify=true
Categories=Utility;TextEditor;Development;IDE;
MimeType=x-scheme-handler/antigravity-ide;
Keywords=vscode;antigravity;ide;
EOF

rm -f "${HOME}/.local/bin/antigravity-ide"
ln -s "${INSTALL_DIRECTORY}/bin/antigravity-ide" "${HOME}/.local/bin/antigravity-ide"

mkdir -p "${HOME}/.antigravity-ide"
tee "${HOME}/.antigravity-ide/argv.json" <<EOF
{
    "password-store": "kwallet5",
    "enable-crash-reporter": false
}
EOF

echo "Antigravity IDE installed successfully!"
"${HOME}/.local/bin/antigravity-ide" --version

# VS Code extensions to be installed
CODE_EXTENSIONS=(
    "angular.ng-template"
    "bradlc.vscode-tailwindcss"
    "tamasfe.even-better-toml"
    "docker.docker"
    "dbaeumer.vscode-eslint"
    "esbenp.prettier-vscode"
    "exiasr.hadolint"
    "foxundermoon.shell-format"
    "github.github-vscode-theme"
    "golang.go"
    "hashicorp.hcl"
    "hashicorp.terraform"
    "ms-azuretools.vscode-containers"
    "ms-azuretools.vscode-docker"
    "ms-python.black-formatter"
    "ms-python.debugpy"
    "ms-python.isort"
    "ms-python.mypy-type-checker"
    "ms-python.pylint"
    "ms-python.python"
    "ms-toolsai.jupyter"
    "ms-toolsai.jupyter-keymap"
    "ms-toolsai.jupyter-renderers"
    "ms-toolsai.vscode-jupyter-cell-tags"
    "ms-toolsai.vscode-jupyter-slideshow"
    "msjsdiag.vscode-react-native"
    "pkief.material-icon-theme"
    "redhat.ansible"
    "redhat.fabric8-analytics"
    "redhat.vscode-xml"
    "redhat.vscode-yaml"
    "rust-lang.rust-analyzer"
    "streetsidesoftware.code-spell-checker"
    "wholroyd.jinja"
    "sumneko.lua"
    "pomdtr.excalidraw-editor"
)

echo "Installing Antigravity IDE extensions..."

# Get currently installed extensions (lowercased for comparison)
INSTALLED_EXTENSIONS="$("${HOME}/.local/bin/antigravity-ide" --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')"

install_extension() {
    local ext="$1"
    local retries=5
    local delay=3
    local attempt=1

    while ((attempt <= retries)); do
        if "${HOME}/.local/bin/antigravity-ide" --install-extension "$ext" >/dev/null 2>&1; then
            echo "✔ Installed: $ext"
            return 0
        fi

        echo "⚠ Failed to install $ext (attempt $attempt/$retries), retrying in ${delay}s..."
        sleep "$delay"
        ((attempt++))
    done

    echo "✖ Failed to install extension after retries: $ext"
    return 1
}

for ext in "${CODE_EXTENSIONS[@]}"; do
    ext_lc="$(printf '%s\n' "$ext" | tr '[:upper:]' '[:lower:]')"

    if grep -qx "$ext_lc" <<<"$INSTALLED_EXTENSIONS"; then
        echo "✔ Already installed: $ext"
        continue
    fi

    install_extension "$ext"
done
