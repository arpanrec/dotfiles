#!/bin/bash
set -xeuo pipefail

#dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
#dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
#dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo --overwrite
#curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
#    tee /etc/yum.repos.d/nvidia-container-toolkit.repo

# dnf install dnf-plugins-core

#dnf config-manager addrepo --from-repofile https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo --overwrite

#dnf install -y fedora-workstation-repositories
#dnf config-manager setopt google-chrome.enabled=1

#dnf update -y

# dnf install -y curl git wget tar zip unzip zsh bash-completion fuse fuse-libs

#dnf remove -y docker docker-client docker-client-latest docker-common docker-latest \
#    docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
#dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#dnf install -y kernel-devel-matched kernel-headers

#dnf install -y akmod-nvidia nvtop
#dnf install -y xorg-x11-drv-nvidia-cuda
#dnf install -y nvidia-container-toolkit nvidia-container-toolkit-base libnvidia-container-tools libnvidia-container1
#nvidia-ctk runtime configure --runtime=docker

#dnf install -y google-chrome-stable brave-browser

#dnf -y install ninja-build cmake gcc make gettext curl glibc-gconv-extra

#dnf -y install neovim vim python3-devel python3-neovim python3-pyyaml

#dnf -y install vlc haruna gtk-murrine-engine gtk2-engines
dnf -y install gnome-tweaks gtk-murrine-engine gtk2-engines
#dnf install -y flatpak
#flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
#flatpak install -y flathub org.gnome.Extensions
