#!/usr/bin/env bash
set -euo pipefail

PACMAN_PACKAGES+=('hyprland' 'kwalletmanager' 'kwallet-pam' 'sddm' 'polkit' 'hyprpolkitagent' 'xorg-xwayland'
    'xorg-xeyes' 'xorg-xlsclients' 'xdg-desktop-portal-hyprland' 'qt5-wayland' 'qt6-wayland' 'hyprpaper'
    'hyprlauncher' 'dolphin' 'dunst' 'copyq' 'kitty' 'kate' 'konsole' 'qt6-declarative' 'qtkeychain-qt6' 'kvantum'
    'wl-clipboard' 'cliphist' 'hyprshot' 'mpd' 'vice' 'ncmpcpp' 'wildmidi' 'xdg-desktop-portal-gtk' 'gwenview'
    'kdegraphics-thumbnailers' 'qt6-imageformats' 'kimageformats')
PACMAN_PACKAGES+=('networkmanager-openvpn' 'libnma' 'network-manager-applet' 'networkmanager-openconnect')
PACMAN_PACKAGES+=('noto-fonts' 'noto-fonts-cjk' 'noto-fonts-emoji' 'noto-fonts-extra' 'waybar' 'otf-font-awesome'
    'adobe-source-sans-fonts' 'ttf-jetbrains-mono-nerd' 'ttf-fantasque-sans-mono' 'rofi-emoji')

PACMAN_PACKAGES+=('gtkmm3' 'jsoncpp' 'libsigc++' 'fmt' 'chrono-date' 'spdlog' 'gtk3' 'gobject-introspection'
    'libgirepository' 'libpulse' 'libnl' 'libappindicator-gtk3' 'libdbusmenu-gtk3' 'libmpdclient' 'sndio' 'libevdev'
    'libxkbcommon' 'upower' 'meson' 'cmake' 'scdoc' 'wayland-protocols' 'glib2-devel')

PACMAN_PACKAGES+=('libavtp' 'lib32-alsa-plugins' 'lib32-libavtp' 'lib32-libsamplerate' 'lib32-speexdsp' 'lib32-glib2')

PACMAN_PACKAGES+=('wireplumber' 'pipewire' 'pipewire-pulse' 'pipewire-alsa' 'sof-firmware' 'pipewire-jack'
    'lib32-pipewire' 'lib32-pipewire-jack' 'alsa-firmware' 'alsa-utils' 'gst-plugin-pipewire' 'pipewire-v4l2'
    'pipewire-zeroconf' 'lib32-pipewire-v4l2' 'pavucontrol' 'qt6-multimedia-ffmpeg')

PACMAN_PACKAGES+=('cups' 'cups-pdf' 'hplip' 'usbutils' 'cups-pk-helper' 'system-config-printer' 'print-manager')

PACMAN_PACKAGES+=('ffmpeg' 'yt-dlp' 'ffmpegthumbs' 'ffmpegthumbnailer' 'gst-libav' 'gstreamer'
    'gst-plugins-ugly' 'taglib' 'gst-plugins-base' 'a52dec' 'faac' 'faad2' 'flac' 'jasper' 'lame' 'libdca' 'libdv'
    'libmad' 'libmpeg2' 'libtheora' 'libvorbis' 'libxv' 'wavpack' 'x264' 'xvidcore' 'vlc' 'vlc-plugin-ffmpeg'
    'vlc-plugins-all' 'haruna' 'libheif' 'gst-plugins-bad' 'gst-plugins-good')

PACMAN_BASIC_PACKAGES+=('blueman')

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

systemctl enable sddm cups
systemctl set-default graphical.target

AUR_PACKAGES=('google-chrome' 'brave-bin' 'sublime-text-4' 'onlyoffice-bin' 'nordvpn-bin' 'yubico-authenticator-bin')

sudo -H -u arch-yay-installer-user bash -c "cd ~ && \
        yay -S --answerclean None --answerdiff None --noconfirm --needed $(printf " %s" "${AUR_PACKAGES[@]}")"

while orphaned=$(pacman -Qtdq); do
    [[ -z "${orphaned}" ]] && break
    pacman -R --noconfirm "${orphaned}"
done

echo "Its a good idea to run 'pacman -R \$(pacman -Qtdq)' or 'yay -R \$(yay -Qtdq)'."

echo "Completed"
