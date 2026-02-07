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

LATEST_VERSION="$(curl -s \
    "https://update.code.visualstudio.com/api/releases/stable" |
    jq -r ".[0]")"

if [[ -z "${LATEST_VERSION}" ]]; then
    echo "Failed to get latest version."
    exit 1
fi

echo "Installing Visual Studio Code version ${LATEST_VERSION}"

TMP_DOWNLOAD_DIRECTORY="${HOME}/.tmp/from_dotfiles_bin"

rm -rf "${HOME}/.local/share/vscode"
mkdir -p "${TMP_DOWNLOAD_DIRECTORY}" "${HOME}/.local/share/vscode" "${HOME}/.local/share/applications/" \
    "${HOME}/.local/bin"

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

DOWNLOAD_URL="https://update.code.visualstudio.com/${LATEST_VERSION}/linux-${DOWNLOAD_ARCH_KEY}/stable"

echo "Downloading Visual Studio Code version ${LATEST_VERSION} for ${CURRENT_ARCH} architecture to ${TMP_DOWNLOAD_DIRECTORY}"

if [[ ! -f "${TMP_DOWNLOAD_DIRECTORY}/vscode-${LATEST_VERSION}-linux-${DOWNLOAD_ARCH_KEY}.tar.gz" ]]; then
    curl -fL "${DOWNLOAD_URL}" -o "${TMP_DOWNLOAD_DIRECTORY}/vscode-${LATEST_VERSION}-linux-${DOWNLOAD_ARCH_KEY}.tar.gz"
else
    echo "Tarball File already exists"
fi

tar -xzvf "${TMP_DOWNLOAD_DIRECTORY}/vscode-${LATEST_VERSION}-linux-${DOWNLOAD_ARCH_KEY}.tar.gz" \
    -C "${HOME}/.local/share/vscode" \
    --strip-components=1

tee "${HOME}/.local/share/applications/code.desktop" <<EOF
[Desktop Entry]
Version=1.0
Name=Visual Studio Code
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=${HOME}/.local/share/vscode/code %F
Icon=${HOME}/.local/share/vscode/resources/app/resources/linux/code.png
Type=Application
StartupNotify=false
StartupWMClass=Code
Categories=TextEditor;Development;IDE;
MimeType=application/x-code-workspace;
Actions=new-empty-window;
Keywords=vscode;

[Desktop Action new-empty-window]
Name=New Empty Window
Name[cs]=Nové prázdné okno
Name[de]=Neues leeres Fenster
Name[es]=Nueva ventana vacía
Name[fr]=Nouvelle fenêtre vide
Name[it]=Nuova finestra vuota
Name[ja]=新しい空のウィンドウ
Name[ko]=새 빈 창
Name[ru]=Новое пустое окно
Name[zh_CN]=新建空窗口
Name[zh_TW]=開新空視窗
Exec=${HOME}/.local/share/vscode/code --new-window %F
Icon=${HOME}/.local/share/vscode/resources/app/resources/linux/code.png
EOF

tee "${HOME}/.local/share/applications/code-url-handler.desktop" <<EOF
[Desktop Entry]
Name=Visual Studio Code - URL Handler
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=${HOME}/.local/share/vscode/code --enable-features=UseOzonePlatform --ozone-platform=wayland --open-url %U
Icon=${HOME}/.local/share/vscode/resources/app/resources/linux/code.png
Type=Application
NoDisplay=true
StartupNotify=true
Categories=Utility;TextEditor;Development;IDE;
MimeType=x-scheme-handler/vscode;
Keywords=vscode;
EOF

rm -f "${HOME}/.local/bin/code"
ln -s "${HOME}/.local/share/vscode/bin/code" "${HOME}/.local/bin/code"

echo "Visual Studio Code installed successfully! :"
"${HOME}/.local/bin/code" --version

echo "Setting kde wallet6"
mkdir -p "${HOME}/.vscode"
tee "${HOME}/.vscode/argv.json" <<EOF
{
    "password-store": "kwallet5",
    "enable-crash-reporter": false
}
EOF

# VS Code extensions to be installed
CODE_EXTENSIONS=(
    "angular.ng-template"
    "bradlc.vscode-tailwindcss"
    "davidanson.vscode-markdownlint"
    "dbaeumer.vscode-eslint"
    "esbenp.prettier-vscode"
    "exiasr.hadolint"
    "foxundermoon.shell-format"
    "github.codespaces"
    "github.github-vscode-theme"
    "github.remotehub"
    "github.vscode-codeql"
    "github.vscode-github-actions"
    "github.vscode-pull-request-github"
    "golang.go"
    "hashicorp.terraform"
    "ms-azuretools.vscode-containers"
    "ms-azuretools.vscode-docker"
    "ms-python.black-formatter"
    "ms-python.debugpy"
    "ms-python.isort"
    "ms-python.mypy-type-checker"
    "ms-python.pylint"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-toolsai.jupyter"
    "ms-toolsai.jupyter-keymap"
    "ms-toolsai.jupyter-renderers"
    "ms-toolsai.vscode-jupyter-cell-tags"
    "ms-toolsai.vscode-jupyter-slideshow"
    "ms-vscode-remote.remote-containers"
    "ms-vscode-remote.remote-ssh"
    "ms-vscode-remote.remote-ssh-edit"
    "ms-vscode-remote.remote-wsl"
    "ms-vscode-remote.vscode-remote-extensionpack"
    "ms-vscode.remote-explorer"
    "ms-vscode.remote-repositories"
    "ms-vscode.remote-server"
    "ms-vscode.vscode-speech"
    "msjsdiag.vscode-react-native"
    "pkief.material-icon-theme"
    "redhat.ansible"
    "redhat.fabric8-analytics"
    "redhat.vscode-xml"
    "redhat.vscode-yaml"
    "rust-lang.rust-analyzer"
    "streetsidesoftware.code-spell-checker"
    "timonwong.shellcheck"
    "wholroyd.jinja"
    "yzhang.markdown-all-in-one"
    "pomdtr.excalidraw-editor"
)

echo "Installing VS Code extensions..."

# Get currently installed extensions (lowercased for comparison)
INSTALLED_EXTENSIONS="$("${HOME}/.local/bin/code" --list-extensions | tr '[:upper:]' '[:lower:]')"

install_extension() {
    local ext="$1"
    local retries=5
    local delay=3
    local attempt=1

    while ((attempt <= retries)); do
        if "${HOME}/.local/bin/code" --install-extension "$ext" >/dev/null 2>&1; then
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
