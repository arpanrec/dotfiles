#!/usr/bin/env bash
set -euo pipefail

if pacman -Qi hyprlauncher &>/dev/null; then
    pacman -Rsc hyprlauncher --noconfirm # with Replace rofi
fi

if pacman -Qi hyprpolkitagent &>/dev/null; then
    pacman -Rsc hyprpolkitagent --noconfirm # with Replace polkit-kde-agent
fi

# 'mpd' 'vice' 'ncmpcpp' 'wildmidi'

PACMAN_PACKAGES+=(
    'hyprland' 'hypridle' 'hyprlock' 'hyprpaper' 'hyprshot' 'hyprland-qt-support' 'hyprpicker'
    'rofi' 'dunst' 'kitty' 'waybar'
    'xdg-desktop-portal-hyprland' 'xdg-user-dirs'
    'network-manager-applet' # For wifi and ethernet from ngw-shell
    'wayland-protocols' 'xorg-xwayland' 'xorg-xeyes' 'xorg-xlsclients'
    'kanshi'       # Dynamic monitor switching tool
    'nwg-displays' # GUI Dynamic monitor switching tool, testings with hyprland
    'brightnessctl'
    'cliphist' 'copyq' 'wl-clip-persist'
)

PACMAN_PACKAGES+=('qt5-wayland' 'qt6-wayland'
    'qt6ct' 'qt5ct' # Replacement for https://wiki.hypr.land/Hypr-Ecosystem/hyprqt6engine/
    'xdg-desktop-portal-kde'
    'kwalletmanager' 'kwallet' 'kwallet-pam' 'sddm' 'sddm-kcm' 'polkit-kde-agent'
    'kleopatra'
    'kvantum'
    'kde-gtk-config' # for gtk apps xsettingsd cli
    'kdialog'        # For popup in browsers like file save dialog.
    'dolphin' 'dolphin-plugins' 'kdegraphics-thumbnailers' 'ffmpegthumbnailer' 'ffmpegthumbs'
    'ark' # ark is needed for dolphin archive/unarchive plugin.
    'gwenview' 'kimageformats' 'qt6-imageformats'
    'kamoso' 'kate' 'konsole')

# 'baloo' 'audiocd-kio' 'kompare' 'kio-gdrive' 'kio-admin' 'libappimage' 'kdesdk-thumbnailers' 'icoutils'
# 'packagekit-qt6'
# 'appmenu-gtk-module' 'webkit2gtk' 'materia-gtk-theme' 'adapta-gtk-theme'
# 'networkmanager-openvpn'  'networkmanager-openconnect'
PACMAN_PACKAGES+=(
    'xdg-desktop-portal-gtk' 'adw-gtk-theme'
    'gobject-introspection' 'glib2-devel' # Waybar GTK apps are breaking without gobject-introspection and glib2-devel.
)

PACMAN_PACKAGES+=(
    'mpv-mpris' 'mpd-mpris' # For waybar mpris module. https://man.archlinux.org/man/extra/waybar/waybar-mpris.5.en
    'playerctl' # mpris media player controller and lib for spotify, vlc, audacious, bmp, xmms2, and others.
)

# fontforge # For font-patcher, used to patching any font to nerd font
PACMAN_PACKAGES+=('noto-fonts' 'noto-fonts-cjk' 'noto-fonts-emoji' 'noto-fonts-extra' 'otf-font-awesome'
    'woff2-font-awesome')

# 'chrono-date' 'meson' 'scdoc' # Needed for waybar

# 'libavtp' 'lib32-libavtp' 'lib32-libsamplerate' 'lib32-speexdsp'
#  'faac' 'faad2' 'lame' 'libdca' 'libdv'
# 'gst-libav'  'libmad' 'libmpeg2' 'libtheora' 'libvorbis' 'libxv' 'x264' 'xvidcore'

PACMAN_PACKAGES+=('firefox')

PACMAN_PACKAGES+=('ffmpeg')

PACMAN_PACKAGES+=('yt-dlp')

PACMAN_PACKAGES+=('gstreamer' 'gst-plugins-base' 'gst-plugins-good' 'gst-plugins-bad' 'gst-plugins-ugly' 'gst-libav')

PACMAN_PACKAGES+=('alsa-plugins' 'lib32-alsa-plugins' 'alsa-firmware' 'alsa-utils')

PACMAN_PACKAGES+=('wireplumber' 'pipewire' 'lib32-pipewire' 'sof-firmware'
    'pipewire-alsa' 'gst-plugin-pipewire' 'lib32-pipewire-jack' 'pipewire-jack' 'pipewire-pulse'
    'pipewire-v4l2' 'lib32-pipewire-v4l2'
    'pipewire-zeroconf'
    'speech-dispatcher' # For speech recognition, like discord audio call.
)

PACMAN_PACKAGES+=('pavucontrol')

PACMAN_PACKAGES+=('haruna')

PACMAN_PACKAGES+=('cups' 'cups-pdf' 'hplip' 'cups-pk-helper' 'system-config-printer' 'print-manager')

PACMAN_PACKAGES+=('blueman')

PACMAN_PACKAGES+=('wireguard-tools')

PACMAN_PACKAGES+=('veracrypt' 'keepassxc')

# 'yubikey-manager-qt' Is broken
PACMAN_PACKAGES+=('yubikey-personalization' 'yubikey-personalization-gui' 'yubikey-manager')

PACMAN_PACKAGES+=('gimp' 'qbittorrent' 'signal-desktop' 'nextcloud-client')

PACMAN_PACKAGES+=('timeshift')

if lspci | grep -E "(VGA|3D)" | grep -E "(NVIDIA|GeForce)"; then
    PACMAN_PACKAGES+=('nvidia-settings' 'nvidia-prime' 'lib32-nvidia-utils' 'libvdpau-va-gl'
        'libva-nvidia-driver' 'libva-utils' # For hardware acceleration
    )
    touch /etc/environment

    sed -i '/LIBVA_DRIVER_NAME/d' /etc/environment
    sed -i '/__GLX_VENDOR_LIBRARY_NAME/d' /etc/environment
    sed -i '/NVD_BACKEND/d' /etc/environment
    sed -i '/GBM_BACKEND/d' /etc/environment

    echo 'LIBVA_DRIVER_NAME=nvidia' | tee -a /etc/environment
    echo '__GLX_VENDOR_LIBRARY_NAME=nvidia' | tee -a /etc/environment
    echo 'NVD_BACKEND=direct' | tee -a /etc/environment
    echo 'GBM_BACKEND=nvidia-drm' | tee -a /etc/environment
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

echo "-------------------------------------------------------"
echo "   Disable dbus org.kde.plasma.Notifications.service   "
echo "-------------------------------------------------------"

if [[ -f /usr/share/dbus-1/services/org.kde.plasma.Notifications.service ]]; then
    mv /usr/share/dbus-1/services/org.kde.plasma.Notifications.service \
        /usr/share/dbus-1/services/org.kde.plasma.Notifications.service.disabled
fi

echo "-------------------------------------------------------"
echo "                    Enable Services                    "
echo "-------------------------------------------------------"

if lspci | grep -E "(VGA|3D)" | grep -E "(NVIDIA|GeForce)"; then
    systemctl enable nvidia-suspend.service
    systemctl enable nvidia-hibernate.service
    systemctl enable nvidia-resume.service
fi

systemctl enable sddm cups avahi-daemon.service
systemctl set-default graphical.target

echo "-------------------------------------------------------"
echo "             Install Yay and AUR Packages              "
echo "-------------------------------------------------------"

AUR_INSTALL_USER="arch-yay-installer-user"

echo "Adding user ${AUR_INSTALL_USER}"

id -u "${AUR_INSTALL_USER}" &>/dev/null ||
    useradd -s /bin/bash --system -m -d "/home/${AUR_INSTALL_USER}" "${AUR_INSTALL_USER}"

echo "${AUR_INSTALL_USER} ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/10-"${AUR_INSTALL_USER}"

AUR_BASIC_PACKAGES=(
    'yay'
    'nordvpn-bin'
    'brave-bin' 'google-chrome'
    'onlyoffice-bin'
    'yubico-authenticator-bin'
    'redhat-fonts' 'sddm-silent-theme' # redhat-fonts is needed for sddm-silent-theme, which comes from AUR, So needed to be installed first and explicitly.
)

# Import OpenPGP key for yay
su - "${AUR_INSTALL_USER}" -c "
            set -eou pipefail
            curl https://keys.openpgp.org/vks/v1/by-fingerprint/20EE325B86A81BCBD3E56798F04367096FBA95E8 |
            gpg --import --batch --yes
        "

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
