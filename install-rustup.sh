#!/usr/bin/env bash
set -euo pipefail

echo "Starting"

echo "Installing Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile complete --verbose

echo "Setting up Rust environment"

# shellcheck source=/dev/null
source "${HOME}/.cargo/env"

rustup update

curl -L --proto '=https' --tlsv1.2 -sSf \
    https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

if command -v cargo &>/dev/null; then
    echo "Installing cargo packages"
    echo y | cargo binstall "fd-find" "ripgrep" "uv" --force
fi

echo "Completed"
