#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -m)" != "x86_64" ]]; then
    echo "Only x86_64 architecture is supported."
    exit 1
fi

LATEST_VERSION="$(curl -s \
    "https://api.github.com/repos/telegramdesktop/tdesktop/releases/latest" |
    jq -r ".tag_name")"

if [[ -z "${LATEST_VERSION}" ]]; then
    echo "Failed to get latest version."
    exit 1
else
    echo "Installing Telegram Desktop version ${LATEST_VERSION}"
fi

rm -rf "${HOME}/.local/share/Telegram"

TMP_DOWNLOAD_DIRECTORY="${HOME}/.tmp/from_dotfiles_bin"

mkdir -p "${TMP_DOWNLOAD_DIRECTORY}" "${HOME}/.local/share/applications" "${HOME}/.local/share/Telegram"
echo "Downloading Telegram Desktop version ${LATEST_VERSION} for $(uname -m) architecture to ${TMP_DOWNLOAD_DIRECTORY}"

if [[ ! -f "${TMP_DOWNLOAD_DIRECTORY}/tsetup.${LATEST_VERSION:1}.tar.xz" ]]; then
    curl -fL "https://github.com/telegramdesktop/tdesktop/releases/download/${LATEST_VERSION}/tsetup.${LATEST_VERSION:1}.tar.xz" \
        -o "${TMP_DOWNLOAD_DIRECTORY}/tsetup.${LATEST_VERSION:1}.tar.xz"
else
    echo "Tarball File already exists"
fi

tar -xf "${TMP_DOWNLOAD_DIRECTORY}/tsetup.${LATEST_VERSION:1}.tar.xz" \
    -C "${HOME}/.local/share/Telegram" --strip-components=1

find "${HOME}/.local/share/applications" -type f -name "*telegram*" -exec rm -f {} \;

#tee "${HOME}/.local/share/applications/telegram-desktop.desktop" <<EOF
#[Desktop Entry]
#Version=1.0
#Name=Telegram
#Comment=New era of messaging
#TryExec=${HOME}/.local/share/Telegram/Telegram
#Exec=${HOME}/.local/share/Telegram/Telegram --enable-features=UseOzonePlatform --ozone-platform=wayland --password-store=kwallet6 -- %U
#Icon=org.telegram.desktop
#Terminal=false
#StartupWMClass=TelegramDesktop
#Type=Application
#X-KDE-DBus-ServiceName=org.telegram.desktop
#X-GNOME-SingleWindow=true
#X-GNOME-UsesNotifications=true
#SingleMainWindow=true
##DBusActivatable=true
#Actions=quit;
#Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
#MimeType=x-scheme-handler/tg;x-scheme-handler/tonsite;
#Categories=Chat;Network;InstantMessaging;Qt;
#
#[Desktop Action quit]
#Exec=${HOME}/.local/share/Telegram/Telegram -quit
#Name=Quit Telegram
#Icon=application-exit
#EOF
#
#chmod 755 "${HOME}/.local/share/applications/telegram-desktop.desktop"

echo "Starting telegram-desktop for automatic desktop entry creation"

"${HOME}/.local/share/Telegram/Telegram" &&

echo "Telegram Desktop installed successfully!"
