#!/bin/bash
set -xeuo pipefail

TARGET_HOSTNAME=s1-dev
TARGET_DOMAINNAME=blr-home.easyiac.com

dnf install -y "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
dnf config-manager addrepo --id=nordvpn --set=baseurl=https://repo.nordvpn.com/yum/nordvpn/centos/x86_64 --set=enabled=1 --overwrite
dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo --overwrite

dnf install dnf-plugins-core

dnf config-manager addrepo --from-repofile https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo --overwrite

dnf install -y fedora-workstation-repositories
dnf config-manager setopt google-chrome.enabled=1

dnf update -y

dnf install -y curl git wget tar zip unzip zsh bash-completion fuse fuse-libs

dnf remove -y docker docker-client docker-client-latest docker-common docker-latest \
    docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable docker.service docker.socket

dnf install -y kernel-devel-matched kernel-headers sgdisk

if lspci | grep -E "(VGA|3D)" | grep -E "(NVIDIA|GeForce)"; then
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo |
        tee /etc/yum.repos.d/nvidia-container-toolkit.repo

    dnf install -y akmod-nvidia nvtop
    dnf install -y xorg-x11-drv-nvidia-cuda
    dnf install -y nvidia-container-toolkit nvidia-container-toolkit-base libnvidia-container-tools libnvidia-container1
    nvidia-ctk runtime configure --runtime=docker
    mkdir -p /etc/dracut.conf.d/
    echo 'add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "' >/etc/dracut.conf.d/nvidia.conf
    dracut --force

fi

dnf install -y google-chrome-stable brave-browser qbittorrent

dnf -y install ninja-build cmake gcc make gettext curl glibc-gconv-extra bash-completion

dnf -y install vim python3-devel python3-pyyaml kvantum ffmpegthumbnailer ffmpegthumbs

dnf -y install vlc haruna gtk-murrine-engine gtk2-engines dolphin-plugins

dnf -y install gtk-murrine-engine gtk2-engines kate lua luarocks nextcloud-client nextcloud-client-dolphin

dnf install -y flatpak htop fastfetch nordvpn-gui

dnf swap ffmpeg-free ffmpeg --allowerasing -y # nvenc doesn't work

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

dnf install snapd -y

systemctl enable snapd.socket
systemctl enable nordvpnd.socket nordvpnd.service

echo "${TARGET_HOSTNAME}" | tee /etc/hostname
cat <<EOT >"/etc/hosts"
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${TARGET_HOSTNAME} ${TARGET_HOSTNAME}.${TARGET_DOMAINNAME}
EOT

hostnamectl hostname "${TARGET_HOSTNAME}"

getent group sudo || groupadd --system sudo
getent group wheel || groupadd --system wheel

echo "Add wheel no password rights"
mkdir -p /etc/sudoers.d
echo "root ALL=(ALL:ALL) ALL" | tee /etc/sudoers.d/1000-root
echo "%sudo ALL=(ALL:ALL) ALL" | tee /etc/sudoers.d/1100-sudo
echo "%wheel ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/1200-wheel

echo "-----------------------------------------------------------------------------------"
echo "                             Install root certificate                              "
echo "-----------------------------------------------------------------------------------"

ROOT_CERTIFICATE_TEMP_FILE="$(mktemp)"
curl -fL https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/assets/root_ca_crt.pem |
    tee "${ROOT_CERTIFICATE_TEMP_FILE}"
trust anchor --store "${ROOT_CERTIFICATE_TEMP_FILE}"

mkdir -p /etc/ca-certificates/trust-source/anchors
cp "${ROOT_CERTIFICATE_TEMP_FILE}" /etc/ca-certificates/trust-source/anchors/root_ca.crt
update-ca-trust
