#!/usr/bin/env bash
set -e

sudo timedatectl set-ntp true
sudo timedatectl set-timezone Asia/Kolkata

sudo apt-get install -y linux-firmware linux-headers-"$(uname -r)" linux-modules-extra-"$(uname -r)" \
  dkms network-manager net-tools build-essential openssh-server dhcpcd5 libgtkmm-3.0-dev ethtool vim neovim

# Add VS Code Repo
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=$(dpkg-architecture -q DEB_BUILD_ARCH)=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

sudo wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg
sudo echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

sudo apt-get install fonts-liberation software-properties-common apt-transport-https wget ca-certificates gnupg2 -y

sudo add-apt-repository multiverse -y

sudo apt update

sudo apt-get install -y git gnupg2 curl zsh terminator htop

if hash google-chrome-stable &>/dev/null; then
  echo "google-chrome is installed!"
else
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome-stable_current_amd64.deb
  rm -rf google-chrome-stable_current_amd64.deb
fi


sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [arch=$(dpkg-architecture -q DEB_BUILD_ARCH) signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
  sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sudo apt update

# Install
# sudo apt-get install code -y # Install from userapps
sudo apt-get install sublime-text -y

# Install java from user apps
# sudo apt-get install openjdk-17-jdk maven gradle gradle-doc groovy groovy-doc -y

sudo apt-get install -y python3-pip

# Install from userapps
# sudo apt-get install -y golang

# Codecs
# sudo apt-get install ubuntu-restricted-extras -y
sudo apt-get install -y ffmpegthumbnailer ffmpeg vlc eog heif-gdk-pixbuf heif-thumbnailer

# Gnome

__optional_packages=('gnome-tweak-tool' 'gnome-tweaks' 'gnome-shell-extension-manager')

for i in "${__optional_packages[@]}"; do
  echo "Checking for package $i"
  __apt_search=$(apt-cache search --names-only "$i")
  if [[ -n $__apt_search ]]; then
    echo "Installing $i"
    sudo apt-get install -y "$i"
  else
    echo "No install candidate for $i"
  fi
done

sudo apt install -y gnome-shell-extensions gnome-shell-extension-prefs

# Fuse is needed for AppImage
# sudo apt install -y fuse3/fuse

sudo apt install brave-browser -y

# Service
sudo systemctl enable NetworkManager
sudo systemctl enable dhcpcd
sudo systemctl enable ssh

echo "END Of Script"
