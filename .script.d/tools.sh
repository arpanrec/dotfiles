#!/usr/bin/env bash
set -ex

if [ "$(id -u)" -eq 0 ]; then
    echo "Root user detected!!!! Error"
    exit 1
fi

install_neovim() {
    echo "Installing Neovim"

    echo "Checking for CPU count"
    CPUCOUNT=$(grep -c "^processor" /proc/cpuinfo)
    echo "CPU count is ${CPUCOUNT}"

    NEOVIM_GIT_CLONE_DIR="${NEOVIM_GIT_CLONE_DIR:-"/tmp/neovim-src-$(date +%s)"}"

    NEOVIM_INSTALL_DIR="${NEOVIM_INSTALL_DIR:-"${HOME}/.local"}"
    NEOVIM_VERSION="${NEOVIM_VERSION:-"v0.9.5"}"
    echo "Neovim version is ${NEOVIM_VERSION}"

    mkdir -p "$(dirname "${NEOVIM_GIT_CLONE_DIR}")"

    echo "Cloning Neovim to ${NEOVIM_GIT_CLONE_DIR}"
    git clone https://github.com/neovim/neovim.git --single-branch \
        --branch="${NEOVIM_VERSION}" --depth 1 "${NEOVIM_GIT_CLONE_DIR}"

    cd "${NEOVIM_GIT_CLONE_DIR}" || exit 1

    rm -rf "${NEOVIM_INSTALL_DIR}/state/nvim"
    rm -rf "${NEOVIM_INSTALL_DIR}/share/nvim"
    rm -rf "${NEOVIM_INSTALL_DIR}/bin/nvim"
    rm -rf "${HOME}/.cache/nvim"

    echo "Building Neovim"
    make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=${NEOVIM_INSTALL_DIR}" -j"${CPUCOUNT}"
    make install

}

echo "Installing Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -q -y

echo "Sourcing cargo env"
# shellcheck source=/dev/null
source "${HOME}/.cargo/env"

declare -a cargo_packages=("ripgrep" "fd-find")

if command -v cargo &>/dev/null; then
    echo "Installing cargo packages"
    for cargo_package in "${cargo_packages[@]}"; do
        echo "Installing cargo package ${cargo_package}"
        cargo install "${cargo_package}"
    done
fi

declare -a npm_packages=("@bitwarden/cli" "neovim" "yarn" "pnpm")
if command -v npm &>/dev/null; then

    # if command -v corepack &>/dev/null; then
    #     echo "enable pnpm and yarn"
    #     corepack enable pnpm yarn
    # fi

    echo "Installing npm packages"
    for npm_package in "${npm_packages[@]}"; do
        echo "Installing npm package globally ${npm_package}"
        npm install -g "${npm_package}"
    done
fi

declare -a go_packages=(
    "golang.org/x/tools/gopls@latest"
    "mvdan.cc/sh/v3/cmd/gosh@latest"
    "github.com/mikefarah/yq/v4@latest"
    "github.com/minio/mc@latest"
    "github.com/jesseduffield/lazygit@latest"
)

if command -v go &>/dev/null; then
    echo "Installing go packages"
    for go_package in "${go_packages[@]}"; do
        echo "Installing go package ${go_package}"
        go install "${go_package}"
    done
fi

install_neovim

exit 0
