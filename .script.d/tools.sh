#!/usr/bin/env bash
set -ex

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -q -y

# shellcheck source=/dev/null
source "$HOME/.cargo/env"
cargo install cargo-binstall
cargo install cargo-quickinstall
cargo install cargo-update
cargo install ripgrep

curl -sSL https://install.python-poetry.org | python3 -

npm i -g yarn
npm i -g bw

go install golang.org/x/tools/gopls@latest
go install mvdan.cc/sh/v3/cmd/gosh@latest

"${HOME}/.script.d/neovim-from-source.sh"
