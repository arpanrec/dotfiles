#!/usr/bin/env bash
set -euo pipefail

echo "Starting"

echo "Installing Rust"
curl --proto '=https' --tlsv1.2 -sSf --connect-timeout 10 --max-time 300 https://sh.rustup.rs | sh -s -- -y --profile complete --verbose

echo "Setting up Rust environment"

if [[ ! -f "${HOME}/.cargo/env" ]]; then
    echo "Rust environment file not found at ${HOME}/.cargo/env"
    exit 1
fi

# shellcheck source=/dev/null
source "${HOME}/.cargo/env"

rustup update

curl -L --proto '=https' --tlsv1.2 -sSf --connect-timeout 10 --max-time 300 \
    https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

if command -v cargo &>/dev/null; then
    echo "Installing cargo packages"
    echo y | cargo binstall "fd-find" "ripgrep" "uv" --force
fi

echo "Completed"
