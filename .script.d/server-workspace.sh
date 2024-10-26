#!/usr/bin/env bash
set -e

if [[ $(id -u) -eq 0 ]]; then
    echo "Root user detected!!!! Error"
    exit 1
fi

which_os_python() {
    # Simply don't use python, /usr/bin/python etc, try to find the highest version of python3
    declare -a PYTHON_VERSIONS=("python3.13" "python3.12" "python3.11" "python3.10")

    for python_version in "${PYTHON_VERSIONS[@]}"; do
        if command -v "${python_version}" &>/dev/null; then
            echo "${python_version}"
            return
        fi
    done

    echo "Supported Python version not found, Only Python3.6+ >< 4 is supported"
    exit 1
}

if [[ -z $* ]]; then

    __install_tags=()

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

    read -n1 -r -p 'Enter "Y" to terminal tools (Press any other key to Skip*) : ' download_terminal
    echo ""
    if [[ $download_terminal == "Y" || $download_terminal == "y" ]]; then
        __install_tags+=('terminal')
    fi

    read -n1 -r -p 'Enter "Y" to install Vault (Press any other key to Skip*) : ' install_vault
    echo ""
    if [[ $install_vault == "Y" || $install_vault == "y" ]]; then
        __install_tags+=('vault')
    fi

    read -n1 -r -p 'Enter "Y" to install Terraform (Press any other key to Skip*) : ' install_terraform
    echo ""
    if [[ $install_terraform == "Y" || $install_terraform == "y" ]]; then
        __install_tags+=('terraform')
    fi

    read -n1 -r -p 'Enter "Y" to install pulumi (Press any other key to Skip*) : ' install_pulumi
    echo ""
    if [[ $install_pulumi == "Y" || $install_pulumi == "y" ]]; then
        __install_tags+=('pulumi')
    fi

    read -n1 -r -p 'Enter "Y" to install Bitwarden SDK (Press any other key to Skip*) : ' install_bitwarden_sdk
    echo ""
    if [[ $install_bitwarden_sdk == "Y" || $install_bitwarden_sdk == "y" ]]; then
        __install_tags+=('bws')
    fi

    read -n1 -r -p 'Enter "Y" to install Bitwarden (Press any other key to Skip*) : ' install_bitwarden_app_image
    echo ""
    if [[ $install_bitwarden_app_image == "Y" || $install_bitwarden_app_image == "y" ]]; then
        __install_tags+=('bitwarden_desktop')
    fi

    read -n1 -r -p 'Enter "Y" to install Mattermost (Press any other key to Skip*) : ' install_mattermost
    echo ""
    if [[ $install_mattermost == "Y" || $install_mattermost == "y" ]]; then
        __install_tags+=('mattermost_desktop')
    fi

    read -n1 -r -p 'Enter "Y" to install Telegram (Press any other key to Skip*) : ' install_telegram_desktop
    echo ""
    if [[ $install_telegram_desktop == "Y" || $install_telegram_desktop == "y" ]]; then
        __install_tags+=('telegram_desktop')
    fi

    read -n1 -r -p 'Enter "Y" to install Postman (Press any other key to Skip*) : ' install_postman
    echo ""
    if [[ $install_postman == "Y" || $install_postman == "y" ]]; then
        __install_tags+=('postman')
    fi

    read -n1 -r -p 'Enter "Y" to install Visual Studio Code (Press any other key to Skip*) : ' install_vscode
    echo ""
    if [[ $install_vscode == "Y" || $install_vscode == "y" ]]; then
        __install_tags+=('code')
    fi

    read -n1 -r -p 'Enter "Y" to install gnome (Press any other key to Skip*) : ' install_gnome
    echo ""
    if [[ ${install_gnome} == "Y" || ${install_gnome} == "y" ]]; then
        __install_tags+=('gnome')
    fi

    read -n1 -r -p 'Enter "Y" to download themes (Press any other key to Skip*) : ' download_themes
    echo ""
    if [[ $download_themes == "Y" || $download_themes == "y" ]]; then
        __install_tags+=('themes')
    fi

    __ansible_tags=$(printf "%s," "${__install_tags[@]}")

fi

# deactivate || true
export _server_workspace_tmp_dir="${_server_workspace_tmp_dir:-${HOME}/.tmp}"
export DEFAULT_ROLES_PATH="${_server_workspace_tmp_dir}/roles"
export ANSIBLE_ROLES_PATH="${DEFAULT_ROLES_PATH}"
export ANSIBLE_COLLECTIONS_PATH="${_server_workspace_tmp_dir}/collections"
export ANSIBLE_INVENTORY="${_server_workspace_tmp_dir}/server_workspace_inventory.yml"
export MMC_SERVER_WORKSPACE_JSON="${MMC_SERVER_WORKSPACE_JSON:-${_server_workspace_tmp_dir}/server_workspace.json}"
export _server_workspace_venv_directory="${_server_workspace_tmp_dir}/sw_venv"

echo "Server Workspace :: ${_server_workspace_tmp_dir}"
mkdir -p "${_server_workspace_tmp_dir}"

# shellcheck source=/dev/null
if [[ -z ${VIRTUAL_ENV} ]]; then
    export PATH="${HOME}/.local/bin:${PATH}"
    if [[ ! -d "${_server_workspace_venv_directory}" ]]; then
        $(readlink -f "$(which "$(which_os_python)")") -m venv "${_server_workspace_venv_directory}"
    fi
    if [[ -f "${_server_workspace_venv_directory}/local/bin/activate" ]]; then
        source "${_server_workspace_venv_directory}/local/bin/activate"
    else
        source "${_server_workspace_venv_directory}/bin/activate"
    fi
fi

echo ""
echo "Python :: $(python --version)"
echo "Virtual Env :: ${VIRTUAL_ENV}"
echo "Working dir :: ${PWD}"
pip3 install --upgrade pip
pip3 install setuptools-rust wheel setuptools --upgrade
pip3 install ansible hvac --upgrade

ansible-galaxy collection install git+https://github.com/arpanrec/arpanrec.nebula.git,1.6.0

ansible-galaxy collection install git+https://github.com/ansible-collections/community.general.git,9.4.0
ansible-galaxy collection install git+https://github.com/ansible-collections/community.crypto.git,2.22.2
ansible-galaxy collection install git+https://github.com/ansible-collections/amazon.aws.git,8.2.1
ansible-galaxy collection install git+https://github.com/ansible-collections/community.docker.git,4.0.0
ansible-galaxy collection install git+https://github.com/ansible-collections/ansible.posix.git,1.6.2
ansible-galaxy collection install git+https://github.com/kewlfft/ansible-aur.git,v0.11.1

ansible-galaxy role install git+https://github.com/geerlingguy/ansible-role-docker.git,7.4.1,geerlingguy.docker

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

echo "Creating ${ANSIBLE_INVENTORY}"
tee "${ANSIBLE_INVENTORY}" >/dev/null <<EOF
---
all:
    children:
        server_workspace:
            hosts:
                localhost:
            vars:
                ansible_become: false
    hosts:
        localhost:
            ansible_connection: local
            ansible_python_interpreter: "$(which python3)"
EOF

cd "${HOME}" || exit 1

if [[ -n ${__ansible_tags} && ${__ansible_tags} != "," && -z $* ]]; then
    ansible-playbook arpanrec.nebula.server_workspace --extra-vars "@${MMC_SERVER_WORKSPACE_JSON}" \
        --tags "${__ansible_tags::-1}"
elif [[ -z ${__ansible_tags} && -n $* ]]; then
    ansible-playbook arpanrec.nebula.server_workspace --extra-vars "@${MMC_SERVER_WORKSPACE_JSON}" "$@"
fi
