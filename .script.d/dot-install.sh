#!/usr/bin/env bash
set -euo pipefail

log_message() {
    printf "\n\n================================================================================\n %s \
dot-install: %s\n--------------------------------------------------------------------------------\n" "$(date)" "$*"
}

export -f log_message

if [[ "$(id -u)" -eq 0 || "${HOME}" == "/root" ]]; then
    if [[ ! -t 1 ]]; then

        log_message "Script is not running in interactive mode. Exiting."
        exit 1
    fi

    log_message "Root user detected, You are mad to run this script as root! If you really know your shit then \
press 'y' to continue But you are going to regret it!"
    read -r -p "Are you sure you want to continue? [y/N] " response_root_user
    if [[ ! "${response_root_user}" =~ ^([yY])$ ]]; then

        log_message "Exiting script as root user detected"
        exit 1
    fi

    log_message "Holy fuck, you went there, i am gonna give you 5 second to think it through"
    for i in {5..1}; do
        log_message "$i..."
        sleep 1
    done
fi

dotfiles_git_remote="https://github.com/arpanrec/dotfiles.git"
dotfiles_dir="${HOME}/.dotfiles"

log_message "Installing dotfiles from ${dotfiles_git_remote} to ${dotfiles_dir}"

if [ -f "${HOME}/.ssh/github.com" ]; then
    dotfiles_git_remote="git@github.com:arpanrec/dotfiles.git"

    log_message "Using SSH key for GitHub at ${HOME}/.ssh/github.com and changing remote URL to ${dotfiles_git_remote}"
fi

log_message "Removing existing dotfiles directory at ${dotfiles_dir}"
rm -rf "${HOME}/.dotfiles"

log_message "Cloning dotfiles from ${dotfiles_git_remote} to ${dotfiles_dir} as a bare repository"
git clone --bare "${dotfiles_git_remote}" "${HOME}/.dotfiles"

log_message "Setting status.showUntrackedFiles to no"
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" config --local status.showUntrackedFiles no

log_message "Checking out main branch with force"
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" checkout main --force

log_message "Adding remote origin with fetch refspec"
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" config \
    --local remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
