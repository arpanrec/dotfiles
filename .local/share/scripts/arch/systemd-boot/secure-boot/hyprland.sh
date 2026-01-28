#!/usr/bin/env bash
set -euo pipefail

if pacman -Qi hyprlauncher &>/dev/null; then
    pacman -Rsc hyprlauncher --noconfirm # with Replace rofi
fi

# 'xdg-desktop-portal-kde' 'xdg-desktop-portal-gtk' kwidgetsaddons kitemviews 'breeze' 'aurorae' 'nodejs-emojione' kconfig
# 'kdbusaddons' 'kcoreaddons' 'kcrash' 'kguiaddons' 'ki18n' kservice 'kwallet-pam' 'sddm-kcm'
# 'polkit' 'polkit-kde-agent' 'avahi' kwindowsystem 'perl-lwp-protocol-https' 'qt6-virtualkeyboard'
PACMAN_PACKAGES+=('hyprland' 'waybar' 'kwalletmanager' 'kwallet' 'sddm' 'xorg-xwayland'
    'xorg-xeyes' 'xorg-xlsclients' 'xdg-desktop-portal-hyprland' 'qt5-wayland' 'qt6-wayland' 'hyprpaper'
    'dolphin' 'dunst' 'copyq' 'kitty' 'kate' 'konsole' 'qt6-declarative' 'qtkeychain-qt6' 'kvantum'
    'wl-clipboard' 'cliphist' 'hyprshot' 'mpd' 'vice' 'ncmpcpp' 'wildmidi'
    'gwenview' 'xdg-user-dirs' 'rofi' 'hyprpolkitagent' 'kdegraphics-thumbnailers' 'qt6-imageformats' 'kimageformats'
    'dolphin-plugins' 'ark' 'archlinux-xdg-menu' 'wayland-protocols'
    'hypridle' 'hyprlock' 'hyprland-qt-support')

# 'baloo' 'audiocd-kio' 'kompare' 'kio-gdrive' 'kio-admin' 'libappimage' 'kdesdk-thumbnailers' 'icoutils' 'packagekit-qt6' 'qt6ct'
# 'appmenu-gtk-module' 'webkit2gtk' 'materia-gtk-theme' 'adapta-gtk-theme' 'adw-gtk-theme'
# 'networkmanager-openvpn' 'libnma'  'networkmanager-openconnect'
PACMAN_PACKAGES+=('network-manager-applet')

# 'ttf-jetbrains-mono-nerd' 'ttf-fantasque-sans-mono' 'otf-font-awesome' 'adobe-source-sans-fonts'
PACMAN_PACKAGES+=('noto-fonts' 'noto-fonts-cjk' 'noto-fonts-emoji' 'noto-fonts-extra')

#'gtkmm3' 'jsoncpp' 'libsigc++' 'fmt' 'chrono-date' 'spdlog' 'gtk3' 'gobject-introspection'
#    'libgirepository' 'libpulse' 'libnl' 'libappindicator-gtk3' 'libdbusmenu-gtk3' 'libmpdclient' 'sndio' 'libevdev'
#    'libxkbcommon' 'upower' 'meson' 'scdoc' 'glib2-devel'

PACMAN_PACKAGES+=('libavtp' 'lib32-alsa-plugins' 'lib32-libavtp' 'lib32-libsamplerate' 'lib32-speexdsp' 'lib32-glib2')

PACMAN_PACKAGES+=('wireplumber' 'pipewire' 'pipewire-pulse' 'pipewire-alsa' 'sof-firmware' 'pipewire-jack'
    'lib32-pipewire' 'lib32-pipewire-jack' 'alsa-firmware' 'alsa-utils' 'gst-plugin-pipewire' 'pipewire-v4l2'
    'pipewire-zeroconf' 'lib32-pipewire-v4l2' 'pavucontrol' 'qt6-multimedia-ffmpeg')

PACMAN_PACKAGES+=('cups' 'cups-pdf' 'hplip' 'usbutils' 'cups-pk-helper' 'system-config-printer' 'print-manager')

PACMAN_PACKAGES+=('ffmpeg' 'yt-dlp' 'ffmpegthumbs' 'ffmpegthumbnailer' 'gst-libav' 'gstreamer'
    'gst-plugins-ugly' 'taglib' 'gst-plugins-base' 'a52dec' 'faac' 'faad2' 'flac' 'jasper' 'lame' 'libdca' 'libdv'
    'libmad' 'libmpeg2' 'libtheora' 'libvorbis' 'libxv' 'wavpack' 'x264' 'xvidcore' 'vlc' 'vlc-plugin-ffmpeg'
    'vlc-plugins-all' 'haruna' 'libheif' 'gst-plugins-bad' 'gst-plugins-good' 'mpv' 'mpv-mpris')

PACMAN_PACKAGES+=('blueman')

PACMAN_PACKAGES+=('wireguard-tools')
PACMAN_PACKAGES+=('veracrypt' 'keepassxc')
# 'yubikey-manager-qt' Is broken
PACMAN_PACKAGES+=('yubikey-personalization' 'yubikey-personalization-gui' 'yubikey-manager')
PACMAN_PACKAGES+=('gimp' 'qbittorrent' 'signal-desktop' 'nextcloud-client')

#  'duplicity'
PACMAN_PACKAGES+=('timeshift' 'vorta' 'deja-dup' 'borgmatic')

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

# redhat-fonts is needed for SilentSDDM
AUR_PACKAGES=('google-chrome' 'brave-bin' 'sublime-text-4' 'onlyoffice-bin' 'nordvpn-bin' 'yubico-authenticator-bin'
    'redhat-fonts')

sudo -H -u arch-yay-installer-user bash -c "cd ~ && \
        yay -S --answerclean None --answerdiff None --noconfirm --needed $(printf " %s" "${AUR_PACKAGES[@]}")"

if [[ ! -d /usr/share/sddm/themes/SilentSDDM ]]; then
    echo "Clonnig https://github.com/uiriansan/SilentSDDM.git to /usr/share/sddm/themes/SilentSDDM"
    mkdir -p /usr/share/sddm/themes
    git clone --depth 1 https://github.com/uiriansan/SilentSDDM.git /usr/share/sddm/themes/SilentSDDM
else
    echo "/usr/share/sddm/themes/SilentSDDM exists, Updating from https://github.com/uiriansan/SilentSDDM.git"
    (
        cd /usr/share/sddm/themes/SilentSDDM || exit 1
        git reset --hard HEAD
        git pull
    )
fi
sed -i 's|^ConfigFile=configs/default\.conf$|ConfigFile=configs/rei.conf|' \
    /usr/share/sddm/themes/SilentSDDM/metadata.desktop
sudo cp -r /usr/share/sddm/themes/SilentSDDM/fonts/* /usr/share/fonts/

tee "/etc/sddm.conf" <<EOF
[Theme]
Current=SilentSDDM
EOF

systemctl enable sddm cups avahi-daemon.service
systemctl set-default graphical.target

while orphaned=$(pacman -Qtdq); do
    [[ -z "${orphaned}" ]] && break
    pacman -R --noconfirm "${orphaned}"
done

echo "Its a good idea to run 'pacman -R \$(pacman -Qtdq)' or 'yay -R \$(yay -Qtdq)'."

echo "Completed"
