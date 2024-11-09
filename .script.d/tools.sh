#!/usr/bin/env bash
set -euo pipefail

log_message() {
    printf "\n\n================================================================================\n %s \
tools: %s\n--------------------------------------------------------------------------------\n\n" "$(date)" "$*"
}

export -f log_message

log_message "Starting"

if [ "$(id -u)" -eq 0 ]; then
    echo "Root user detected!!!! Error"
    exit 1
fi

TOOLS_INSTALL_LOCK_FILE="/tmp/tools-install.lock"
if [ -f "${TOOLS_INSTALL_LOCK_FILE}" ]; then
    log_message "Lock file exists at ${TOOLS_INSTALL_LOCK_FILE}. Exiting"
    exit 1
else
    touch "${TOOLS_INSTALL_LOCK_FILE}"
fi

install_neovim() {
    log_message "Installing Neovim"

    log_message "Checking for CPU count"
    CPUCOUNT=$(grep -c "^processor" /proc/cpuinfo)
    log_message "CPU count is ${CPUCOUNT}"

    NEOVIM_GIT_CLONE_DIR="${NEOVIM_GIT_CLONE_DIR:-"/tmp/neovim-src-$(date +%s)"}"

    NEOVIM_INSTALL_DIR="${NEOVIM_INSTALL_DIR:-"${HOME}/.local"}"
    NEOVIM_VERSION="${NEOVIM_VERSION:-"v0.10.2"}"
    log_message "Creating Neovim directories"
    mkdir -p "$(dirname "${NEOVIM_GIT_CLONE_DIR}")"

    log_message "Cloning Neovim ${NEOVIM_VERSION} to ${NEOVIM_GIT_CLONE_DIR}"
    git clone https://github.com/neovim/neovim.git --single-branch \
        --branch="${NEOVIM_VERSION}" --depth 1 "${NEOVIM_GIT_CLONE_DIR}"

    cd "${NEOVIM_GIT_CLONE_DIR}" || exit 1

    rm -rf "${NEOVIM_INSTALL_DIR}/state/nvim"
    rm -rf "${NEOVIM_INSTALL_DIR}/share/nvim"
    rm -rf "${NEOVIM_INSTALL_DIR}/bin/nvim"
    rm -rf "${HOME}/.cache/nvim"

    log_message "Building Neovim"
    make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=${NEOVIM_INSTALL_DIR}" -j"${CPUCOUNT}"
    make install

}

log_message "Installing Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile complete --verbose

log_message "Setting up Rust environment"
# shellcheck source=/dev/null
source "${HOME}/.cargo/env"

rustup update

declare -a cargo_packages=("ripgrep" "fd-find")

if command -v cargo &>/dev/null; then
    log_message "Installing cargo packages"
    for cargo_package in "${cargo_packages[@]}"; do
        log_message "Installing cargo package ${cargo_package}"
        cargo install "${cargo_package}"
    done
fi

declare -a npm_packages=("@bitwarden/cli" "neovim" "yarn" "pnpm")
if command -v npm &>/dev/null; then

    # if command -v corepack &>/dev/null; then
    #     echo "enable pnpm and yarn"
    #     corepack enable pnpm yarn
    # fi

    log_message "Installing npm packages"
    for npm_package in "${npm_packages[@]}"; do
        log_message "Installing npm package ${npm_package}"
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
    log_message "Installing go packages"
    for go_package in "${go_packages[@]}"; do
        log_message "Installing go package ${go_package}"
        go install "${go_package}"
    done
fi

install_neovim

log_message "Removing lock file at ${TOOLS_INSTALL_LOCK_FILE}"
rm -f "${TOOLS_INSTALL_LOCK_FILE}"

log_message "Completed"
