#!/usr/bin/env bash
set -euo pipefail

dotfiles_git_remote="https://github.com/arpanrec/dotfiles.git"
dotfiles_dir="${HOME}/.dotfiles"

printf "\n\n================================================================================\n"
echo "Installing dotfiles from ${dotfiles_git_remote}"
echo "--------------------------------------------------------------------------------"

if [ -f "${HOME}/.ssh/github.com" ]; then
    dotfiles_git_remote="git@github.com:arpanrec/dotfiles.git"
    printf "\n\n================================================================================\n"
    echo "Using SSH key for GitHub at ${HOME}/.ssh/github.com and changing remote URL to ${dotfiles_git_remote}"
    echo "--------------------------------------------------------------------------------"
fi

printf "\n\n================================================================================\n"
echo "Removing existing dotfiles directory at ${dotfiles_dir}"
echo "--------------------------------------------------------------------------------"
rm -rf "${HOME}/.dotfiles"

printf "\n\n================================================================================\n"
echo "Cloning dotfiles from ${dotfiles_git_remote} to ${dotfiles_dir} as a bare repository"
echo "--------------------------------------------------------------------------------"
git clone --bare "${dotfiles_git_remote}" "${HOME}/.dotfiles"

printf "\n\n================================================================================\n"
echo "Setting status.showUntrackedFiles to no"
echo "--------------------------------------------------------------------------------"
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" config --local status.showUntrackedFiles no

printf "\n\n================================================================================\n"
echo "Checking out main branch with force"
echo "--------------------------------------------------------------------------------"
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" checkout main --force

printf "\n\n================================================================================\n"
echo "Adding remote origin with fetch refspec"
echo "--------------------------------------------------------------------------------"
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" config \
    --local remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
