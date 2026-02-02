#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${HOME}/.gnupg"
chmod 700 "${HOME}/.gnupg"
touch "${HOME}/.gnupg/gpg-agent.conf"
chmod 600 "${HOME}/.gnupg/gpg-agent.conf"
if [[ -f /usr/bin/pinentry-qt ]]; then
    sed -i 's/^pinentry-program.*/pinentry-program \/usr\/bin\/pinentry-qt/' "${HOME}/.gnupg/gpg-agent.conf"
fi
