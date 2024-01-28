#!/usr/bin/env bash
set -e

deactivate || true

__clone_directory="${HOME}/.tmp/dotfiles_server_workspace"
__working_dir="${__clone_directory}/workspace/.setup"
__git_setup_repo='https://github.com/arpanrec/dotfiles.git'

if ! hash git &>/dev/null; then
    echo "git not Installed"
    exit 1
fi

mkdir -p "$(dirname "${__clone_directory}")"

if [[ ! -d ${__clone_directory} ]]; then
    git clone --depth 1 --single-branch "${__git_setup_repo}" "${__clone_directory}"
    cd "${__working_dir}"
else
    cd "${__working_dir}"
fi

git reset --hard HEAD
git clean -f -d
git pull

./server_workspace.sh "$@"
