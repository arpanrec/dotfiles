#!/usr/bin/env bash
set -ex

install_neovim() {

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

}

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -q -y

# shellcheck source=/dev/null
source "$HOME/.cargo/env"
cargo install ripgrep
cargo install fd-find

curl -sSL https://install.python-poetry.org | python3 -

npm i -g yarn
npm i -g bw
npm i -g neovim

go install golang.org/x/tools/gopls@latest
go install mvdan.cc/sh/v3/cmd/gosh@latest
go install github.com/mikefarah/yq/v4@latest
go install github.com/minio/mc@latest

curl -fsSL https://get.pulumi.com | sh

install_neovim
