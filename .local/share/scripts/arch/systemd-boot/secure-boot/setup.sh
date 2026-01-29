#!/usr/bin/env bash
set -euo pipefail
echo "Starting setup"
echo "Allowed hosts are: s1-dev, s2-dev"

export TARGET_HOSTNAME="${1:-$(hostname -s)}"

if [[ "${TARGET_HOSTNAME}" != "s1-dev" ]] && [[ "${TARGET_HOSTNAME}" != "s2-dev" ]]; then
    echo "Invalid hostname provided. Allowed hosts are: s1-dev, s2-dev"
    echo "First argument should be one of the above"
    exit 1
fi

allowed_host_names=(
    s1-dev
    s2-dev
)

is_valid_hostname=false
for host in "${allowed_host_names[@]}"; do
    if [[ "$TARGET_HOSTNAME" == "$host" ]]; then
        is_valid_hostname=true
        echo "Valid hostname: $TARGET_HOSTNAME"
        break
    fi
done

if ! $is_valid_hostname; then
    echo "Invalid hostname: $TARGET_HOSTNAME"
    echo "Allowed hosts are: ${allowed_host_names[*]}"
    exit 1
fi

if [[ -d /run/systemd/system ]] && [[ "$(ps -p 1 -o comm=)" == "systemd" ]]; then
    export IS_RUNNING_SYSTEMD=true
else
    export IS_RUNNING_SYSTEMD=false
fi

echo "System is running systemd: $IS_RUNNING_SYSTEMD"

echo "--------------------------------------"
echo "--     Time zone : Asia/Kolkata     --"
echo "--------------------------------------"
rm -rf /etc/localtime
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

if [[ "$IS_RUNNING_SYSTEMD" == "true" ]]; then
    timedatectl set-timezone Asia/Kolkata
    timedatectl set-ntp true
else
    echo "Skipping systemd time setup (not running under systemd)"
fi

hwclock --systohc

echo "Current date time : $(date)"

echo "--------------------------------------"
echo "--       Localization : UTF-8       --"
echo "--------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
echo 'LANG=en_US.UTF-8' >/etc/locale.conf
locale-gen

if [[ "$IS_RUNNING_SYSTEMD" == "true" ]]; then
    localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8"
    localectl --no-ask-password set-keymap us
    localectl
else
    echo "Skipping systemd services (not running under systemd)"
fi

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

echo "Add parallel downloading"
sed -i 's/^#Para/Para/' /etc/pacman.conf
sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
echo "Enable multilib"
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
cp /etc/pacman.d/mirrorlist "/etc/pacman.d/mirrorlist.bak-$(date +%s)"

echo "--------------------------------------"
echo "             Set Host Name            "
echo "--------------------------------------"

echo "${TARGET_HOSTNAME}" | tee /etc/hostname
cat <<EOT >"/etc/hosts"
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${TARGET_HOSTNAME} ${TARGET_HOSTNAME}.blr-home.easyiac.com
EOT

if [[ "$IS_RUNNING_SYSTEMD" == "true" ]]; then
    hostnamectl hostname "${TARGET_HOSTNAME}"
else
    echo "Skipping systemd services (not running under systemd)"
fi

pacman -Sy archlinux-keyring --noconfirm

sed -i 's|^keyserver .*|keyserver hkp://keyserver.ubuntu.com|' /etc/pacman.d/gnupg/gpg.conf

pacman -Sy reflector curl --noconfirm --needed

reflector --country India --age 12 \
    --protocol https --sort rate --save /etc/pacman.d/mirrorlist --verbose

pacman -Syu --noconfirm

# Core system & boot
PACMAN_BASIC_PACKAGES=('base' 'base-devel' 'linux' 'linux-headers' 'linux-api-headers' 'mkinitcpio'
    'efibootmgr' 'sbctl' 'plymouth')

# Firmware
PACMAN_BASIC_PACKAGES+=('linux-firmware' 'linux-firmware-atheros' 'linux-firmware-broadcom' 'linux-firmware-mediatek'
    'linux-firmware-realtek' 'linux-firmware-other' 'linux-firmware-whence' 'fwupd')

# Init, services & scheduling
PACMAN_BASIC_PACKAGES+=('systemd' 'cronie' 'power-profiles-daemon')

# Networking & firewall
PACMAN_BASIC_PACKAGES+=('networkmanager' 'dhcpcd' 'dhclient' 'inetutils' 'openssh' 'iptables-nft' 'ufw')

# Storage, filesystems & disk utilities
PACMAN_BASIC_PACKAGES+=('lvm2' 'cryptsetup' 'btrfs-progs' 'xfsprogs' 'nilfs-utils' 'jfsutils' 'udftools' 'dosfstools'
    'exfatprogs' 'ntfs-3g' 'sshfs')

# Archiving & compression
PACMAN_BASIC_PACKAGES+=('zip' 'unzip' 'p7zip' 'unrar' 'unarchiver' 'pigz' 'lzop' 'lrzip')

# Monitoring & diagnostics
PACMAN_BASIC_PACKAGES+=('htop' 'bpytop' 'bashtop' 'sysstat' 'lm_sensors' 'lsof' 'strace' 'screenfetch')

# Development toolchains
PACMAN_BASIC_PACKAGES+=('make' 'cmake' 'ninja' 'gcc' 'clang' 'llvm' 'llvm-libs' 'lldb' 'devtools' 'tree-sitter')

# Cross-compilers & embedded
PACMAN_BASIC_PACKAGES+=('mingw-w64-gcc' 'arm-none-eabi-gcc' 'arm-none-eabi-newlib')

PACMAN_BASIC_PACKAGES+=('dkms')

# CLI essentials & shell tooling
PACMAN_BASIC_PACKAGES+=('curlftpfs' 'wget' 'jq' 'trurl' 'git' 'less' 'tree' 'shfmt' 'tmux' 'vim' 'zsh' 'shellcheck'
    'bash-completion')

PACMAN_BASIC_PACKAGES+=('lua' 'luarocks')

PACMAN_BASIC_PACKAGES+=('hunspell' 'hunspell-en_us' 'hunspell-en_gb')

PACMAN_BASIC_PACKAGES+=('docker' 'criu' 'docker-buildx' 'docker-compose')

PACMAN_BASIC_PACKAGES+=('postgresql-libs')

PACMAN_BASIC_PACKAGES+=('ccid' 'opensc' 'pcsc-tools')

PACMAN_BASIC_PACKAGES+=('rclone' 'rsync' 'restic' 'borg')

PACMAN_BASIC_PACKAGES+=('bluez' 'bluez-utils')

echo "--------------------------------------------------"
echo "--determine processor type and install microcode--"
echo "--------------------------------------------------"
proc_type=$(grep vendor /proc/cpuinfo | uniq | awk '{print $3}')
echo "proc_type: $proc_type"
case "$proc_type" in
GenuineIntel)
    echo "Installing Intel microcode"
    PACMAN_BASIC_PACKAGES+=('intel-ucode')
    ;;
AuthenticAMD)
    echo "Installing AMD microcode"
    PACMAN_BASIC_PACKAGES+=('amd-ucode')
    ;;
*)
    echo "Unknown processor type"
    exit 1
    ;;
esac

echo "--------------------------------------------------"
echo "         Graphics Drivers find and install        "
echo "--------------------------------------------------"
IS_NVIDIA_DRM=false
if lspci | grep -E "(VGA|3D)" | grep -E "(NVIDIA|GeForce)"; then

    echo "-----------------------------------------------------------"
    echo "  Setting Nvidia Drivers setup pacman hook and udev rules  "
    echo "-----------------------------------------------------------"
    echo "Adding nvidia drivers to be installed"
    IS_NVIDIA_DRM=true
    #This will cause egl packages to install 'extra/egl-gbm' 'extra/egl-wayland' 'extra/egl-wayland2' 'egl-x11'
    PACMAN_BASIC_PACKAGES+=('linux-firmware-nvidia' 'nvtop' 'nvidia-open' 'nvidia-container-toolkit')

    mkdir -p "/etc/pacman.d/hooks"
    cat <<EOT >"/etc/pacman.d/hooks/nvidia.hook"
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia-open
Target=linux

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r -r trg; do case \$trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOT
    mkdir /etc/udev/rules.d/ -p
    cat <<EOT >"/etc/udev/rules.d/99-nvidia.rules"
ACTION=="add", DEVPATH=="/bus/pci/drivers/nvidia", RUN+="/usr/bin/nvidia-modprobe -c0 -u"
EOT
fi

if lspci | grep -E "(VGA|3D)" | grep -E "(Radeon|Advanced Micro Devices)"; then

    echo "-----------------------------------------------------------"
    echo "                    Setting AMD Drivers                    "
    echo "-----------------------------------------------------------"
    PACMAN_BASIC_PACKAGES+=('linux-firmware-amdgpu')
fi

if lspci | grep -E "(VGA|3D)" | grep -E "(Integrated Graphics Controller|Intel Corporation)"; then

    echo "-----------------------------------------------------------"
    echo "                   Setting Intel Drivers                   "
    echo "-----------------------------------------------------------"
    PACMAN_BASIC_PACKAGES+=('linux-firmware-intel')
fi

echo "--------------------------------------------------"
echo "         Installing Hell lot of packages          "
echo "--------------------------------------------------"

pacman -S --needed --noconfirm "${PACMAN_BASIC_PACKAGES[@]}"

echo "--------------------------------------------------"
echo '      Setting Root Password to a Random one       '
echo "--------------------------------------------------"

# shellcheck disable=SC2155
NEW_RANDOM_ROOT_PASSWORD="$(openssl rand -base64 128 | tr -d '\n')"
export NEW_RANDOM_ROOT_PASSWORD
echo "Setting a random root password"
printf '%s\n%s\n' "$NEW_RANDOM_ROOT_PASSWORD" "$NEW_RANDOM_ROOT_PASSWORD" | passwd root

echo "------------------------------------------"
echo "       heil wheel group in sudoers        "
echo "------------------------------------------"

getent group sudo || groupadd --system sudo
getent group wheel || groupadd --system wheel

echo "Add wheel no password rights"
mkdir -p /etc/sudoers.d
echo "root ALL=(ALL:ALL) ALL" | tee /etc/sudoers.d/1000-root
echo "%sudo ALL=(ALL:ALL) ALL" | tee /etc/sudoers.d/1100-sudo
echo "%wheel ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/1200-wheel

echo "--------------------------------------"
echo "           Create Admin User          "
echo "--------------------------------------"

SYSTEM_ADMIN_USER="${SYSTEM_ADMIN_USER:-admin1}"
SYSTEM_ADMIN_PASSWORD="${SYSTEM_ADMIN_PASSWORD:-password}"
id -u "${SYSTEM_ADMIN_USER}" &>/dev/null || useradd -s /bin/bash -G docker,wheel -m \
    -d "/home/${SYSTEM_ADMIN_USER}" "${SYSTEM_ADMIN_USER}"

usermod -aG docker,wheel "${SYSTEM_ADMIN_USER}"
echo "Set the password for user ${SYSTEM_ADMIN_USER} using '${SYSTEM_ADMIN_PASSWORD}'."
echo -e "${SYSTEM_ADMIN_PASSWORD}\n${SYSTEM_ADMIN_PASSWORD}" | passwd "${SYSTEM_ADMIN_USER}"

echo "Adding ssh key to admin user"
mkdir -p "/home/${SYSTEM_ADMIN_USER}/.ssh"
curl -fl https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/assets/id_ecdsa.pub |
    tee -a "/home/${SYSTEM_ADMIN_USER}/.ssh/authorized_keys"
chmod 600 "/home/${SYSTEM_ADMIN_USER}/.ssh/authorized_keys"
chown -R "${SYSTEM_ADMIN_USER}":"${SYSTEM_ADMIN_USER}" "/home/${SYSTEM_ADMIN_USER}/.ssh"

echo "--------------------------------------"
echo "         SSH Key Only login           "
echo "--------------------------------------"

mkdir -p /etc/ssh/sshd_config.d
tee "/etc/ssh/sshd_config.d/010-ssh-ansible.conf" <<EOF
Port 22
PasswordAuthentication no
PermitRootLogin no
PermitEmptyPasswords no
MaxAuthTries 3
X11Forwarding no
ClientAliveInterval 60
ClientAliveCountMax 3
ChallengeResponseAuthentication no

EOF

echo "--------------------------------------"
echo "      Disable MAC Randomization       "
echo "--------------------------------------"

mkdir -p /etc/NetworkManager/conf.d
tee "/etc/NetworkManager/conf.d/30-mac-randomization.conf" <<EOF
[device-mac-randomization]
wifi.scan-rand-mac-address=yes

[connection-mac-randomization]
ethernet.cloned-mac-address=permanent
wifi.cloned-mac-address=permanent

EOF

echo "--------------------------------------"
echo "       Enable Mandatory Services      "
echo "--------------------------------------"

mkdir -p /etc/pacman.d/hooks

mkdir -p /etc/systemd/system/NetworkManager.service.d
tee "/etc/systemd/system/NetworkManager.service.d/44-override.conf" <<EOF
[Service]
TimeoutStopSec=10s
EOF

tee "/etc/pacman.d/hooks/95-systemd-boot.hook" <<EOF
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Gracefully upgrading systemd-boot...
When = PostTransaction
Exec = /usr/bin/systemctl restart systemd-boot-update.service
EOF

SYSTEMD_BASIC_SERVICES=('dhcpcd' 'NetworkManager' 'systemd-timesyncd' 'systemd-resolved' 'iptables' 'ufw' 'docker' 'pcscd'
    'bluetooth' 'power-profiles-daemon' 'fwupd-refresh.timer' 'cronie' 'sshd' 'systemd-boot-update'
)

for SYSTEMD_BASIC_SERVICE in "${SYSTEMD_BASIC_SERVICES[@]}"; do
    echo "Enable Service: ${SYSTEMD_BASIC_SERVICE}"
    systemctl enable "$SYSTEMD_BASIC_SERVICE"
done

if ! command -v nvidia-ctk &>/dev/null; then
    echo "Nvidia Container Toolkit is not installed. Skipping Nvidia setup."
else
    echo "Nvidia Container Toolkit is installed."

    if $IS_RUNNING_SYSTEMD; then
        echo "Systemd detected. Proceeding with Nvidia runtime configuration."
        nvidia-ctk runtime configure --runtime=docker
        systemctl restart docker
    else
        echo "Systemd not running (arch-chroot / container). Skipping systemd-dependent Nvidia setup."
    fi
fi

echo "-----------------------------------------------------------------------------------"
echo "                           Install Boot-loader with UEFI                           "
echo "-----------------------------------------------------------------------------------"

if [[ "${IS_NVIDIA_DRM}" == "true" ]]; then
    mkdir -p /etc/modprobe.d
    tee "/etc/modprobe.d/nvidia-drm.conf" <<EOF
options nvidia-drm modeset=1
EOF

    sed -i 's/^MODULES=.*/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf

fi

plymouth-set-default-theme spinner

tee "/etc/mkinitcpio.d/linux.preset" <<EOF
ALL_kver="/boot/vmlinuz-linux"
PRESETS=('default' 'fallback')
default_image="/boot/initramfs-linux.img"
default_options=""
fallback_image="/boot/initramfs-linux-fallback.img"
fallback_options="-S autodetect"
EOF

echo "KEYMAP=us" | tee /etc/vconsole.conf

sed -i 's/^HOOKS=.*/HOOKS=(base systemd plymouth autodetect microcode modconf kms keyboard keymap sd-vconsole block sd-encrypt lvm2 filesystems fsck)/' \
    /etc/mkinitcpio.conf

mkinitcpio -P
chmod 600 /boot/initramfs-linux*

mkdir -p /boot/loader

tee "/boot/loader/loader.conf" <<EOF
default  arch.conf
timeout  4
console-mode auto
editor   yes
EOF

mkdir -p /boot/loader/entries

tee "/boot/loader/entries/arch.conf" <<EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options $(cat /etc/kernel/cmdline) splash quiet
EOF

tee "/boot/loader/entries/arch-fallback.conf" <<EOF
title   Arch Linux (fallback)
linux   /vmlinuz-linux
initrd  /initramfs-linux-fallback.img
options $(cat /etc/kernel/cmdline) splash quiet
EOF

bootctl install

sbctl sign -s /boot/vmlinuz-linux
sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI
sbctl sign -s /boot/EFI/systemd/systemd-bootx64.efi

sbctl status
sbctl verify
bootctl list

echo "-------------------------------------------------------"
echo "             Install Yay and AUR Packages              "
echo "-------------------------------------------------------"

echo "Adding user arch-yay-installer-user"
id -u arch-yay-installer-user &>/dev/null ||
    useradd -s /bin/bash --system -m -d /home/arch-yay-installer-user arch-yay-installer-user
echo "arch-yay-installer-user ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/10-arch-yay-installer-user

if ! command -v yay &>/dev/null; then

    sudo -H -u arch-yay-installer-user bash -c '
    set -e
    rm -rf ~/yay
    git clone "https://aur.archlinux.org/yay.git" ~/yay --depth=1
    cd "${HOME}/yay"
    makepkg -si --noconfirm
    '
fi

while orphaned=$(pacman -Qtdq); do
    [[ -z "${orphaned}" ]] && break
    pacman -R --noconfirm "${orphaned}"
done

AUR_BASIC_PACKAGES=('nordvpn-bin')

sudo -H -u arch-yay-installer-user bash -c "cd ~ && \
        yay -S --answerclean None --answerdiff None --noconfirm --needed $(printf " %s" "${AUR_BASIC_PACKAGES[@]}")"

while orphaned=$(pacman -Qtdq); do
    [[ -z "${orphaned}" ]] && break
    pacman -R --noconfirm "${orphaned}"
done

usermod -aG nordvpn "${SYSTEM_ADMIN_USER}"
systemctl enable nordvpnd

echo "Install root certificate"

ROOT_CERTIFICATE_TEMP_FILE="$(mktemp)"
curl -fL https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/assets/root_ca_crt.pem |
    tee "${ROOT_CERTIFICATE_TEMP_FILE}"
trust anchor --store "${ROOT_CERTIFICATE_TEMP_FILE}"

mkdir -p /etc/ca-certificates/trust-source/anchors
cp "${ROOT_CERTIFICATE_TEMP_FILE}" /etc/ca-certificates/trust-source/anchors/root_ca.crt
update-ca-trust

echo "Its a good idea to run 'pacman -R \$(pacman -Qtdq)' or 'yay -R \$(yay -Qtdq)'."

echo "Completed"
