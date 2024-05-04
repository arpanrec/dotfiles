#!/usr/bin/env bash
set -ex

NEOVIM_GIT_CLONE_DIR="${NEOVIM_GIT_CLONE_DIR:-"/tmp/neovim-src-$(date +%s)"}"

if [ "$(id -u)" -eq 0 ]; then
    export NEOVIM_INSTALL_DIR=${NEOVIM_INSTALL_DIR:-"/usr/local"}
fi

NEOVIM_INSTALL_DIR="${NEOVIM_INSTALL_DIR:-"${HOME}/.local"}"
NEOVIM_VERSION="${NEOVIM_VERSION:-"v0.9.5"}"

mkdir -p "$(dirname "${NEOVIM_GIT_CLONE_DIR}")"
git clone https://github.com/neovim/neovim.git --single-branch \
    --branch="${NEOVIM_VERSION}" --depth 1 "${NEOVIM_GIT_CLONE_DIR}"

cd "${NEOVIM_GIT_CLONE_DIR}"

rm -rf "${NEOVIM_INSTALL_DIR}/state/nvim"
rm -rf "${NEOVIM_INSTALL_DIR}/share/nvim"
rm -rf "${NEOVIM_INSTALL_DIR}/bin/nvim"
rm -rf "${HOME}/.cache/nvim"

make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=${NEOVIM_INSTALL_DIR}"
make install
