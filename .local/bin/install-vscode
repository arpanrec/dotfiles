#!/usr/bin/env bash
set -euo pipefail

LATEST_VERSION="$(curl -s \
    "https://update.code.visualstudio.com/api/releases/stable" |
    jq -r ".[0]")"

if [[ -z "${LATEST_VERSION}" ]]; then
    echo "Failed to get latest version."
    exit 1
fi

echo "Installing Visual Studio Code version ${LATEST_VERSION}"

DOWNLOAD_DIRECTORY="${HOME}/Downloads"

rm -rf "${HOME}/.local/share/vscode"
mkdir -p "${DOWNLOAD_DIRECTORY}" "${HOME}/.local/share/vscode" "${HOME}/.local/share/applications/" \
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

echo "Downloading Visual Studio Code version ${LATEST_VERSION} for ${CURRENT_ARCH} architecture to ${DOWNLOAD_DIRECTORY}"

if [[ ! -f "${DOWNLOAD_DIRECTORY}/vscode-${LATEST_VERSION}-linux-${DOWNLOAD_ARCH_KEY}.tar.gz" ]]; then
    curl -fL "${DOWNLOAD_URL}" -o "${DOWNLOAD_DIRECTORY}/vscode-${LATEST_VERSION}-linux-${DOWNLOAD_ARCH_KEY}.tar.gz"
else
    echo "Tarball File already exists"
fi

tar -xzvf "${DOWNLOAD_DIRECTORY}/vscode-${LATEST_VERSION}-linux-${DOWNLOAD_ARCH_KEY}.tar.gz" \
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
Exec=${HOME}/.local/share/vscode/code --open-url %U
Icon=${HOME}/.local/share/vscode/resources/app/resources/linux/code.png
Type=Application
NoDisplay=true
StartupNotify=true
Categories=Utility;TextEditor;Development;IDE;
MimeType=x-scheme-handler/vscode;
Keywords=vscode;
EOF

rm "${HOME}/.local/bin/code"
ln -s "${HOME}/.local/share/vscode/bin/code" "${HOME}/.local/bin/code"

echo "Visual Studio Code installed successfully! :"
"${HOME}/.local/bin/code" --version
