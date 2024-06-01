#!/usr/bin/env bash
set -e

__select_gpg_key() {
    list_private_keys=$(gpg --list-secret-keys --keyid-format LONG)

    printf "List of GPG keys \n %s\n" "${list_private_keys}"

    gpgkeys=$(
        gpg --with-colons --fingerprint |
            grep -B1 "^uid" |
            grep "^fpr" |
            awk -F: '$1 == "fpr" {print $10;}'
    )

    __keys_arr=()

    if [ "${#gpgkeys[@]}" -lt 1 ] || [[ "${gpgkeys}" == "" ]]; then
        echo "no Keys found"
    else
        int_con=0
        for key in ${gpgkeys}; do
            last_8_char=$(echo "${key}" | tail -c 15)
            if [[ $list_private_keys =~ ${last_8_char} ]]; then
                echo "Press ${int_con} using ${key} as gpg sign key"
                int_con=$((int_con + 1))
                __keys_arr+=("${key}")
            fi
        done
        read -r -n1 -p "Enter exact number " __gpg_key_index_in_array && echo ""
        if [[ -n ${__gpg_key_index_in_array} ]]; then
            git config --global user.signingkey "${__keys_arr[$__gpg_key_index_in_array]}"
        fi
    fi

}

__setup_git_interactively() {

    echo "Git Username, Current Value: $(git config --global user.name)"
    read -r -p "Enter Username, [Leave Empty to skip] :: " __gitconfig_username

    if [[ -n "${__gitconfig_username}" ]]; then
        git config --global user.name "${__gitconfig_username}"
    fi

    echo "Git EmailID, Current Value: $(git config --global user.email)"
    read -r -p "Enter Email ID, [Leave Empty to skip] :: " __gitconfig_email

    if [[ -n "${__gitconfig_email}" ]]; then
        git config --global user.email "${__gitconfig_email}"
    fi

    echo "Git sign commints with gpg keys, Current Value: $(git config --global commit.gpgsign)"
    read -r -n1 -p "Press Y/N to Enable or Disable, [Leave Empty to skip] :: " __gitconfig_enable_gpg && echo ""

    if [[ "${__gitconfig_enable_gpg}" == Y || "${__gitconfig_enable_gpg}" == y ]]; then
        git config --global commit.gpgsign true
    elif [[ "${__gitconfig_enable_gpg}" == N || "${__gitconfig_enable_gpg}" == n ]]; then
        git config --global commit.gpgsign false
    fi

    echo "Git GPG key id: $(git config --global user.signingkey)"
    read -r -n1 -p "Press Y to change, [Leave Empty to skip] :: " __gitconfig_key_id && echo ""

    if [[ "${__gitconfig_key_id}" == Y || "${__gitconfig_key_id}" == y ]]; then
        __select_gpg_key
    fi

}

if [[ -f "${HOME}/.gitconfig" ]]; then
    read -r -n1 -p "${HOME}/gitconfig is already present, Press Y/y to Delete the existing gitconfig, Press any other config to ignore. :: " __delete_existing_gitconfig && echo ""
    if [[ "${__delete_existing_gitconfig}" == Y || "${__delete_existing_gitconfig}" == y ]]; then
        rm -rf "${HOME}/.gitconfig"
    fi
fi

echo "git config --global advice.detachedHead false"
git config --global advice.detachedHead false

echo "git config --global fetch.prune false"
git config --global fetch.prune false

echo "git config --global pull.rebase false"
git config --global pull.rebase false

echo "git config --global core.autocrlf false"
git config --global core.autocrlf false

echo "git config --global core.filemode true"
git config --global core.filemode true

echo "git config --global core.ignorecase false"
git config --global core.ignorecase false

echo "git config --global core.safecrlf true"
git config --global core.safecrlf true

echo "git config --global core.eol lf"
git config --global core.eol lf

echo "git config --global core.editor vim"
git config --global core.editor vim

echo "git config --global core.pager less"
git config --global core.pager less

echo "git config --global push.followTags true"
git config --global push.followTags true

echo "git config --global init.defaultBranch main"
git config --global init.defaultBranch main

echo "git config --global credential.helper store --file=\${HOME}/.git-credentials"
# shellcheck disable=SC2016
git config --global credential.helper 'store --file="${HOME}/.git-credentials"'
touch "${HOME}/.git-credentials"

echo "git config --global core.excludesFile '~/.gitexcludes'"
# shellcheck disable=SC2088
git config --global core.excludesFile '~/.gitexcludes'
touch "${HOME}/.gitexcludes"

echo "git config --global color.ui auto"
git config --global color.ui auto

echo "Press a for arpanrec git config from https://github.com/arpanrec/dotfiles/blob/main/.gitconfig"
echo "Press d for dummy git config"
echo "Press any other key to setup gitconfig interactively"
read -r -n1 __symlink_gitconfig
echo ""

case ${__symlink_gitconfig} in

a | A)
    raw_url="https://raw.githubusercontent.com/arpanrec/dotfiles/main/.gitconfig"
    echo "Downloading gitconfig from ${raw_url} to ${HOME}/.gitconfig"
    curl -sSL "${raw_url}" -o "${HOME}/.gitconfig"
    excludes_raw_url="https://raw.githubusercontent.com/arpanrec/dotfiles/main/.gitexcludes"
    echo "Downloading gitexcludes from ${excludes_raw_url} to ${HOME}/.gitexcludes"
    curl -sSL "${excludes_raw_url}" -o "${HOME}/.gitexcludes"
    ;;

d | D)
    echo "git config --global commit.gpgsign false"
    git config --global commit.gpgsign false

    echo "git config --global user.name dummy"
    git config --global user.name dummy

    echo "git config --global user.email dummy@x.com"
    git config --global user.email dummy@x.com

    ;;

*)
    echo "Press Y to Delete the existing gitconfig"
    read -r -n1 -p "Press any other key to update the existing git config :: " __delete_existing_gitconfig && echo ""

    if [[ "${__delete_existing_gitconfig}" == Y || "${__delete_existing_gitconfig}" == y ]]; then
        rm -rf "${HOME}/.gitconfig"
    fi
    __setup_git_interactively
    ;;

esac
