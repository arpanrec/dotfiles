#!/usr/bin/env bash
set -e

if [[ $(id -u) -eq 0 ]]; then
    echo "Root user detected!!!! Error"
    exit 1
fi

if [[ -z $* ]]; then

    __install_tags=()

    read -n1 -r -p "Enter \"Y\" to track dotfiles from 'https://github.com/arpanrec/dotfiles' (Press any other key to Skip*) : " install_dotfiles
    echo ""
    if [[ ${install_dotfiles} == "Y" || ${install_dotfiles} == "y" ]]; then
        __install_tags+=('dotfiles')
    fi

    read -n1 -r -p 'Enter "Y" to install Telegram (Press any other key to Skip*) : ' install_telegram
    echo ""
    if [[ $install_telegram == "Y" || $install_telegram == "y" ]]; then
        __install_tags+=('telegram')
    fi

    read -n1 -r -p 'Enter "Y" to install Terraform (Press any other key to Skip*) : ' install_terraform
    echo ""
    if [[ $install_terraform == "Y" || $install_terraform == "y" ]]; then
        __install_tags+=('terraform')
    fi

    read -n1 -r -p 'Enter "Y" to install Vault (Press any other key to Skip*) : ' install_vault
    echo ""
    if [[ $install_vault == "Y" || $install_vault == "y" ]]; then
        __install_tags+=('vault')
    fi

    read -n1 -r -p 'Enter "Y" to install Bitwarden (Press any other key to Skip*) : ' install_bitwarden_app_image
    echo ""
    if [[ $install_bitwarden_app_image == "Y" || $install_bitwarden_app_image == "y" ]]; then
        __install_tags+=('bitwarden_desktop')
    fi

    read -n1 -r -p 'Enter "Y" to install Bitwarden Command-line Interface (Press any other key to Skip*) : ' install_bitwarden_cli
    echo ""
    if [[ $install_bitwarden_cli == "Y" || $install_bitwarden_cli == "y" ]]; then
        __install_tags+=('bw')
    fi

    read -n1 -r -p 'Enter "Y" to install Mattermost (Press any other key to Skip*) : ' install_mattermost
    echo ""
    if [[ $install_mattermost == "Y" || $install_mattermost == "y" ]]; then
        __install_tags+=('mattermost_desktop')
    fi

    read -n1 -r -p 'Enter "Y" to install Postman (Press any other key to Skip*) : ' install_postman
    echo ""
    if [[ $install_postman == "Y" || $install_postman == "y" ]]; then
        __install_tags+=('postman')
    fi

    read -n1 -r -p 'Enter "Y" to install node js (Press any other key to Skip*) : ' install_node_js
    echo ""
    if [[ $install_node_js == "Y" || $install_node_js == "y" ]]; then
        __install_tags+=('nodejs')
    fi

    read -n1 -r -p 'Enter "Y" to install go (Press any other key to Skip*) : ' install_go
    echo ""
    if [[ $install_go == "Y" || $install_go == "y" ]]; then
        __install_tags+=('go')
    fi

    read -n1 -r -p 'Enter "Y" to install Oracle JDK17 (Press any other key to Skip*) : ' install_java
    echo ""
    if [[ $install_java == "Y" || $install_java == "y" ]]; then
        __install_tags+=('java')
    fi

    read -n1 -r -p 'Enter "Y" to install Visual Studio Code (Press any other key to Skip*) : ' install_vscode
    echo ""
    if [[ $install_vscode == "Y" || $install_vscode == "y" ]]; then
        __install_tags+=('code')
    fi

    read -n1 -r -p 'Enter "Y" to download themes (Press any other key to Skip*) : ' download_themes
    echo ""
    if [[ $download_themes == "Y" || $download_themes == "y" ]]; then
        __install_tags+=('themes')
    fi

    read -n1 -r -p 'Enter "Y" to install gnome (Press any other key to Skip*) : ' install_gnome
    echo ""
    if [[ ${install_gnome} == "Y" || ${install_gnome} == "y" ]]; then
        __install_tags+=('gnome')
    fi

    __ansible_tags=$(printf "%s," "${__install_tags[@]}")

fi

__server_workspace_venv_directory="${HOME}/.tmp/server_workspace_venv"

# shellcheck source=/dev/null
if [[ -z ${VIRTUAL_ENV} ]]; then
    export PATH="${HOME}/.local/bin:${PATH}"
    echo "Updating Python packages"
    # "$(readlink -f "$(which python3)")" -m pip install testresources wheel setuptools pip virtualenv --user --upgrade
    echo "Pip Packages installed"
    if [[ ! -d "${__server_workspace_venv_directory}" ]]; then
        "$(readlink -f "$(which python3)")" -m venv "${__server_workspace_venv_directory}"
    fi
    if [[ -f "${__server_workspace_venv_directory}/local/bin/activate" ]]; then
        source "${__server_workspace_venv_directory}/local/bin/activate"
    else
        source "${__server_workspace_venv_directory}/bin/activate"
    fi
fi

echo ""
echo "Python :: $(python3 --version)"
echo "Virtual Env :: ${VIRTUAL_ENV}"
echo "Working dir :: ${PWD}"
pip3 install --upgrade setuptools-rust pip
pip3 install ansible requests --upgrade
ansible-galaxy collection install git+https://github.com/arpanrec/arpanrec.nebula.git -f

MMC_SERVER_WORKSPACE_JSON="${MMC_SERVER_WORKSPACE_JSON:-${HOME}/.tmp/server_workspace.json}"
echo "MMC_SERVER_WORKSPACE_JSON :: ${MMC_SERVER_WORKSPACE_JSON}"
echo "Check if ${MMC_SERVER_WORKSPACE_JSON} exists"
if [[ ! -f "${MMC_SERVER_WORKSPACE_JSON}" ]]; then
    echo "Creating ${MMC_SERVER_WORKSPACE_JSON}"
    echo "Creating directory $(dirname "${MMC_SERVER_WORKSPACE_JSON}")"
    mkdir -p "$(dirname "${MMC_SERVER_WORKSPACE_JSON}")"
    echo "{}" >"${MMC_SERVER_WORKSPACE_JSON}"
    echo "File ${MMC_SERVER_WORKSPACE_JSON} created"
else
    echo "File ${MMC_SERVER_WORKSPACE_JSON} exists"
    echo "This file will be used as extra-vars"
fi

__server_workspace_inventory="${HOME}/.tmp/server_workspace_inventory.yml"

echo "Creating ${__server_workspace_inventory}"
tee "${__server_workspace_inventory}" >/dev/null <<EOF
---
all:
  hosts:
    localhost:
      ansible_connection: local

EOF

if [[ -n ${__ansible_tags} && ${__ansible_tags} != "," && -z $* ]]; then
    ansible-playbook -i "${__server_workspace_inventory}" arpanrec.nebula.server_workspace --extra-vars "@${MMC_SERVER_WORKSPACE_JSON}" --tags "${__ansible_tags::-1}"
elif [[ -z ${__ansible_tags} && -n $* ]]; then
    ansible-playbook -i "${__server_workspace_inventory}" arpanrec.nebula.server_workspace --extra-vars "@${MMC_SERVER_WORKSPACE_JSON}" "$@"
fi
