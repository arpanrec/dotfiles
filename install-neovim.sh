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
    yarn
    jq
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

# https://github.com/neovim/neovim/blob/master/BUILD.md
# https://github.com/neovim/neovim/blob/master/INSTALL.md

echo "Installing Neovim"

echo "Checking for CPU count"
CPUCOUNT=$(grep -c "^processor" /proc/cpuinfo)
echo "CPU count is ${CPUCOUNT}"

NEOVIM_VERSION="$(curl -s \
    "https://api.github.com/repos/neovim/neovim/releases/latest" |
    jq -r ".tag_name")"

TMP_DOWNLOAD_DIRECTORY="${HOME}/.tmp/from_dotfiles_bin"

NEOVIM_GIT_CLONE_DIR="${TMP_DOWNLOAD_DIRECTORY}/neovim-src-${NEOVIM_VERSION}"

NEOVIM_INSTALL_DIR="${NEOVIM_INSTALL_DIR:-"${HOME}/.local"}"
NVIM_APPNAME="${NVIM_APPNAME:-nvim}"

if [[ ! -d "${NEOVIM_GIT_CLONE_DIR}" ]]; then
    echo "Cloning Neovim ${NEOVIM_VERSION} to ${NEOVIM_GIT_CLONE_DIR}"
    git clone https://github.com/neovim/neovim.git --single-branch \
        --branch="${NEOVIM_VERSION}" --depth 1 "${NEOVIM_GIT_CLONE_DIR}"
fi

cd "${NEOVIM_GIT_CLONE_DIR}" || exit 1

git reset --hard HEAD
git clean -fd

rm -rf "${NEOVIM_INSTALL_DIR}/state/${NVIM_APPNAME}" \
    "${NEOVIM_INSTALL_DIR}/share/${NVIM_APPNAME}" \
    "${NEOVIM_INSTALL_DIR}/bin/nvim" \
    "${HOME}/.cache/${NVIM_APPNAME}"

echo "Building Neovim"
make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=${NEOVIM_INSTALL_DIR}" -j"${CPUCOUNT}"
make install

echo "Completed"
