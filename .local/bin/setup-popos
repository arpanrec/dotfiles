#!/usr/bin/env bash
set -xeuo pipefail

echo "Starting setup"
echo "Allowed hosts are: s1-dev, s2-dev"

export TARGET_HOSTNAME="${1}"

timedatectl set-timezone Asia/Kolkata
timedatectl set-ntp true

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
echo 'LANG=en_US.UTF-8' >/etc/locale.conf

localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8"
localectl

echo "${TARGET_HOSTNAME}" | tee /etc/hostname
cat <<EOT >"/etc/hosts"
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${TARGET_HOSTNAME} ${TARGET_HOSTNAME}.blr-home.easyiac.com
EOT

hostnamectl hostname "${TARGET_HOSTNAME}"

# apt update

apt install -y sudo jq git curl wget zip unzip jq zsh bpytop htop lm-sensors fancontrol read-edid i2c-tools

install -d -m 0755 /etc/apt/keyrings
wget -qO- https://dl.google.com/linux/linux_signing_key.pub |
    gpg --dearmor --yes -o /etc/apt/keyrings/google-chrome.gpg
chmod 0644 /etc/apt/keyrings/google-chrome.gpg

tee "/etc/apt/sources.list.d/google-chrome.sources" <<EOF
Types: deb
URIs: https://dl.google.com/linux/chrome/deb/
Suites: stable
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/google-chrome.gpg
EOF

sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt update

apt install -y shfmt shellcheck

apt install -y python3-venv python3-pynvim

apt install -y lua5.1 luarocks ninja-build gettext cmake

apt install -y brave-browser google-chrome-stable

rm -f /etc/apt/sources.list.d/google-chrome.list

sudo apt remove "$(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)"

sudo apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# shellcheck disable=SC2155
export __new_random_root="$(tr -dc 'A-Za-z0-9!@#$%^&*()_+=-{}[]:;,.?' </dev/urandom | head -c 64)"
echo "Setting a random root password"
echo -e "${__new_random_root}\n${__new_random_root}" | passwd root

getent group sudo || groupadd --system sudo
getent group wheel || groupadd --system wheel

mkdir -p /etc/sudoers.d
echo "root ALL=(ALL:ALL) ALL" | tee /etc/sudoers.d/1000-root
echo "%sudo ALL=(ALL:ALL) ALL" | tee /etc/sudoers.d/1100-sudo
echo "%wheel ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/1200-wheel

if lspci | grep -E "(VGA|3D)" | grep -E "(NVIDIA|GeForce)"; then
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey |
        gpg --yes --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg &&
        curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list |
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' |
            tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    apt update
    apt install -y nvidia-container-toolkit nvidia-container-toolkit-base libnvidia-container-tools \
        libnvidia-container1 nvtop
    nvidia-ctk runtime configure --runtime=docker
    systemctl restart docker
fi

sh <(wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh) -p nordvpn-gui
