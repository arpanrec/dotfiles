#!/usr/bin/env bash
set -e

# Check if git is installed
if ! command -v git &>/dev/null; then
    echo "git could not be found"
    exit
fi

# Check if jq is installed
if ! command -v jq &>/dev/null; then
    echo "jq could not be found"
    exit
fi

__dotfiles_directory="${HOME}/.dotfiles"
__dotfiles_repo="arpanrec/dotfiles"
__dotfiles_git_ssh_remote="git@github.com:${__dotfiles_repo}.git"
__dotfiles_git_https_remote="https://github.com/${__dotfiles_repo}.git"
__dotfiles_git_remote="${__dotfiles_git_https_remote}"

echo "GitHub repository: ${__dotfiles_repo}"
echo "Dotfiles directory: ${__dotfiles_directory}"

## Remote selection
read -r -n1 -p "Current remote is HTTPS: ${__dotfiles_git_https_remote}, Want to use SSH: ${__dotfiles_git_ssh_remote}? (default: N) [y/N]: " __dotfiles_decision_if_change_remote_ssh
echo ""

if [[ "${__dotfiles_decision_if_change_remote_ssh}" == "y" ]]; then
    __dotfiles_git_remote="${__dotfiles_git_ssh_remote}"
fi

echo "Selected remote: ${__dotfiles_git_remote}"

## Branch selection
echo "Fetching default branch"
__dotfiles_git_branch=$(curl -sL \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/${__dotfiles_repo}" | jq -r '.default_branch')
echo "Current branch is: ${__dotfiles_git_branch}"

echo "Fetching available branches"
__dotfiles_available_branches=$(curl -sL \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/${__dotfiles_repo}/branches" | jq -r '.[].name')
printf "Available branches: \n\n%s\n\n" "${__dotfiles_available_branches}"

read -r -n1 -p "Want change the current branch? (default: N) [y/N]: " __dotfiles_decision_if_change_branch
echo ""

if [[ "${__dotfiles_decision_if_change_branch}" == "y" ]]; then
    echo "Enter the branch number followed by enter key"
    select __dotfiles_git_branch in ${__dotfiles_available_branches}; do
        break
    done

    if [[ -z "${__dotfiles_git_branch}" ]]; then
        echo "No branch selected, exiting"
        exit 1
    fi
fi

echo "Selected branch: ${__dotfiles_git_branch}"

## Dotfiles directory
# read -r -p "Enter the dotfiles directory (default: ~/.dotfiles): " __dotfiles_directory
# echo ""

# if [[ -z "${__dotfiles_directory}" ]]; then
#     __dotfiles_directory="${HOME}/.dotfiles"
# fi

# echo "Selected dotfiles directory: ${__dotfiles_directory}"

## Reset all dotfiles
read -r -n1 -p 'Reset all dotfiles? (default: N) [y/N]: ' __dotfiles_decision_if_reset
echo ""

if [[ "${__dotfiles_decision_if_reset}" == "y" ]]; then
    echo "Resetting all dotfiles"
    rm -rf "${__dotfiles_directory}"
fi

__doconfig="git --git-dir=${__dotfiles_directory} --work-tree=${HOME}"

## Check if repo is already cloned
if [[ ! -d "${__dotfiles_directory}" ]]; then
    echo "Cloning dotfiles"
    git clone --bare "${__dotfiles_git_remote}" "${__dotfiles_directory}" --branch "${__dotfiles_git_branch}"
    ${__doconfig} config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

    echo "Fetching all branches"
    ${__doconfig} fetch --all

    echo "Setting upstream to origin/${__dotfiles_git_branch}"
    ${__doconfig} branch --set-upstream-to=origin/"${__dotfiles_git_branch}" "${__dotfiles_git_branch}"
else

    echo "Repository already cloned in ${__dotfiles_directory}"

    __dotfiles_current_remote=$(${__doconfig} remote get-url origin)

    if [[ "${__dotfiles_current_remote}" != "${__dotfiles_git_remote}" ]]; then
        echo "Current remote is ${__dotfiles_current_remote}, changing to ${__dotfiles_git_remote}"
        ${__doconfig} remote set-url origin "${__dotfiles_git_remote}"
    else
        echo "Current remote is already ${__dotfiles_git_remote}"
    fi

    echo "Setting remote origin fetch to +refs/heads/*:refs/remotes/origin/*"
    ${__doconfig} config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

    echo "Fetching all branches and pruning"
    ${__doconfig} fetch --all --prune

    ## Change branch if required
    __dotfiles_current_branch=$(${__doconfig} branch --show-current)

    if [[ "${__dotfiles_current_branch}" != "${__dotfiles_git_branch}" ]]; then
        echo "Current branch is ${__dotfiles_current_branch}, changing to ${__dotfiles_git_branch}"
        __dotfiles_stash_name=$(date +%s)
        echo "Stashing changes with message: ${__dotfiles_stash_name}"
        ${__doconfig} stash push -m "${__dotfiles_stash_name}"
        ${__doconfig} checkout "${__dotfiles_git_branch}"
    else
        echo "Current branch is already ${__dotfiles_git_branch}"
    fi

    echo "Setting upstream to origin/${__dotfiles_git_branch}"
    ${__doconfig} branch --set-upstream-to=origin/"${__dotfiles_git_branch}" "${__dotfiles_git_branch}"

fi

## Set status.showUntrackedFiles to no
echo "Setting status.showUntrackedFiles to no"
${__doconfig} config --local status.showUntrackedFiles no

## Add alias to rc files
echo "alias dotfiles='git --git-dir=${__dotfiles_directory} --work-tree=${HOME}'" >>"${HOME}/.bashrc"
echo "alias dotfiles='git --git-dir=${__dotfiles_directory} --work-tree=${HOME}'" >>"${HOME}/.zshrc"
echo "alias dotfiles='git --git-dir=${__dotfiles_directory} --work-tree=${HOME}'" >>"${HOME}/.aliasrc"

## Check status
${__doconfig} status
