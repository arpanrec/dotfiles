#!/usr/bin/env bash
set -ex

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

"${HOME}/.script.d/neovim-from-source.sh"
