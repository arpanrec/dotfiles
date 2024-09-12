#!/usr/bin/env bash
set -euo pipefail
rm -rf "${HOME}/.dotfiles"
git clone --bare https://github.com/arpanrec/dotfiles.git "${HOME}/.dotfiles"
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" config --local status.showUntrackedFiles no
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" checkout main --force
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" config \
    --local remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
