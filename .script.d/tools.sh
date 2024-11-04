#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    echo "Root user detected!!!! Error"
    exit 1
fi

install_neovim() {
    printf "\n\n================================================================================\n"
    echo "tools: Installing Neovim"
    echo "--------------------------------------------------------------------------------"

    printf "\n\n================================================================================\n"
    echo "tools: Checking for CPU count"
    echo "--------------------------------------------------------------------------------"
    CPUCOUNT=$(grep -c "^processor" /proc/cpuinfo)
    printf "\n\n================================================================================\n"
    echo "tools: CPU count is ${CPUCOUNT}"
    echo "--------------------------------------------------------------------------------"

    NEOVIM_GIT_CLONE_DIR="${NEOVIM_GIT_CLONE_DIR:-"/tmp/neovim-src-$(date +%s)"}"

    NEOVIM_INSTALL_DIR="${NEOVIM_INSTALL_DIR:-"${HOME}/.local"}"
    NEOVIM_VERSION="${NEOVIM_VERSION:-"v0.10.2"}"
    printf "\n\n================================================================================\n"
    echo "tools: Creating Neovim directories"
    echo "--------------------------------------------------------------------------------"
    mkdir -p "$(dirname "${NEOVIM_GIT_CLONE_DIR}")"

    printf "\n\n================================================================================\n"
    echo "tools: Cloning Neovim ${NEOVIM_VERSION} to ${NEOVIM_GIT_CLONE_DIR}"
    echo "--------------------------------------------------------------------------------"
    git clone https://github.com/neovim/neovim.git --single-branch \
        --branch="${NEOVIM_VERSION}" --depth 1 "${NEOVIM_GIT_CLONE_DIR}"

    cd "${NEOVIM_GIT_CLONE_DIR}" || exit 1

    rm -rf "${NEOVIM_INSTALL_DIR}/state/nvim"
    rm -rf "${NEOVIM_INSTALL_DIR}/share/nvim"
    rm -rf "${NEOVIM_INSTALL_DIR}/bin/nvim"
    rm -rf "${HOME}/.cache/nvim"

    printf "\n\n================================================================================\n"
    echo "tools: Building Neovim"
    echo "--------------------------------------------------------------------------------"
    make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=${NEOVIM_INSTALL_DIR}" -j"${CPUCOUNT}"
    make install

}

printf "\n\n================================================================================\n"
echo "tools: Installing Rust"
echo "--------------------------------------------------------------------------------"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile complete --verbose

printf "\n\n================================================================================\n"
echo "tools: Setting up Rust environment"
echo "--------------------------------------------------------------------------------"
# shellcheck source=/dev/null
source "${HOME}/.cargo/env"

rustup update

declare -a cargo_packages=("ripgrep" "fd-find")

if command -v cargo &>/dev/null; then
    printf "\n\n================================================================================\n"
    echo "tools: Installing cargo packages"
    echo "--------------------------------------------------------------------------------"
    for cargo_package in "${cargo_packages[@]}"; do
        printf "\n\n================================================================================\n"
        echo "tools: Installing cargo package ${cargo_package}"
        echo "--------------------------------------------------------------------------------"
        cargo install "${cargo_package}"
    done
fi

declare -a npm_packages=("@bitwarden/cli" "neovim" "yarn" "pnpm")
if command -v npm &>/dev/null; then

    # if command -v corepack &>/dev/null; then
    #     echo "enable pnpm and yarn"
    #     corepack enable pnpm yarn
    # fi

    printf "\n\n================================================================================\n"
    echo "tools: Installing npm packages"
    echo "--------------------------------------------------------------------------------"
    for npm_package in "${npm_packages[@]}"; do
        printf "\n\n================================================================================\n"
        echo "tools: Installing npm package ${npm_package}"
        echo "--------------------------------------------------------------------------------"
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
    printf "\n\n================================================================================\n"
    echo "tools: Installing go packages"
    echo "--------------------------------------------------------------------------------"
    for go_package in "${go_packages[@]}"; do
        printf "\n\n================================================================================\n"
        echo "tools: Installing go package ${go_package}"
        echo "--------------------------------------------------------------------------------"
        go install "${go_package}"
    done
fi

install_neovim

exit 0
