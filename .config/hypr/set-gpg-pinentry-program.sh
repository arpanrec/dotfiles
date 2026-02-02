#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${HOME}/.gnupg"

if [[ -f /usr/bin/pinentry-qt ]]; then
    sed -i 's/^pinentry-program.*/pinentry-program \/usr\/bin\/pinentry-qt/' "${HOME}/.gnupg/gpg-agent.conf"
fi
