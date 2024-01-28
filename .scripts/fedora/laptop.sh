#!/usr/bin/env bash
set -ex
sudo dnf remove -y xorg-x11-drv-nouveau

sudo dnf install -y nvidia-settings akmod-nvidia xorg-x11-drv-nvidia-cuda gwe
sudo dnf install -y steam
