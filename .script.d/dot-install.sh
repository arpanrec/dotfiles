#!/usr/bin/env bash
set -euo pipefail

git_remote_url="https://github.com/arpanrec/dotfiles.git"

if [ -f "${HOME}/.ssh/github.com" ]; then
    git_remote_url="git@github.com:arpanrec/dotfiles.git"
fi

rm -rf "${HOME}/.dotfiles"
git clone --bare "${git_remote_url}" "${HOME}/.dotfiles"
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" config --local status.showUntrackedFiles no
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" checkout main --force
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" config \
    --local remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
