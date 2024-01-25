#!/usr/bin/env bash
set -e

sudo dnf install -y \
  "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"

sudo dnf install -y \
  "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y libglvnd-devel cmake ncurses-devel git

# chsh
sudo dnf install -y util-linux-user

# JAVA and other dev tools
sudo dnf install -y python3-pip

sudo dnf install -y google-chrome-stable zsh neofetch rclone rsync \
  terminator \
  p7zip p7zip-plugins zip unzip \
  htop openssl
# flatpak install flathub com.mattermost.Desktop -y
# Gnome Things
sudo dnf install -y seahorse gnome-tweaks gnome-extensions-app \
  libappindicator libappindicator-gtk3 libindicator \
  gtkmm4.0 gtkmm4.0-doc gtkmm4.0-devel \
  gtkmm30 gtkmm30-doc gtkmm30-devel mingw32-gtkmm30 mingw64-gtkmm30 \
  gtkmm24 gtkmm24-docs gtkmm24-devel mingw32-gtkmm24 mingw64-gtkmm24 \
  jalv-gtkmm
#    gnome-shell-extension-appindicator
#    gnome-shell-extension-workspace-indicator

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
#sudo dnf install -y code
#sudo echo y | sh <(wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh)

sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg

sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
sudo dnf -y install sublime-text
