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

read_dotfiles_directory() {
    echo "Enter the dotfiles directory (default: ${HOME}/.dotfiles)"
    read -r -p "Press enter to use default: " dotfiles_directory_input
    if [[ -n "${dotfiles_directory_input}" ]]; then
        export DOTFILES_DIR="${dotfiles_directory_input}"
    else
        export DOTFILES_DIR="${HOME}/.dotfiles"
    fi
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

read_branch_from_user() {

    default_branch=$(check_existing_branch)
    if [[ -z "${default_branch}" ]]; then
        echo "No git repository found in ${DOTFILES_DIR}"
        if default_branch=$(git ls-remote --symref "${DOTFILES_GIT_REPO}" HEAD |
            awk '{print $2}' | sed 's/refs\/heads\///g' | head -1); then
            echo "Default branch of ${DOTFILES_GIT_REPO} is ${default_branch}"
        else
            exit 1
        fi
    fi
    read -r -p "Want to change the current branch? (default: N) [y/N]: " decision_if_change_branch
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
        export DOTFILES_BRANCH="${default_branch}"
    fi
}

pre_install_dotfiles() {
    echo "Setting up dotfiles"

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
            echo "Dotfiles branch is not set and running in silent mode"
            exit 1
        fi
    fi

    if [[ "${DOTFILES_CLEAN_INSTALL}" == "true" ]]; then
        echo "Removing existing dotfiles directory if exists"
        rm -rf "${DOTFILES_DIR}"
    else
        if [[ -z "${DOTFILES_SILENT_INSTALL}" ]]; then
            read -r -n1 -p "Reset all dotfiles? (default: N) [y/N]: " decision_if_reset
            echo ""
            if [[ "${decision_if_reset}" == "y" ]]; then
                echo "Removing existing dotfiles directory if exists"
                rm -rf "${DOTFILES_DIR}"
            fi
        fi
    fi
}

install_dotfiles() {
    pre_install_dotfiles

    if [[ ! -d "${DOTFILES_DIR}" ]]; then
        echo "Cloning dotfiles"
        git clone --bare "${DOTFILES_GIT_REPO}" "${DOTFILES_DIR}" --branch "${DOTFILES_BRANCH}"
        git --git-dir="${DOTFILES_DIR}" config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

        echo "Fetching all branches"
        git --git-dir="${DOTFILES_DIR}" fetch --all

        echo "Setting upstream to origin/${DOTFILES_BRANCH}"
        git --git-dir="${DOTFILES_DIR}" branch --set-upstream-to=origin/"${DOTFILES_BRANCH}" "${DOTFILES_BRANCH}"
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
