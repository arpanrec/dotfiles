#!/usr/bin/env bash
set -euo pipefail

sleep 30

gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"   # for GTK4 apps
gsettings set org.gnome.desktop.interface gtk-theme "Nordic"   # for GTK3 apps
gsettings set org.gnome.desktop.interface icon-theme 'Tela-nord-dark'
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrainsMono Nerd Font Propo 10"
gsettings set org.gnome.desktop.interface font-name "JetBrainsMono Nerd Font Propo 10"
gsettings set org.gnome.desktop.interface document-font-name "JetBrainsMono Nerd Font Propo 10"
gsettings set org.gnome.desktop.wm.preferences theme "Nordic"
gsettings set org.gnome.desktop.wm.preferences titlebar-font "JetBrainsMono Nerd Font Propo 10"
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'

# JSON
xdg-mime default org.kde.kate.desktop application/json

# HTML & web
xdg-mime default brave-browser.desktop text/html
xdg-mime default firefox.desktop application/xhtml+xml
xdg-mime default firefox.desktop application/x-extension-htm
xdg-mime default firefox.desktop application/x-extension-html
xdg-mime default firefox.desktop application/x-extension-shtml
xdg-mime default firefox.desktop application/x-extension-xht
xdg-mime default firefox.desktop application/x-extension-xhtml

# Text
xdg-mime default org.kde.kate.desktop text/plain

# Images
xdg-mime default org.kde.gwenview.desktop image/jpeg
xdg-mime default org.kde.gwenview.desktop image/png

# Audio
xdg-mime default org.kde.haruna.desktop audio/flac
xdg-mime default org.kde.haruna.desktop audio/mpeg

# Video
xdg-mime default org.kde.haruna.desktop video/mp4
xdg-mime default org.kde.haruna.desktop video/webm
xdg-mime default org.kde.haruna.desktop video/x-matroska
xdg-mime default org.kde.haruna.desktop video/x-ogm+ogg

# Directories
xdg-mime default org.kde.dolphin.desktop inode/directory

# URL handlers
xdg-mime default brave-browser.desktop x-scheme-handler/http
xdg-mime default brave-browser.desktop x-scheme-handler/https
xdg-mime default brave-browser.desktop x-scheme-handler/about
xdg-mime default brave-browser.desktop x-scheme-handler/unknown
xdg-mime default firefox.desktop x-scheme-handler/chrome

# Custom schemes
xdg-mime default bitwarden.desktop x-scheme-handler/bitwarden
xdg-mime default jetbrains-toolbox.desktop x-scheme-handler/jetbrains
xdg-mime default jetbrains-gateway.desktop x-scheme-handler/jetbrains-gateway
xdg-mime default Logseq.desktop x-scheme-handler/logseq
xdg-mime default Postman.desktop x-scheme-handler/postman
xdg-mime default signal-desktop.desktop x-scheme-handler/sgnl
xdg-mime default signal-desktop.desktop x-scheme-handler/signalcaptcha
