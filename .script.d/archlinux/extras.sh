#!/usr/bin/env bash
set -e

pack_extars+=(
  'gsfonts' 'apparmor' 'xsane' 'imagescan'
  'python-pysmbc'
)
pack_extars+=('libotr')
pack_extars+=('xclip' 'xsel' 'wl-clipboard')
pack_extars+=('htop' 'neofetch' 'screenfetch' 'bashtop' 'bpytop' 'mlocate' 'inetutils' 'net-tools')
pack_extars+=('discord' 'gimp' 'gnuplot' 'sysstat')

# These are neeeded for icaclient
# libc++abi This is also required, part of libc++
pack_extars+=('libc++' 'libidn11' 'libjpeg6-turbo' 'libpng12' 'libxp')
pacman -S --needed --noconfirm "${pack_extars[@]}"
