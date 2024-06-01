#!/usr/bin/env bash
set -euo pipefail

export DOTFILES_DIR="${DOTFILES_DIR:-"${HOME}/.dotfiles"}"
export DOTFILES_GIT_REPO="${DOTFILES_GIT_REPO:-}"
export DOTFILES_CLEAN_INSTALL="${DOTFILES_CLEAN_INSTALL:-false}"
export DOTFILES_BRANCH="${DOTFILES_BRANCH:-}"

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

    -h Show this help message.
EOF
}

check_variables() {
    declare -a required_variables=("DOTFILES_DIR" "DOTFILES_GIT_REPO" "DOTFILES_CLEAN_INSTALL" "DOTFILES_BRANCH")
    for required_variable in "${required_variables[@]}"; do
        if [ -z "${!required_variable}" ]; then
            echo "Required variable ${required_variable} is not set"
            exit 1
        fi
    done

    # DOTFILES_CLEAN_INSTALL should be a boolean
    if [[ "${DOTFILES_CLEAN_INSTALL}" != "true" && "${DOTFILES_CLEAN_INSTALL}" != "false" ]]; then
        echo "DOTFILES_CLEAN_INSTALL should be a boolean true or false"
        exit 1
    fi

}

main() {
    check_variables
    echo "Setting up dotfiles"
    echo "Dotfiles directory is ${DOTFILES_DIR}"
}

while getopts "o:r:cb:h" opt; do
    case "${opt}" in
    o)
        echo "Setting DOTFILES_DIR to ${OPTARG}"
        export DOTFILES_DIR="${OPTARG}"
        ;;
    r)
        echo "Setting DOTFILES_GIT_REPO to ${OPTARG}"
        export DOTFILES_GIT_REPO="${OPTARG}"
        ;;
    b)
        echo "Setting DOTFILES_BRANCH to ${OPTARG}"
        export DOTFILES_BRANCH="${OPTARG}"
        ;;
    c)
        echo "Setting DOTFILES_CLEAN_INSTALL to true"
        export DOTFILES_CLEAN_INSTALL="true"
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

shift $((OPTIND - 1))

echo "Remaining arguments: ${*}"

main
