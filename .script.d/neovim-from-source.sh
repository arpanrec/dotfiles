#!/usr/bin/env bash
set -ex

NEOVIM_GIT_CLONE_DIR="${NEOVIM_GIT_CLONE_DIR:-"/tmp/neovim-source/$(date +%s)"}"
NEOVIM_INSTALL_DIR="${NEOVIM_INSTALL_DIR:-"${HOME}/.local"}"

neovim_install() {
    pwd
    make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=${NEOVIM_INSTALL_DIR}"
    make install
}

git clone https://github.com/neovim/neovim.git --single-branch --branch=stable --depth 1 "${NEOVIM_GIT_CLONE_DIR}"

cd "${NEOVIM_GIT_CLONE_DIR}"
neovim_install
