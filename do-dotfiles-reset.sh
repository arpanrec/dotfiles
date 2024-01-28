#!/usr/bin/env bash
set -ex

__dotfiles_repo="arpanrec/dotfiles"
__dotfiles_git_ssh_remote="git@github.com:${__dotfiles_repo}.git"
__dotfiles_git_https_remote="https://github.com/${__dotfiles_repo}.git"
__dotfiles_git_remote="${__dotfiles_git_https_remote}"
__dotfiles_git_branch="main"
__dotfiles_dir="${HOME}/.dotfiles"

echo "Configuring dotfiles"
echo "Repo: ${__dotfiles_repo}"
echo "Remote: ${__dotfiles_git_remote}"
echo "Branch: ${__dotfiles_git_branch}"
echo "Dir: ${__dotfiles_dir}"

echo "Reset: $1"

__dotfiles_reset=false
if [[ $# -gt 0 ]]; then
    if [[ "$1" == "reset" ]]; then
        __dotfiles_reset=true
    fi
fi

if [[ "${__dotfiles_reset}" == true ]]; then
    echo "Resetting dotfiles"
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

git --git-dir="${__dotfiles_dir}" --work-tree="${HOME}" config --local status.showUntrackedFiles no
echo "alias config='git --git-dir=${__dotfiles_dir} --work-tree=${HOME}'" >>"${HOME}/.bashrc"
echo "alias config='git --git-dir=${__dotfiles_dir} --work-tree=${HOME}'" >>"${HOME}/.zshrc"
echo "alias config='git --git-dir=${__dotfiles_dir} --work-tree=${HOME}'" >>"${HOME}/.aliasrc"
git --git-dir="${__dotfiles_dir}" --work-tree="${HOME}" status
