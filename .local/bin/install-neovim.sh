#!/usr/bin/env bash
set -euo pipefail

required_cmds=(
    curl
    git
    unzip
    ninja
    cmake
    gcc
    gettext
)

for cmd in "${required_cmds[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Required command '$cmd' is not installed or not in PATH"
        exit 1
    fi
done

echo "Starting"

if [ "$(id -u)" -eq 0 ]; then
    echo "Root user detected!!!! Error"
    exit 1
fi

echo "Installing Neovim"

echo "Checking for CPU count"
CPUCOUNT=$(grep -c "^processor" /proc/cpuinfo)
echo "CPU count is ${CPUCOUNT}"

NEOVIM_GIT_CLONE_DIR="${NEOVIM_GIT_CLONE_DIR:-"/tmp/neovim-src-$(date +%s)"}"

NEOVIM_INSTALL_DIR="${NEOVIM_INSTALL_DIR:-"${HOME}/.local"}"
NEOVIM_VERSION="${NEOVIM_VERSION:-"v0.11.4"}"
echo "Creating Neovim directories"
mkdir -p "$(dirname "${NEOVIM_GIT_CLONE_DIR}")"

echo "Cloning Neovim ${NEOVIM_VERSION} to ${NEOVIM_GIT_CLONE_DIR}"
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

echo "Completed"
