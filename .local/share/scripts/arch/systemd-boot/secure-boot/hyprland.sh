#!/usr/bin/env bash
set -euo pipefail

if pacman -Qi hyprlauncher &>/dev/null; then
    pacman -Rsc hyprlauncher --noconfirm # with Replace rofi
fi

# 'mpd' 'vice' 'ncmpcpp' 'wildmidi'
# 'cliphist'

PACMAN_PACKAGES+=('hyprland' 'hypridle' 'hyprlock' 'hyprpaper' 'waybar' 'hyprland-qt-support' 'hyprpolkitagent'
    'rofi' 'dunst' 'kitty' 'hyprshot' 'xdg-desktop-portal-hyprland' 'xdg-user-dirs'
    'wayland-protocols' 'xorg-xwayland' 'xorg-xeyes' 'xorg-xlsclients'
    'wl-clipboard' 'copyq'
    'qt5-wayland' 'qt6-wayland'
    'qt6ct' # Replacement for https://wiki.hypr.land/Hypr-Ecosystem/hyprqt6engine/
    'kwalletmanager' 'kwallet' 'sddm' 'kleopatra'
    'dolphin' 'dolphin-plugins' 'kate' 'konsole' 'qtkeychain-qt6' 'kvantum' 'gwenview'
    'ark') # ark is needed for dolphin archive/unarchive plugin.

# 'xdg-desktop-portal-kde'

# 'baloo' 'audiocd-kio' 'kompare' 'kio-gdrive' 'kio-admin' 'libappimage' 'kdesdk-thumbnailers' 'icoutils'
# 'packagekit-qt6' 'qt6ct'
# 'appmenu-gtk-module' 'webkit2gtk' 'materia-gtk-theme' 'adapta-gtk-theme' 'adw-gtk-theme'
# 'networkmanager-openvpn' 'libnma'  'networkmanager-openconnect'
PACMAN_PACKAGES+=('network-manager-applet')

# 'ttf-jetbrains-mono-nerd' 'ttf-fantasque-sans-mono' 'otf-font-awesome' 'adobe-source-sans-fonts'
PACMAN_PACKAGES+=('noto-fonts' 'noto-fonts-cjk' 'noto-fonts-emoji' 'noto-fonts-extra')

# 'gtkmm3' 'jsoncpp' 'libsigc++' 'fmt' 'chrono-date' 'spdlog' 'gtk3' 'gobject-introspection' 'libgirepository'
# 'libpulse' 'libnl' 'libappindicator-gtk3' 'libdbusmenu-gtk3' 'libmpdclient' 'sndio' 'libevdev' 'libxkbcommon' 'upower'
# 'meson' 'scdoc' 'glib2-devel'

# 'libavtp' 'lib32-alsa-plugins' 'lib32-libavtp' 'lib32-libsamplerate' 'lib32-speexdsp' 'lib32-glib2'
# 'gst-plugins-ugly' 'gst-plugins-base' 'a52dec' 'faac' 'faad2' 'flac' 'jasper' 'lame' 'libdca' 'libdv'
# 'gst-libav' 'gstreamer' 'libmad' 'libmpeg2' 'libtheora' 'libvorbis' 'libxv' 'wavpack' 'x264' 'xvidcore'
# 'gst-plugins-good' 'libheif' 'gst-plugins-bad' 'mpv' 'mpv-mpris' 'gst-plugin-pipewire'

PACMAN_PACKAGES+=('wireplumber' 'pipewire' 'pipewire-pulse' 'pipewire-alsa' 'sof-firmware' 'pipewire-jack'
    'lib32-pipewire' 'lib32-pipewire-jack' 'alsa-firmware' 'alsa-utils' 'pipewire-v4l2' 'pipewire-zeroconf'
    'lib32-pipewire-v4l2' 'pavucontrol' 'qt6-multimedia-ffmpeg' 'qt6-imageformats' 'kimageformats'
    'ffmpeg' 'yt-dlp' 'ffmpegthumbs' 'ffmpegthumbnailer' 'taglib' 'haruna' 'kdegraphics-thumbnailers')

PACMAN_PACKAGES+=('cups' 'cups-pdf' 'hplip' 'cups-pk-helper' 'system-config-printer' 'print-manager')

PACMAN_PACKAGES+=('blueman')

PACMAN_PACKAGES+=('wireguard-tools')
PACMAN_PACKAGES+=('veracrypt' 'keepassxc')
# 'yubikey-manager-qt' Is broken
PACMAN_PACKAGES+=('yubikey-personalization' 'yubikey-personalization-gui' 'yubikey-manager')
PACMAN_PACKAGES+=('gimp' 'qbittorrent' 'signal-desktop' 'nextcloud-client')

#  'duplicity' 'vorta' 'borgmatic'
PACMAN_PACKAGES+=('timeshift' 'deja-dup')

if lspci | grep -E "(VGA|3D)" | grep -E "(NVIDIA|GeForce)"; then
    PACMAN_PACKAGES+=('nvidia-settings' 'nvidia-prime' 'lib32-nvidia-utils' 'libvdpau-va-gl')
fi

if lspci | grep -E "(VGA|3D)" | grep -E "(Radeon|Advanced Micro Devices)"; then
    PACMAN_PACKAGES+=('xf86-video-amdgpu' 'xf86-video-ati' 'vulkan-radeon' 'lib32-vulkan-radeon'
        'lib32-vulkan-mesa-layers')
fi

if lspci | grep -E "(VGA|3D)" | grep -E "(Integrated Graphics Controller|Intel Corporation)"; then
    PACMAN_PACKAGES+=('libvdpau-va-gl' 'lib32-vulkan-intel' 'vulkan-intel' 'libva-intel-driver'
        'libva-utils' 'mesa' 'intel-media-driver')
fi

pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

systemctl enable sddm cups avahi-daemon.service
systemctl set-default graphical.target

echo "-------------------------------------------------------"
echo "             Install Yay and AUR Packages              "
echo "-------------------------------------------------------"

AUR_INSTALL_USER="arch-yay-installer-user"

echo "Adding user ${AUR_INSTALL_USER}"

id -u "${AUR_INSTALL_USER}" &>/dev/null ||
    useradd -s /bin/bash --system -m -d /home/"${AUR_INSTALL_USER}" "${AUR_INSTALL_USER}"

echo "${AUR_INSTALL_USER} ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/10-"${AUR_INSTALL_USER}"

# redhat-fonts is needed for sddm-silent-theme, which comes from AUR, So needed to be installed first and explicitly.
AUR_BASIC_PACKAGES=('yay' 'nordvpn-bin' 'google-chrome' 'brave-bin' 'onlyoffice-bin' 'yubico-authenticator-bin'
    'redhat-fonts' 'sddm-silent-theme')

for AUR_BASIC_PACKAGE in "${AUR_BASIC_PACKAGES[@]}"; do
    if ! pacman -Qi "${AUR_BASIC_PACKAGE}" &>/dev/null; then
        su - "${AUR_INSTALL_USER}" -c "
            set -eou pipefail
            rm -rf \"\${HOME}/${AUR_BASIC_PACKAGE}\"
            git clone \"https://aur.archlinux.org/${AUR_BASIC_PACKAGE}.git\" \"\${HOME}/${AUR_BASIC_PACKAGE}\" --depth=1
            cd \"\${HOME}/${AUR_BASIC_PACKAGE}\" || exit 1
            makepkg -si --noconfirm
        "
    fi
done

while orphaned=$(pacman -Qtdq); do
    [[ -z "${orphaned}" ]] && break
    pacman -R --noconfirm "${orphaned}"
done

systemctl enable nordvpnd

sed -i 's|^ConfigFile=configs/default\.conf$|ConfigFile=configs/rei.conf|' \
    /usr/share/sddm/themes/silent/metadata.desktop

tee "/etc/sddm.conf" <<EOF
[Theme]
Current=silent
EOF

echo "Its a good idea to run 'pacman -R \$(pacman -Qtdq)' or 'yay -R \$(yay -Qtdq)'."

echo "Completed"
