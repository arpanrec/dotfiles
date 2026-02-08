#!/usr/bin/env bash
set -euo pipefail

echo "Starting"

if [[ "$(id -u)" -eq 0 || "${HOME}" == "/root" ]]; then
    if [[ ! -t 1 ]]; then

        echo "Script is not running in interactive mode. Exiting."
        exit 1
    fi

    echo "Root user detected, You are mad to run this script as root! If you really know your shit then \
press 'y' to continue But you are going to regret it!"
    read -r -p "Are you sure you want to continue? [y/N] " response_root_user
    if [[ ! "${response_root_user}" =~ ^([yY])$ ]]; then

        echo "Exiting script as root user detected"
        exit 1
    fi

    echo "Holy fuck, you went there, i am gonna give you 5 second to think it through"
    for i in {5..1}; do
        echo "$i..."
        sleep 1
    done
fi

dotfiles_git_remote="https://github.com/arpanrec/dotfiles.git"
dotfiles_dir="${HOME}/.dotfiles"
dotfiles_branch="dotfiles-main"
bash_it_directory="${HOME}/.bash_it"
oh_my_zsh_directory="${ZSH:-${HOME}/.oh-my-zsh}"
fzf_directory="${HOME}/.fzf"
zsh_syntax_highlighting_directory="${ZSH_CUSTOM:-${oh_my_zsh_directory}/custom}/plugins/zsh-syntax-highlighting"
zsh_autosuggestions_directory="${ZSH_CUSTOM:-${oh_my_zsh_directory}/custom}/plugins/zsh-autosuggestions"
zsh_completions_directory="${ZSH_CUSTOM:-${oh_my_zsh_directory}/custom}/plugins/zsh-completions"
powerlevel10k_directory="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

CLEAN_DOT_INSTALL="${CLEAN_DOT_INSTALL:-no}"

if [[ "${CLEAN_DOT_INSTALL}" == "yes" ]]; then
    echo "CLEAN_DOT_INSTALL is set to yes. Cleaning all existing repos."
    rm -rf "${dotfiles_dir}" "${bash_it_directory}" "${oh_my_zsh_directory}" "${fzf_directory}" \
        "${zsh_syntax_highlighting_directory}" "${zsh_autosuggestions_directory}" "${zsh_completions_directory}" \
        "${powerlevel10k_directory}"
fi

echo "Installing dotfiles from ${dotfiles_git_remote} to ${dotfiles_dir}"

if [ -f "${HOME}/.ssh/github.com" ]; then
    dotfiles_git_remote="git@github.com:arpanrec/dotfiles.git"
    echo "Using SSH key for GitHub at ${HOME}/.ssh/github.com and changing remote URL to ${dotfiles_git_remote}"
fi

if [[ ! -d "${dotfiles_dir}" ]]; then
    echo "Cloning dotfiles from ${dotfiles_git_remote} to ${dotfiles_dir} as a bare repository"
    git clone --bare "${dotfiles_git_remote}" "${dotfiles_dir}"
    echo "Checking out ${dotfiles_branch} branch with force"
    git --git-dir="${dotfiles_dir}" --work-tree="${HOME}" checkout "${dotfiles_branch}" --force
else
    git --git-dir="${dotfiles_dir}" --work-tree="${HOME}" remote set-url origin "${dotfiles_git_remote}"
    echo "${dotfiles_dir} directory already exists. Updating existing repo."
fi

echo "Adding remote origin with fetch refspec"
git --git-dir="${dotfiles_dir}" --work-tree="${HOME}" config \
    --local remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

git --git-dir="${dotfiles_dir}" --work-tree="${HOME}" fetch --all

echo "Setting status.showUntrackedFiles to no"
git --git-dir="${dotfiles_dir}" --work-tree="${HOME}" config --local status.showUntrackedFiles no

git --git-dir="${dotfiles_dir}" --work-tree="${HOME}" branch --set-upstream-to=origin/"${dotfiles_branch}" "${dotfiles_branch}"

git --git-dir="${dotfiles_dir}" --work-tree="${HOME}" pull

# "name|repo_url|target_dir"
declare -a zsh_items=(
    "bash-it|https://github.com/Bash-it/bash-it.git|${bash_it_directory}"
    "oh-my-zsh|https://github.com/ohmyzsh/ohmyzsh.git|${oh_my_zsh_directory}"
    "fzf|https://github.com/junegunn/fzf.git|${fzf_directory}"
    "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git|${zsh_syntax_highlighting_directory}"
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions.git|${zsh_autosuggestions_directory}"
    "zsh-completions|https://github.com/zsh-users/zsh-completions.git|${zsh_completions_directory}"
    "powerlevel10k|https://github.com/romkatv/powerlevel10k.git|${powerlevel10k_directory}"
)

for item in "${zsh_items[@]}"; do
    IFS="|" read -r item_name item_repo item_dir <<<"${item}"

    echo "Installing ${item_name}"

    if [[ ! -d "${item_dir}" ]]; then
        echo "Cloning ${item_repo} to ${item_dir}"
        git clone --depth 1 "${item_repo}" "${item_dir}" --single-branch
    else
        echo "${item_name} already exists at ${item_dir}. Updating."
        (
            cd "${item_dir}" || exit 1
            git reset --hard HEAD
            git clean -fd
            git pull
        )
    fi
done

chmod +x "${fzf_directory}/install"
"${fzf_directory}/install" --all

chmod +x "${powerlevel10k_directory}/gitstatus/install"
"${powerlevel10k_directory}/gitstatus/install" -f

echo "Adding my ssh key"

public_key="$(curl -sSfL https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/dotfiles-assets/id_ecdsa.pub)"
AUTHORIZED_KEYS_FILE="${HOME}/.ssh/authorized_keys"

mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"
touch "${AUTHORIZED_KEYS_FILE}"
chmod 600 "${AUTHORIZED_KEYS_FILE}"

if ! grep -qxF "${public_key}" "${AUTHORIZED_KEYS_FILE}"; then
    echo "${public_key}" >>"${AUTHORIZED_KEYS_FILE}"
    echo "SSH key added."
else
    echo "SSH key already present."
fi
echo "Completed"
