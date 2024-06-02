#!/usr/bin/env bash
set -euo pipefail

export DOTFILES_DIR="${DOTFILES_DIR:-}"
export DOTFILES_GIT_REPO="${DOTFILES_GIT_REPO:-}"
export DOTFILES_CLEAN_INSTALL="${DOTFILES_CLEAN_INSTALL:-}"
export DOTFILES_BRANCH="${DOTFILES_BRANCH:-}"
export DOTFILES_SILENT_INSTALL="${DOTFILES_SILENT_INSTALL:-}"
export DOTFILES_BACKUP_DIR="${DOTFILES_BACKUP_DIR:-}"
export DOTFILES_INSTALL_COMPLETE=false
export DOTFILES_RESET="${DOTFILES_RESET:-}"

main_help() {
    cat <<EOF
-----------------------------------------------
-----------------------------------------------
Setup dotfiles sync with git for new systems.
-----------------------------------------------
-----------------------------------------------

Usage:

    dotfiles-setup.sh [OPTIONS] [OPERATION] [ARGUMENTS]

    Operations:
        install_dotfiles
        backup_dotfiles

    Environment variables can be used to set default values for options and arguments.

    -r URL
            Dotfiles git repository.
            ENV: DOTFILES_GIT_REPO
            Example:
                    "-r https://github.com/arpanrec/dotfiles.git"
                    "-r git@github.com:arpanrec/dotfiles.git"
                    "export DOTFILES_GIT_REPO=git@github.com:arpanrec/dotfiles.git"

    -s
            If -s is passed, the script will not prompt for any input.
            ENV: DOTFILES_SILENT_INSTALL
            Example:
                    "-s"
                    "export DOTFILES_SILENT_INSTALL=true"
    
    -k
            If -k is passed, the script will reset all dotfiles.
            ENV: DOTFILES_RESET
            Example:
                    "-k"
                    "export DOTFILES_RESET=true"

    -h
            Show this help message.
EOF
}

install_dotfiles_help() {
    main_help
    cat <<EOF

    OPERATION: install_dotfiles
    Setup git bare repository for dotfiles sync with home directory.

    Usage:

        dotfiles-setup.sh [OPTIONS] install_dotfiles [ARGUMENTS]

        Arguments:
            -o Path
                    Dotfiles directory.
                    ENV: DOTFILES_DIR
                    Example:
                            "-o /home/user/.dotfiles"
                            "export DOTFILES_DIR=/home/user/.dotfiles"

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

            -h
                    Show this help message.
EOF
}

backup_dotfiles_help() {
    main_help
    cat <<EOF

    OPERATION: backup_dotfiles
    Backup dotfiles to a directory.

    Usage:

        dotfiles-setup.sh [OPTIONS] backup_dotfiles [ARGUMENTS]

        Arguments:
            -o Path
                    Backup directory.
                    ENV: DOTFILES_BACKUP_DIR
                    Example:
                            "-d /home/user/.dotfiles"
                            "export DOTFILES_BACKUP_DIR=/home/user/.dotfiles"

            -h
                    Show this help message.
EOF
}

install_dotfiles_read_dotfiles_directory() {
    echo "Enter the dotfiles directory (default: ${HOME}/.dotfiles)"
    read -r -p "Press enter to use default: " dotfiles_directory_input
    if [[ -n "${dotfiles_directory_input}" ]]; then
        export DOTFILES_DIR="${dotfiles_directory_input}"
    else
        export DOTFILES_DIR="${HOME}/.dotfiles"
    fi
}

install_dotfiles_read_gitrepo_from_user() {

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

install_dotfiles_check_existing_branch() {
    if [[ -d "${DOTFILES_DIR}" ]]; then
        if branch_name=$(git --git-dir "${DOTFILES_DIR}" rev-parse --abbrev-ref HEAD); then
            echo "${branch_name}"
        else
            exit 1
        fi
    fi
}

install_dotfiles_get_preferred_branch() {
    existing_branch=$(install_dotfiles_check_existing_branch)
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

install_dotfiles_read_branch_from_user() {
    preferred_branch=$(install_dotfiles_get_preferred_branch)
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

install_dotfiles_pre() {
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

    if [[ -z "${DOTFILES_GIT_REPO}" ]]; then
        if [[ -z "${DOTFILES_SILENT_INSTALL}" ]]; then
            install_dotfiles_read_gitrepo_from_user
        else
            echo "Dotfiles git repository is not set and running in silent mode"
            main_help
            exit 1
        fi
    fi

    if [[ -z "${DOTFILES_DIR}" ]]; then
        if [[ -z "${DOTFILES_SILENT_INSTALL}" ]]; then
            install_dotfiles_read_dotfiles_directory
        else
            echo "Dotfiles directory is not set and running in silent mode"
            install_dotfiles_help
            exit 1
        fi
    fi

    if [[ -z "${DOTFILES_BRANCH}" ]]; then
        if [[ -z "${DOTFILES_SILENT_INSTALL}" ]]; then
            install_dotfiles_read_branch_from_user
        else
            preferred_branch=$(install_dotfiles_get_preferred_branch)
            export DOTFILES_BRANCH="${preferred_branch}"
        fi
    fi

}

install_dotfiles_new() {
    doconfig_cmd="git --git-dir=${DOTFILES_DIR} --work-tree=${HOME}"
    echo "Cloning dotfiles"
    git clone --bare "${DOTFILES_GIT_REPO}" "${DOTFILES_DIR}" --branch "${DOTFILES_BRANCH}"
    ${doconfig_cmd} config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

    echo "Fetching all branches"
    ${doconfig_cmd} fetch --all

    echo "Setting upstream to origin/${DOTFILES_BRANCH}"
    ${doconfig_cmd} branch --set-upstream-to=origin/"${DOTFILES_BRANCH}" "${DOTFILES_BRANCH}"
}

install_dotfiles_update_existing() {
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

    current_branch=$(install_dotfiles_check_existing_branch)

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

install_dotfiles_post() {
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

install_dotfiles_args_parse() {
    while getopts "o:cb:h" opt; do
        case "${opt}" in
        o)
            if [[ -n "${DOTFILES_DIR}" ]]; then
                echo "Exit Error: DOTFILES_DIR or -o is already set to ${DOTFILES_DIR}"
                exit 1
            fi
            export DOTFILES_DIR="${OPTARG}"
            ;;
        b)
            if [[ -n "${DOTFILES_BRANCH}" ]]; then
                echo "Exit Error: DOTFILES_BRANCH or -b is already set to ${DOTFILES_BRANCH}"
                exit 1
            fi
            export DOTFILES_BRANCH="${OPTARG}"
            ;;
        c)
            if [[ -n "${DOTFILES_CLEAN_INSTALL}" ]]; then
                echo "Exit Error: DOTFILES_CLEAN_INSTALL or -c is already set to ${DOTFILES_CLEAN_INSTALL}"
                exit 1
            fi
            export DOTFILES_CLEAN_INSTALL="true"
            ;;
        h)
            install_dotfiles_help
            exit 0
            ;;
        *)
            install_dotfiles_help
            exit 1
            ;;
        esac
    done

    declare -a boolean_variables=("DOTFILES_CLEAN_INSTALL")

    for variable in "${boolean_variables[@]}"; do
        if [[ -n "${!variable}" ]]; then
            if [[ "${!variable}" == "true" ]]; then
                export "${variable}"="true"
            else
                export "${variable}"="false"
            fi
        fi
    done
}

install_dotfiles() {
    install_dotfiles_pre

    if [[ ! -d "${DOTFILES_DIR}" ]]; then
        install_dotfiles_new
    else
        install_dotfiles_update_existing
    fi
    install_dotfiles_post
}

main_options_parse() {
    while getopts "r:skh" opt; do
        case "${opt}" in
        r)
            if [[ -n "${DOTFILES_GIT_REPO}" ]]; then
                echo "Exit Error: DOTFILES_GIT_REPO or -r is already set to ${DOTFILES_GIT_REPO}"
                exit 1
            fi

            export DOTFILES_GIT_REPO="${OPTARG}"
            ;;
        s)
            if [[ -n "${DOTFILES_SILENT_INSTALL}" ]]; then
                echo "Exit Error: DOTFILES_SILENT_INSTALL or -s is already set to ${DOTFILES_SILENT_INSTALL}"
                exit 1
            fi
            export DOTFILES_SILENT_INSTALL="true"
            ;;
        k)
            if [[ -n "${DOTFILES_RESET}" ]]; then
                echo "Exit Error: DOTFILES_RESET or -k is already set to ${DOTFILES_RESET}"
                exit 1
            fi
            export DOTFILES_RESET="true"
            ;;
        h)
            main_help
            exit 0
            ;;
        *)
            main_help
            exit 1
            ;;
        esac
    done

    declare -a boolean_variables=("DOTFILES_SILENT_INSTALL" "DOTFILES_RESET")

    for variable in "${boolean_variables[@]}"; do
        if [[ -n "${!variable}" ]]; then
            if [[ "${!variable}" == "true" ]]; then
                export "${variable}"="true"
            else
                export "${variable}"="false"
            fi
        fi
    done
}

backup_dotfiles_args_parse() {
    while getopts "o:h" opt; do
        case "${opt}" in
        o)
            if [[ -n "${DOTFILES_BACKUP_DIR}" ]]; then
                echo "Exit Error: DOTFILES_BACKUP_DIR or -o is already set to ${DOTFILES_BACKUP_DIR}"
                exit 1
            fi
            export DOTFILES_BACKUP_DIR="${OPTARG}"
            ;;
        h)
            backup_dotfiles_help
            exit 0
            ;;
        *)
            backup_dotfiles_help
            exit 1
            ;;
        esac
    done
}

dotfiles_backup_cp() {
    set -euo pipefail
    file_name="${1}"
    mkdir -p "${DOTFILES_BACKUP_DIR}/$(dirname "${file_name}" || echo)"
    echo "Backing up ${file_name} to ${DOTFILES_BACKUP_DIR}/${file_name}"
    cp "${file_name}" "${DOTFILES_BACKUP_DIR}/${file_name}" || exit 255
}

export -f dotfiles_backup_cp

backup_dotfiles() {
    if [[ -z "${DOTFILES_BACKUP_DIR}" ]]; then
        if [[ -z "${DOTFILES_SILENT_INSTALL}" ]]; then
            echo "Enter the backup directory, Default: ${HOME}/.dotfiles-backup"
            read -r -p "Press enter to use default: " backup_directory_input
            if [[ -n "${backup_directory_input}" ]]; then
                export DOTFILES_BACKUP_DIR="${backup_directory_input}"
            else
                export DOTFILES_BACKUP_DIR="${HOME}/.dotfiles-backup"
            fi
        else
            echo "Backup directory is not set and running in silent mode"
            backup_dotfiles_help
            exit 1
        fi
    fi

    echo "Backing up dotfiles to ${DOTFILES_BACKUP_DIR}"
    doconfig_cmd="git --git-dir=${DOTFILES_DIR} --work-tree=${HOME}"
    mkdir -p "${DOTFILES_BACKUP_DIR}"
    cd "${HOME}" || exit 1
    ${doconfig_cmd} ls-files | xargs -n 1 -I {} bash -c 'dotfiles_backup_cp "{}"'
}

main() {
    local OPTIND=1
    main_options_parse "${@}"
    shift $(("${OPTIND}" - 1))

    while [[ "${#}" -gt 0 ]]; do
        case "${1}" in
        install_dotfiles)
            shift
            local OPTIND=1
            install_dotfiles_args_parse "${@}"
            shift $(("${OPTIND}" - 1))
            install_dotfiles
            export DOTFILES_INSTALL_COMPLETE=true
            ;;
        backup_dotfiles)
            if [[ "${DOTFILES_INSTALL_COMPLETE}" != "true" ]]; then
                echo "Install dotfiles before backup"
                exit 1
            fi
            shift
            local OPTIND=1
            backup_dotfiles_args_parse "${@}"
            shift $(("${OPTIND}" - 1))
            backup_dotfiles
            ;;
        *)
            main_help
            exit 1
            ;;
        esac
    done

    if [[ "${DOTFILES_INSTALL_COMPLETE}" == "true" ]] && [[ "${DOTFILES_RESET}" == "true" ]]; then
        echo "Resetting to dotfiles"
        git --git-dir="${DOTFILES_DIR}" --work-tree="${HOME}" reset --hard HEAD
    fi
}

main "${@}"
