#!/usr/bin/env bash
set -e
echo "Starting s1-dev setup"

echo "--------------------------------------"
echo "--     Time zone : Asia/Kolkata     --"
echo "--------------------------------------"
rm -rf /etc/localtime
timedatectl set-timezone Asia/Kolkata || true
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
timedatectl set-ntp true || true
echo "Current date time : " "$(date)"

echo "--------------------------------------"
echo "--       Localization : UTF-8       --"
echo "--------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8" || true
localectl --no-ask-password set-keymap us || true
echo 'LANG=en_US.UTF-8' >/etc/locale.conf
localectl || true

nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have $nc cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for $nc cores."
TOTALMEM=$(grep -i 'memtotal' /proc/meminfo | grep -o '[[:digit:]]*')
if [[ $TOTALMEM -gt 8000000 ]]; then
    sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
    echo "Changing the compression settings for $nc cores."
    sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf
fi

#Add parallel downloading
sed -i 's/^#Para/Para/' /etc/pacman.conf

#Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

echo "--------------------------------------"
echo "             Set Host Name            "
echo "--------------------------------------"

touch /etc/hosts
touch /etc/hostname
hostnamectl hostname s1-dev || true
echo s1-dev | tee /etc/hostname

cat <<EOT >"/etc/hosts"
127.0.0.1   localhost
::1         localhost
127.0.1.1   s1-dev s1-dev.localdomain
EOT

pacman -Sy archlinux-keyring --noconfirm

grep "keyserver hkp://keyserver.ubuntu.com" \
    /etc/pacman.d/gnupg/gpg.conf ||
    echo "keyserver hkp://keyserver.ubuntu.com" >>/etc/pacman.d/gnupg/gpg.conf

pacman -Syu --noconfirm

ALL_PAKGS=('mkinitcpio' 'grub' 'efibootmgr' 'dhcpcd' 'networkmanager'
    'openssh' 'git' 'vim' 'base' 'base-devel' 'linux' 'linux-firmware' 'lvm2' 'exfatprogs')

ALL_PAKGS+=('base' 'base-devel' 'linux' 'linux-firmware' 'linux-headers' 'zip' 'unzip' 'pigz' 'wget' 'ntfs-3g'
    'jfsutils' 'udftools' 'xfsprogs' 'nilfs-utils'
    'curlftpfs' 'dhcpcd' 'networkmanager' 'dhclient' 'ufw' 'p7zip' 'unrar' 'jq' 'unarchiver' 'lzop' 'lrzip' 'curl'
    'libxcrypt-compat')

ALL_PAKGS+=('neovim' 'xclip' 'wl-clipboard' 'python-pynvim' 'make' 'cmake' 'ninja' 'lua' 'luarocks' 'dkms'
    'gtkmm3' 'pcsclite' 'swtpm' 'wget' 'git' 'openssl-1.1' 'realtime-privileges' 'tree-sitter')

ALL_PAKGS+=('bash-completion' 'python-pip' 'rclone' 'rsync' 'git' 'shellcheck')

ALL_PAKGS+=('docker' 'criu' 'docker-scan' 'docker-buildx' 'docker-compose' 'sshfs' 'btrfs-progs' 'dosfstools')

ALL_PAKGS+=('terraform' 'pulumi' 'vault' 'go' 'terragrunt' 'keyd')

ALL_PAKGS+=('ccid' 'opensc' 'pcsc-tools' 'gimp' 'postgresql-libs')

ALL_PAKGS+=('firefox')

ALL_PAKGS+=('veracrypt' 'keepassxc' 'bpytop' 'htop' 'neofetch' 'screenfetch' 'bashtop' 'sysstat')

ALL_PAKGS+=('noto-fonts-cjk' 'noto-fonts-emoji' 'noto-fonts-extra')

ALL_PAKGS+=('xorg' 'xorg-xinit' 'phonon-qt5-gstreamer' 'plasma' 'xdg-desktop-portal' 'sddm' 'konsole')

ALL_PAKGS+=('kwalletmanager' 'kleopatra' 'partitionmanager' 'skanlite')

ALL_PAKGS+=('spectacle' 'gwenview' 'kcalc' 'kamera' 'lm_sensors' 'lsof' 'strace' 'tk' 'gnuplot')

ALL_PAKGS+=('packagekit-qt5' 'qbittorrent' 'kdialog')

# 'raw-thumbnailer' not found, 'kimageformats' not found
ALL_PAKGS+=('dolphin' 'dolphin-plugins' 'kompare' 'kdegraphics-thumbnailers' 'qt5-imageformats'
    'kdesdk-thumbnailers' 'ffmpegthumbs' 'ark' 'gvfs')

# materia-kde materia UI based themes support, kvantum-qt5 has moved to aur
ALL_PAKGS+=('kvantum' 'materia-kde')

ALL_PAKGS+=('qt5-declarative' 'qt5-x11extras' 'kdecoration' 'print-manager')

ALL_PAKGS+=('networkmanager-openvpn' 'libnma')

# GTK Themes Support
# materia-gtk-theme this is required for some of the themes like prof and sweet
# gtk-engine-murrine and gtk-engines is required by materia-gtk-theme
# adapta-gtk-theme Gtk+ theme based on Material Design
ALL_PAKGS+=('gtk-engine-murrine' 'gtk-engines' 'appmenu-gtk-module' 'webkit2gtk' 'materia-gtk-theme' 'adapta-gtk-theme')

# Extras
ALL_PAKGS+=('hunspell-en_us' 'hunspell-en_gb') # For some spelling check
ALL_PAKGS+=('cryfs' 'encfs' 'gocryptfs')       # For kde vault
ALL_PAKGS+=('texlive-core' 'libwmf' 'scour' 'pstoedit' 'fig2dev' 'yubikey-manager' 'yubikey-manager-qt')

ALL_PAKGS+=('terminator' 'zsh')

ALL_PAKGS+=('libavtp' 'lib32-alsa-plugins' 'lib32-libavtp' 'lib32-libsamplerate' 'lib32-speexdsp' 'lib32-glib2')

ALL_PAKGS+=('thunderbird' 'bitwarden' 'signal-desktop' 'telegram-desktop')

ALL_PAKGS+=('cups' 'cups-pdf' 'hplip' 'usbutils' 'system-config-printer' 'cups-pk-helper')

# 'kcodecs' 'ffmpeg2theora' removed from arch
ALL_PAKGS+=('ffmpegthumbnailer' 'gst-libav' 'gstreamer' 'gst-plugins-bad' 'gst-plugins-good' 'gst-plugins-ugly'
    'gst-plugins-base' 'a52dec' 'faac' 'faad2' 'flac' 'jasper' 'lame' 'libdca' 'libdv' 'libmad' 'ffmpeg'
    'libmpeg2' 'libtheora' 'libvorbis' 'libxv' 'wavpack' 'x264' 'xvidcore' 'vlc')

# Not Sure if this is needed Removed # libva-vdpau-driver lib32-libva-vdpau-driver
ALL_PAKGS+=('libva-mesa-driver' 'lib32-libva-mesa-driver' 'mesa-vdpau' 'lib32-mesa-vdpau'
    'lib32-mesa' 'libvdpau-va-gl' 'mesa-utils')

echo "--------------------------------------------------"
echo "--determine processor type and install microcode--"
echo "--------------------------------------------------"
proc_type=$(grep vendor /proc/cpuinfo | uniq | awk '{print $3}')
echo "proc_type: $proc_type"
case "$proc_type" in
GenuineIntel)
    echo "Installing Intel microcode"
    ALL_PAKGS+=('intel-ucode')
    ;;
AuthenticAMD)
    echo "Installing AMD microcode"
    ALL_PAKGS+=('amd-ucode')
    ;;
esac

echo "--------------------------------------------------"
echo "         Graphics Drivers find and install        "
echo "--------------------------------------------------"

if lspci | grep -E "(VGA|3D)" | grep -E "(NVIDIA|GeForce)"; then

    echo "-----------------------------------------------------------"
    echo "  Setting Nvidia Drivers setup pacman hook and udev rules  "
    echo "-----------------------------------------------------------"

    ALL_PAKGS+=('nvidia' 'nvidia-utils' 'nvidia-settings' 'nvidia-prime' 'lib32-nvidia-utils' 'nvtop' 'libvdpau-va-gl')
    echo "Adding nvidia drivers to be installed"

    mkdir -p "/etc/pacman.d/hooks"
    cat <<EOT >"/etc/pacman.d/hooks/nvidia.hook"
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux
# Change the linux part above and in the Exec line if a different kernel is used

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r -r trg; do case \$trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOT
    echo "Nvidia pacman hook installed /etc/pacman.d/hooks/nvidia.hook"
    cat /etc/pacman.d/hooks/nvidia.hook

    mkdir /etc/udev/rules.d/ -p
    cat <<EOT >"/etc/udev/rules.d/99-nvidia.rules"
ACTION=="add", DEVPATH=="/bus/pci/drivers/nvidia", RUN+="/usr/bin/nvidia-modprobe -c0 -u"
EOT

    echo "Nvidia pudev rule installed /etc/udev/rules.d/99-nvidia.rules"
    cat /etc/udev/rules.d/99-nvidia.rules

fi

if lspci | grep -E "(VGA|3D)" | grep -E "(Radeon|Advanced Micro Devices)"; then

    echo "-----------------------------------------------------------"
    echo "                    Setting AMD Drivers                    "
    echo "-----------------------------------------------------------"

    ALL_PAKGS+=('xf86-video-amdgpu' 'amdvlk' 'lib32-amdvlk'
        'xf86-video-amdgpu' 'amdvlk' 'lib32-amdvlk')

fi

if lspci | grep -E "(VGA|3D)" | grep -E "(Integrated Graphics Controller|Intel Corporation)"; then

    echo "-----------------------------------------------------------"
    echo "                   Setting Intel Drivers                   "
    echo "-----------------------------------------------------------"

    ALL_PAKGS+=('libvdpau-va-gl' 'lib32-vulkan-intel' 'vulkan-intel' 'libva-intel-driver' 'libva-utils')

fi

ALL_PAKGS+=('wireplumber' 'pipewire' 'pipewire-pulse' 'pipewire-alsa' 'sof-firmware'
    'pipewire-jack' 'lib32-pipewire' 'lib32-pipewire-jack' 'alsa-firmware' 'alsa-utils'
    'gst-plugin-pipewire' 'pipewire-v4l2' 'pipewire-zeroconf' 'lib32-pipewire-v4l2')

echo "--------------------------------------------------"
echo "         Installing Hell lot of packages          "
echo "--------------------------------------------------"

pacman -S --needed --noconfirm "${ALL_PAKGS[@]}"

echo "--------------------------------------------------"
echo '         Setting Root Password to "root"        '
echo "--------------------------------------------------"
getent group sudo || groupadd sudo
getent group wheel || groupadd wheel
echo -e "root\nroot" | passwd

echo "-----------------------------------------------------------------------------------"
echo "       Install Grub Boot-loader with UEFI in directory /efi                        "
echo "-----------------------------------------------------------------------------------"
mkinitcpio -P
chmod 600 /boot/initramfs-linux*
grub-install --target=x86_64-efi --bootloader-id=Archlinux \
    --efi-directory=/efi --root-directory=/ --recheck
grub-mkconfig -o /boot/grub/grub.cfg

echo "------------------------------------------"
echo "       heil wheel group in sudoers        "
echo "------------------------------------------"

# Add wheel no password rights
mkdir -p /etc/sudoers.d
echo "root ALL=(ALL:ALL) ALL" | tee /etc/sudoers.d/1000-root
echo "%sudo ALL=(ALL:ALL) ALL" | tee /etc/sudoers.d/1100-sudo
echo "%wheel ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/1200-wheel

grep wheel /etc/sudoers

echo "-------------------------------------------------------"
echo "             Install Yay and AUR Packages              "
echo "-------------------------------------------------------"

echo " Adding user makemyarch_build_user"
id -u makemyarch_build_user &>/dev/null ||
    useradd -s /bin/bash -m -d /home/makemyarch_build_user makemyarch_build_user
echo "makemyarch_build_user ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers.d/10-makemyarch_build_user

if ! command -v yay &>/dev/null; then
    sudo -H -u makemyarch_build_user bash -c '
    set -e
    rm -rf ~/yay
    git clone "https://aur.archlinux.org/yay.git" ~/yay --depth=1
    cd "${HOME}/yay"
    makepkg -si --noconfirm
    '
fi

PKGS_AUR=('google-chrome' 'brave-bin' 'sublime-text-4' 'onlyoffice-bin' 'nordvpn-bin')

PKG_AUR_JOIN=$(printf " %s" "${PKGS_AUR[@]}")

sudo -H -u makemyarch_build_user bash -c "cd ~ && \
        yay -S --answerclean None --answerdiff None --noconfirm --needed ${PKG_AUR_JOIN}"
sudo userdel -r makemyarch_build_user || true

echo "--------------------------------------"
echo "       Create User and Groups         "
echo "--------------------------------------"

username="${username:-arpan}"
id -u "${username}" &>/dev/null || useradd -s /bin/zsh -G docker,wheel,nordvpn -m -d "/home/${username}" "${username}"
sudo usermod -aG docker,wheel,nordvpn "${username}"

echo "--------------------------------------"
echo "       Enable Mandatory Services      "
echo "--------------------------------------"

MAN_SERVICES=('dhcpcd' 'NetworkManager' 'systemd-timesyncd' 'systemd-resolved' 'iptables' 'ufw' 'docker' 'sddm' 'pcscd'
    'cups' 'bluetooth' 'nordvpnd' # 'sshd'
)

for MAN_SERVICE in "${MAN_SERVICES[@]}"; do
    echo "Enable Service: ${MAN_SERVICE}"
    systemctl enable "$MAN_SERVICE"
done

echo "Completed"
# shellcheck disable=SC2016
echo "Set the password for user ${username} using 'passwd ${username}'."

echo "Its a good idea to run 'pacman -R \$(pacman -Qtdq)' or 'yay -R \$(yay -Qtdq)'."
