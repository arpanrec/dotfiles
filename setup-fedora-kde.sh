#!/bin/bash
set -xeuo pipefail

export TARGET_HOSTNAME="${1:-$(hostname -s)}"
export TARGET_DOMAINNAME=blr-home.easyiac.com
case "${TARGET_HOSTNAME}" in
s1-dev | s1-dev-* | s2-dev | s2-dev-*)
    echo "Valid hostname: ${TARGET_HOSTNAME}"
    ;;
*)
    echo "Invalid hostname: ${TARGET_HOSTNAME}"
    echo "Allowed hosts are: s1-dev, s1-dev-*, s2-dev, s2-dev-*"
    exit 1
    ;;
esac

dnf install -y "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
dnf config-manager addrepo --id=nordvpn --set=enabled=1 --overwrite \
    --set=baseurl=https://repo.nordvpn.com/yum/nordvpn/centos/x86_64
rpm -v --import https://repo.nordvpn.com//gpg/nordvpn_public.asc

dnf config-manager addrepo --overwrite --from-repofile \
    https://download.docker.com/linux/fedora/docker-ce.repo

dnf install dnf-plugins-core

dnf config-manager addrepo --overwrite --from-repofile \
    https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

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
    dnf config-manager addrepo --overwrite --from-repofile \
        https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
    dnf config-manager addrepo --overwrite --from-repofile \
        "https://developer.download.nvidia.com/compute/cuda/repos/fedora$(rpm -E %fedora)/x86_64/cuda-fedora$(rpm -E %fedora).repo"

    dnf clean expire-cache

    dnf install -y cuda-drivers nvtop
    dnf install -y nvidia-container-toolkit nvidia-container-toolkit-base libnvidia-container-tools libnvidia-container1
    nvidia-ctk runtime configure --runtime=docker
    mkdir -p /etc/dracut.conf.d/
    echo 'add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "' >/etc/dracut.conf.d/nvidia.conf
    # dracut --force

fi

dnf install -y google-chrome-stable brave-browser qbittorrent

dnf -y install ninja-build cmake gcc make gettext curl glibc-gconv-extra bash-completion \
    shfmt

dnf -y install vim python3-devel python3-pyyaml kvantum ffmpegthumbnailer ffmpegthumbs

dnf -y install vlc haruna gtk-murrine-engine gtk2-engines dolphin-plugins

dnf -y install gtk-murrine-engine gtk2-engines kate lua luarocks restic rsync

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
CERT_SPLIT_DIR="$(mktemp -d)"

curl -fL --connect-timeout 10 --max-time 60 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/assets/intermediate_ca_full_chain.pem \
    -o "${ROOT_CERTIFICATE_TEMP_FILE}"

mkdir -p /etc/ca-certificates/trust-source/anchors

awk -v outdir="${CERT_SPLIT_DIR}" '
BEGIN { c = 0 }
/-----BEGIN CERTIFICATE-----/ { c++ }
{
    file = outdir "/cert." c ".crt"
    print >> file
}
' <"${ROOT_CERTIFICATE_TEMP_FILE}"

for cert in "${CERT_SPLIT_DIR}"/*.crt; do
    trust anchor --store "${cert}"
    cp "${cert}" \
        "/etc/ca-certificates/trust-source/anchors/$(basename "${cert}")"
done

update-ca-trust
