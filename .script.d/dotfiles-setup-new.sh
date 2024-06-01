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

    dotfiles-setup-new.sh [OPTIONS].

    Environment variables can be used to set default values.

    -o Path
            Dotfiles directory. Default is "\${HOME}/.dotfiles"
            Example:
                    "-o /home/user/.dotfiles"
            ENV: DOTFILES_DIR

    -r URL
            Dotfiles git repository.
            Example:
                    "-r https://github.com/arpanrec/dotfiles.git"
                    "-r git@github.com:arpanrec/dotfiles.git"
            ENV: DOTFILES_GIT_REPO

    -b Branch
            Dotfiles git repository branch. Default is "main"
            Example:
                    "-b main"
            ENV: DOTFILES_BRANCH

    -c
            If -c is passed, the script will remove the existing dotfiles directory.
            Example:
                    "-c"
            ENV: DOTFILES_CLEAN_INSTALL

    -s
            If -s is passed, the script will not prompt for any input.
            Example:
                    "-s"
            ENV: DOTFILES_SILENT_INSTALL

    -h Show this help message.
EOF
}

read_gitrepo_from_user() {

    git_protocol="https"
    git_remote_host="github.com"
    git_repo_path="arpanrec/dotfiles"
    ssh_git_user="git"

    read -r -n1 -p "Use ssh remote? Current remote protocol is ${git_protocol}. (default: N) [y/N]: " \
        decision_if_change_remote_ssh
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

install_dotfiles() {
    echo "Setting up dotfiles"
    if [[ -z "${DOTFILES_GIT_REPO}" ]]; then
        if [[ -z "${DOTFILES_SILENT_INSTALL}" ]]; then
            read_gitrepo_from_user
        else
            echo "DOTFILES_GIT_REPO is not set"
            exit 1
        fi
    fi
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
        echo "Setting DOTFILES_DIR to ${OPTARG}"
        if [[ -n "${DOTFILES_DIR}" ]]; then
            echo "DOTFILES_DIR is already set to ${DOTFILES_DIR}"
            echo "Exiting"
            exit 1
        fi
        export DOTFILES_DIR="${OPTARG}"
        ;;
    r)
        echo "Setting DOTFILES_GIT_REPO to ${OPTARG}"
        if [[ -n "${DOTFILES_GIT_REPO}" ]]; then
            echo "DOTFILES_GIT_REPO is already set to ${DOTFILES_GIT_REPO}"
            echo "Exiting"
            exit 1
        fi

        export DOTFILES_GIT_REPO="${OPTARG}"
        ;;
    b)
        echo "Setting DOTFILES_BRANCH to ${OPTARG}"
        if [[ -n "${DOTFILES_BRANCH}" ]]; then
            echo "DOTFILES_BRANCH is already set to ${DOTFILES_BRANCH}"
            echo "Exiting"
            exit 1
        fi
        export DOTFILES_BRANCH="${OPTARG}"
        ;;
    c)
        echo "Setting DOTFILES_CLEAN_INSTALL to true"
        if [[ -n "${DOTFILES_CLEAN_INSTALL}" ]]; then
            echo "DOTFILES_CLEAN_INSTALL is already set to ${DOTFILES_CLEAN_INSTALL}"
            echo "Exiting"
            exit 1
        fi
        export DOTFILES_CLEAN_INSTALL="true"
        ;;
    s)
        echo "Setting DOTFILES_SILENT_INSTALL to true"
        if [[ -n "${DOTFILES_SILENT_INSTALL}" ]]; then
            echo "DOTFILES_SILENT_INSTALL is already set to ${DOTFILES_SILENT_INSTALL}"
            echo "Exiting"
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
