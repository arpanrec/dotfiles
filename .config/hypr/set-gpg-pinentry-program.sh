#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${HOME}/.gnupg"
chmod 700 "${HOME}/.gnupg"
touch "${HOME}/.gnupg/gpg-agent.conf"
chmod 600 "${HOME}/.gnupg/gpg-agent.conf"
sed -i 's/^pinentry-program.*/d' "${HOME}/.gnupg/gpg-agent.conf"
echo 'pinentry-program /usr/bin/pinentry-qt' | tee -a "${HOME}/.gnupg/gpg-agent.conf"
