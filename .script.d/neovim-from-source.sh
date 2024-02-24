#!/usr/bin/env bash
set -ex

NEOVIM_GIT_CLONE_DIR="${NEOVIM_GIT_CLONE_DIR:-"/tmp/neovim-src-$(date +%s)"}"
NEOVIM_INSTALL_DIR="${NEOVIM_INSTALL_DIR:-"${HOME}/.local"}"

neovim_install() {

    rm -rf "${HOME}/.local/bin/nvim*"
    rm -rf "${HOME}/.local/state/nvim*"
    rm -rf "${HOME}/.local/share/nvim*"
    rm -rf "${HOME}/.cache/nvim*"
    rm -rf "${HOME}/.local/lib/nvim*"
    rm -rf "${HOME}/.local/neovim*"

    make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=${NEOVIM_INSTALL_DIR}"
    make install
}

mkdir -p "$(dirname "${NEOVIM_GIT_CLONE_DIR}")"
git clone https://github.com/neovim/neovim.git --single-branch --branch=stable --depth 1 "${NEOVIM_GIT_CLONE_DIR}"

cd "${NEOVIM_GIT_CLONE_DIR}"
neovim_install
