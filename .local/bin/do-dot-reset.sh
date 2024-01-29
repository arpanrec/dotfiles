#!/usr/bin/env bash
set -ex

__dotfiles_repo="arpanrec/dotfiles"
__dotfiles_git_ssh_remote="git@github.com:${__dotfiles_repo}.git"
__dotfiles_git_https_remote="https://github.com/${__dotfiles_repo}.git"
__dotfiles_git_remote="${__dotfiles_git_https_remote}"
__dotfiles_git_branch="main"
__dotfiles_dir="${HOME}/.dotfiles"

# ask user for http or ssh and save in __dotfiles_git_remote_user

read -r -n1 -p "Use SSH remote ${__dotfiles_git_ssh_remote}? (default: HTTPS: ${__dotfiles_git_https_remote}) [y/N]: " __dotfiles_git_remote_user

if [[ "${__dotfiles_git_remote_user}" == "y" ]]; then
    __dotfiles_git_remote="${__dotfiles_git_ssh_remote}"
fi

echo "Configuring dotfiles"
echo "Repo: ${__dotfiles_repo}"
echo "Remote: ${__dotfiles_git_remote}"
echo "Branch: ${__dotfiles_git_branch}"
echo "Dir: ${__dotfiles_dir}"

# ask user for total reset

read -r -n1 -p 'Reset all dotfiles? (default: no) [y/N]: ' __dotfiles_reset

if [[ "${__dotfiles_reset}" == "y" ]]; then
    echo "Resetting all dotfiles"
    rm -rf "${__dotfiles_dir}"
fi

# Check if git is installed
if ! command -v git &>/dev/null; then
    echo "git could not be found"
    exit
fi

# Check if repo is already cloned

if [[ ! -d "${__dotfiles_dir}" ]]; then
    echo "Cloning dotfiles repo"
    git clone --bare "${__dotfiles_git_remote}" "${__dotfiles_dir}"
fi

git --git-dir="${__dotfiles_dir}" --work-tree="${HOME}" set-url origin "${__dotfiles_git_remote}"
git --git-dir="${__dotfiles_dir}" --work-tree="${HOME}" config --local status.showUntrackedFiles no
echo "alias config='git --git-dir=${__dotfiles_dir} --work-tree=${HOME}'" >>"${HOME}/.bashrc"
echo "alias config='git --git-dir=${__dotfiles_dir} --work-tree=${HOME}'" >>"${HOME}/.zshrc"
echo "alias config='git --git-dir=${__dotfiles_dir} --work-tree=${HOME}'" >>"${HOME}/.aliasrc"
git --git-dir="${__dotfiles_dir}" --work-tree="${HOME}" status
