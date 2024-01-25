#!/usr/bin/env bash
set -e

rm -rf ~/yay
git clone "https://aur.archlinux.org/yay.git" ~/yay --depth=1
cd "${HOME}/yay"
makepkg -si --noconfirm
