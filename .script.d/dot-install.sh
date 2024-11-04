#!/usr/bin/env bash
set -euo pipefail

if [[ "$(id -u)" -eq 0 || "${HOME}" == "/root" ]]; then
    if [[ ! -t 1 ]]; then
        printf "\n\n================================================================================\n"
        echo "$(date) dot-install: Script is not running in interactive mode. Exiting."
        echo "--------------------------------------------------------------------------------"
        exit 1
    fi
    printf "\n\n================================================================================\n"
    echo "$(date) dot-install: Root user detected, You are mad to run this script as root!"
    echo "$(date) dot-install: If you really know your shit then press 'y' to continue"
    echo "$(date) dot-install: But you are going to regret it!"
    echo "--------------------------------------------------------------------------------"
    read -r -p "Are you sure you want to continue? [y/N] " response_root_user
    if [[ ! "$response_root_user" =~ ^([yY])$ ]]; then
        printf "\n\n================================================================================\n"
        echo "$(date) dot-install: Exiting script as root user detected"
        echo "--------------------------------------------------------------------------------"
        exit 1
    fi
    printf "\n\n================================================================================\n"
    echo "$(date) dot-install: Holy fuck, you went there, i am gonna give you 5 second to think it through"
    echo "--------------------------------------------------------------------------------"
    for i in {5..1}; do
        echo "$(date) dot-install: $i..."
        sleep 1
    done
fi

dotfiles_git_remote="https://github.com/arpanrec/dotfiles.git"
dotfiles_dir="${HOME}/.dotfiles"

printf "\n\n================================================================================\n"
echo "$(date) dot-install: Installing dotfiles from ${dotfiles_git_remote} to ${dotfiles_dir}"
echo "--------------------------------------------------------------------------------"

if [ -f "${HOME}/.ssh/github.com" ]; then
    dotfiles_git_remote="git@github.com:arpanrec/dotfiles.git"
    printf "\n\n================================================================================\n"
    echo "$(date) dot-install: Using SSH key for GitHub at ${HOME}/.ssh/github.com and changing remote URL to ${dotfiles_git_remote}"
    echo "--------------------------------------------------------------------------------"
fi

printf "\n\n================================================================================\n"
echo "$(date) dot-install: Removing existing dotfiles directory at ${dotfiles_dir}"
echo "--------------------------------------------------------------------------------"
rm -rf "${HOME}/.dotfiles"

printf "\n\n================================================================================\n"
echo "$(date) dot-install: Cloning dotfiles from ${dotfiles_git_remote} to ${dotfiles_dir} as a bare repository"
echo "--------------------------------------------------------------------------------"
git clone --bare "${dotfiles_git_remote}" "${HOME}/.dotfiles"

printf "\n\n================================================================================\n"
echo "$(date) dot-install: Setting status.showUntrackedFiles to no"
echo "--------------------------------------------------------------------------------"
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" config --local status.showUntrackedFiles no

printf "\n\n================================================================================\n"
echo "$(date) dot-install: Checking out main branch with force"
echo "--------------------------------------------------------------------------------"
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" checkout main --force

printf "\n\n================================================================================\n"
echo "$(date) dot-install: Adding remote origin with fetch refspec"
echo "--------------------------------------------------------------------------------"
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" config \
    --local remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
