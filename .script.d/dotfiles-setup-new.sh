#!/usr/bin/env bash
set -euo pipefail

export DOTFILES_DIR="${DOTFILES_DIR:-}"
export DOTFILES_GIT_REPO="${DOTFILES_GIT_REPO:-}"
export DOTFILES_CLEAN_INSTALL="${DOTFILES_CLEAN_INSTALL:-}"
export DOTFILES_BRANCH="${DOTFILES_BRANCH:-}"
export DOTFILES_SILENT_INSTALL="${DOTFILES_SILENT_INSTALL:-}"

help() {
    cat <<EOF
Setup dotfiles sync with git for new systems.

Usage:

    dotfiles-setup-new.sh [OPTIONS] install_dotfiles

    Environment variables can be used to set default values.

    -o Path
            Dotfiles directory.
            ENV: DOTFILES_DIR
            Example:
                    "-o /home/user/.dotfiles"
                    "export DOTFILES_DIR=/home/user/.dotfiles"

    -r URL
            Dotfiles git repository.
            ENV: DOTFILES_GIT_REPO
            Example:
                    "-r https://github.com/arpanrec/dotfiles.git"
                    "-r git@github.com:arpanrec/dotfiles.git"
                    "export DOTFILES_GIT_REPO=git@github.com:arpanrec/dotfiles.git"

    -b Branch
            Dotfiles git repository branch.
            Default: Curent branch or default branch of the repository. if '-c' is passed, default branch will be used.
            ENV: DOTFILES_BRANCH
            Example:
                    "-b main"
                    "export DOTFILES_BRANCH=main"

    -c
            If -c is passed, the script will remove the existing dotfiles directory.
            ENV: DOTFILES_CLEAN_INSTALL
            Example:
                    "-c"
                    "export DOTFILES_CLEAN_INSTALL=true"

    -s
            If -s is passed, the script will not prompt for any input.
            ENV: DOTFILES_SILENT_INSTALL
            Example:
                    "-s"
                    "export DOTFILES_SILENT_INSTALL=true"

    -h Show this help message.
EOF
}

read_dotfiles_directory() {
    echo "Enter the dotfiles directory (default: ${HOME}/.dotfiles)"
    read -r -p "Press enter to use default: " dotfiles_directory_input
    if [[ -n "${dotfiles_directory_input}" ]]; then
        export DOTFILES_DIR="${dotfiles_directory_input}"
    else
        export DOTFILES_DIR="${HOME}/.dotfiles"
    fi
}

read_gitrepo_from_user() {

    git_protocol="https"
    git_remote_host="github.com"
    git_repo_path="arpanrec/dotfiles"
    ssh_git_user="git"

    read -r -n1 -p "Use ssh remote? Current remote protocol is ${git_protocol}. (default: N) [y/N]: " \
        decision_if_change_remote_ssh
    echo ""
    if [[ "${decision_if_change_remote_ssh}" == "y" ]]; then
        git_protocol="ssh"
    fi

    echo "Enter the git remote host (default: ${git_remote_host})"
    echo "Example: github.com, gitlab.com, example.com:22, gitea.com:8080"
    read -r -p "Press enter to use default: " git_remote_host_input
    if [[ -n "${git_remote_host_input}" ]]; then
        git_remote_host="${git_remote_host_input}"
    fi

    echo "Enter the git repository path (default: ${git_repo_path})"
    echo "Example: arpanrec/dotfiles, user/dotfiles, gl_group/subgroup/dotfiles"
    read -r -p "Press enter to use default: " git_repo_path_input
    if [[ -n "${git_repo_path_input}" ]]; then
        git_repo_path="${git_repo_path_input}"
    fi

    if [[ "${git_protocol}" == "ssh" ]]; then

        echo "Enter the ssh git user (default: ${ssh_git_user})"
        read -r -p "Press enter to use default: " ssh_git_user_input
        if [[ -n "${ssh_git_user_input}" ]]; then
            ssh_git_user="${ssh_git_user_input}"
        fi

        export DOTFILES_GIT_REPO="${ssh_git_user}@${git_remote_host}:${git_repo_path}.git"
    else
        export DOTFILES_GIT_REPO="${git_protocol}://${git_remote_host}/${git_repo_path}.git"
    fi

    echo "Selected git repository: ${DOTFILES_GIT_REPO}"

}

check_existing_branch() {
    if [[ -d "${DOTFILES_DIR}" ]]; then
        if branch_name=$(git --git-dir "${DOTFILES_DIR}" rev-parse --abbrev-ref HEAD); then
            echo "${branch_name}"
        else
            exit 1
        fi
    fi
}

get_preferred_branch() {
    existing_branch=$(check_existing_branch)
    if [[ -z "${existing_branch}" ]]; then
        if default_branch=$(git ls-remote --symref "${DOTFILES_GIT_REPO}" HEAD |
            awk '{print $2}' | sed 's/refs\/heads\///g' | head -1); then
            echo "${default_branch}"
        else
            exit 1
        fi
    else
        echo "${existing_branch}"
    fi
}

read_branch_from_user() {
    preferred_branch=$(get_preferred_branch)
    echo "Preferred branch is: ${preferred_branch}"
    read -r -p "Want to change the current branch? (default: N) [y/N]: " decision_if_change_branch
    echo ""
    if [[ "${decision_if_change_branch}" == "y" ]]; then
        echo "Fetching available branches"
        available_branches=$(git ls-remote --heads "${DOTFILES_GIT_REPO}" | awk '{print $2}' | sed 's/refs\/heads\///g')
        printf "Available branches: \n\n%s\n\n" "${available_branches}"
        echo "Enter the branch number followed by enter key"
        select branch_name in ${available_branches}; do
            break
        done

        if [[ -z "${branch_name}" ]]; then
            echo "No branch selected, exiting"
            exit 1
        fi
        export DOTFILES_BRANCH="${branch_name}"
    else
        export DOTFILES_BRANCH="${preferred_branch}"
    fi
}

pre_install_dotfiles() {
    echo "Setting up dotfiles"

    if [[ "${DOTFILES_CLEAN_INSTALL}" == "true" ]]; then
        echo "Removing existing dotfiles directory if exists"
        rm -rf "${DOTFILES_DIR}"
    else
        if [[ -z "${DOTFILES_SILENT_INSTALL}" ]] && [[ -d "${DOTFILES_DIR}" ]]; then
            read -r -n1 -p "Reset all dotfiles? (default: N) [y/N]: " decision_if_reset
            echo ""
            if [[ "${decision_if_reset}" == "y" ]]; then
                echo "Removing existing dotfiles directory if exists"
                rm -rf "${DOTFILES_DIR}"
            fi
        fi
    fi

    if [[ -z "${DOTFILES_DIR}" ]]; then
        if [[ -z "${DOTFILES_SILENT_INSTALL}" ]]; then
            read_dotfiles_directory
        else
            echo "Dotfiles directory is not set and running in silent mode"
            exit 1
        fi
    fi

    if [[ -z "${DOTFILES_GIT_REPO}" ]]; then
        if [[ -z "${DOTFILES_SILENT_INSTALL}" ]]; then
            read_gitrepo_from_user
        else
            echo "Dotfiles git repository is not set and running in silent mode"
            exit 1
        fi
    fi

    if [[ -z "${DOTFILES_BRANCH}" ]]; then
        if [[ -z "${DOTFILES_SILENT_INSTALL}" ]]; then
            read_branch_from_user
        else
            preferred_branch=$(get_preferred_branch)
            export DOTFILES_BRANCH="${preferred_branch}"
        fi
    fi

}

new_install() {
    doconfig_cmd="git --git-dir=${DOTFILES_DIR} --work-tree=${HOME}"
    echo "Cloning dotfiles"
    git clone --bare "${DOTFILES_GIT_REPO}" "${DOTFILES_DIR}" --branch "${DOTFILES_BRANCH}"
    ${doconfig_cmd} config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

    echo "Fetching all branches"
    ${doconfig_cmd} fetch --all

    echo "Setting upstream to origin/${DOTFILES_BRANCH}"
    ${doconfig_cmd} branch --set-upstream-to=origin/"${DOTFILES_BRANCH}" "${DOTFILES_BRANCH}"
}

existing_install_update() {
    doconfig_cmd="git --git-dir=${DOTFILES_DIR} --work-tree=${HOME}"
    echo "Repository already cloned in ${DOTFILES_DIR}"

    current_remote=$(${doconfig_cmd} remote get-url origin)

    if [[ "${current_remote}" != "${DOTFILES_GIT_REPO}" ]]; then
        echo "Current remote is ${current_remote}, changing to ${DOTFILES_GIT_REPO}"
        ${doconfig_cmd} remote set-url origin "${DOTFILES_GIT_REPO}"
    else
        echo "Current remote is already ${DOTFILES_GIT_REPO}"
    fi

    echo "Setting remote origin fetch to +refs/heads/*:refs/remotes/origin/*"
    ${doconfig_cmd} config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

    echo "Fetching all branches and pruning"
    ${doconfig_cmd} fetch --all --prune

    current_branch=$(check_existing_branch)

    if [[ "${current_branch}" != "${DOTFILES_BRANCH}" ]]; then
        echo "Current branch is ${current_branch}, changing to ${DOTFILES_BRANCH}"
        dotfiles_stash_name="dotfiles-stash-$(date +%s)"
        echo "Stashing changes with message: ${dotfiles_stash_name}"
        ${doconfig_cmd} stash push -m "${dotfiles_stash_name}"
        ${doconfig_cmd} checkout "${DOTFILES_BRANCH}"
    else
        echo "Current branch is already ${DOTFILES_BRANCH}"
    fi

    echo "Setting upstream to origin/${DOTFILES_BRANCH}"
    ${doconfig_cmd} branch --set-upstream-to=origin/"${DOTFILES_BRANCH}" "${DOTFILES_BRANCH}"
}

post_install_dotfiles() {
    doconfig_cmd="git --git-dir=${DOTFILES_DIR} --work-tree=${HOME}"
    ## Set status.showUntrackedFiles to no
    echo "Setting status.showUntrackedFiles to no"
    ${doconfig_cmd} config --local status.showUntrackedFiles no

    ## Add alias to rc files
    echo "alias dotfiles='git --git-dir=${DOTFILES_DIR} --work-tree=${HOME}'" >>"${HOME}/.bashrc"
    echo "alias dotfiles='git --git-dir=${DOTFILES_DIR} --work-tree=${HOME}'" >>"${HOME}/.zshrc"
    echo "alias dotfiles='git --git-dir=${DOTFILES_DIR} --work-tree=${HOME}'" >>"${HOME}/.aliasrc"

    ## Check status
    ${doconfig_cmd} status
}

install_dotfiles() {
    pre_install_dotfiles

    if [[ ! -d "${DOTFILES_DIR}" ]]; then
        new_install
    else
        existing_install_update
    fi
    post_install_dotfiles
}

main() {
    for action in "${@}"; do
        case "${action}" in
        install_dotfiles)
            install_dotfiles
            ;;
        *)
            echo "Invalid option: ${action}."
            help
            exit 1
            ;;
        esac
    done
}

while getopts "o:r:cb:sh" opt; do
    case "${opt}" in
    o)
        echo "Setting dotfiles directory to ${OPTARG}"
        if [[ -n "${DOTFILES_DIR}" ]]; then
            echo "Exit Error: DOTFILES_DIR is already set to ${DOTFILES_DIR}"
            exit 1
        fi
        export DOTFILES_DIR="${OPTARG}"
        ;;
    r)
        echo "Setting dotfiles git repository to ${OPTARG}"
        if [[ -n "${DOTFILES_GIT_REPO}" ]]; then
            echo "Exit Error: DOTFILES_GIT_REPO is already set to ${DOTFILES_GIT_REPO}"
            exit 1
        fi

        export DOTFILES_GIT_REPO="${OPTARG}"
        ;;
    b)
        echo "Setting dotfiles git branch to ${OPTARG}"
        if [[ -n "${DOTFILES_BRANCH}" ]]; then
            echo "Exit Error: DOTFILES_BRANCH is already set to ${DOTFILES_BRANCH}"
            exit 1
        fi
        export DOTFILES_BRANCH="${OPTARG}"
        ;;
    c)
        echo "If dotfiles directory exists, it will be removed"
        if [[ -n "${DOTFILES_CLEAN_INSTALL}" ]]; then
            echo "Exit Error: DOTFILES_CLEAN_INSTALL is already set to ${DOTFILES_CLEAN_INSTALL}"
            exit 1
        fi
        export DOTFILES_CLEAN_INSTALL="true"
        ;;
    s)
        echo "No prompt for input"
        if [[ -n "${DOTFILES_SILENT_INSTALL}" ]]; then
            echo "Exit Error: DOTFILES_SILENT_INSTALL is already set to ${DOTFILES_SILENT_INSTALL}"
            exit 1
        fi
        export DOTFILES_SILENT_INSTALL="true"
        ;;
    h)
        help
        exit 0
        ;;
    *)
        echo "Invalid option: -${opt}."
        help
        exit 1
        ;;
    esac
done

declare -a boolean_variables=("DOTFILES_CLEAN_INSTALL" "DOTFILES_SILENT_INSTALL")

for variable in "${boolean_variables[@]}"; do
    if [[ -n "${!variable}" ]]; then
        if [[ "${!variable}" == "true" ]]; then
            export "${variable}"="true"
        else
            export "${variable}"="false"
        fi
    fi
done

shift $((OPTIND - 1))

main "${@}"
