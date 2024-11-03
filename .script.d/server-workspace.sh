#!/usr/bin/env bash
set -euo pipefail

if [[ $(id -u) -eq 0 ]]; then
    printf "\n\n================================================================================\n"
    echo "server-workspace: Root user detected, Please run this script as a non-root user, Exiting"
    echo "--------------------------------------------------------------------------------"
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
    printf "\n\n================================================================================\n"
    echo "server-workspace: Supported Python version not found, Only Python3.6+ >< 4 is supported, Exiting"
    echo "--------------------------------------------------------------------------------"
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
else
    printf "\n\n================================================================================\n"
    echo "server-workspace: Running with custom tags :: $*"
    echo "--------------------------------------------------------------------------------"
fi

# deactivate || true
export SERVER_WORKSPACE_TMP_DIR="${SERVER_WORKSPACE_TMP_DIR:-${HOME}/.tmp}"
export DEFAULT_ROLES_PATH="${DEFAULT_ROLES_PATH:-${SERVER_WORKSPACE_TMP_DIR}/roles}"
export ANSIBLE_ROLES_PATH="${ANSIBLE_ROLES_PATH:-${DEFAULT_ROLES_PATH}}"
export ANSIBLE_COLLECTIONS_PATH="${ANSIBLE_COLLECTIONS_PATH:-${SERVER_WORKSPACE_TMP_DIR}/collections}"
export ANSIBLE_INVENTORY="${ANSIBLE_INVENTORY:-${SERVER_WORKSPACE_TMP_DIR}/inventory.yml}"
export SERVER_WORKSPACE_EXTRA_VARS_JSON="${SERVER_WORKSPACE_EXTRA_VARS_JSON:-${SERVER_WORKSPACE_TMP_DIR}/server_workspace.json}"
export NEBULA_VERSION="${NEBULA_VERSION:-1.9.0}"
export _server_workspace_venv_directory="${SERVER_WORKSPACE_TMP_DIR}/sw_venv"
export PATH="${HOME}/.local/bin:${PATH}"

printf "\n\n================================================================================\n"
echo "server-workspace: Creating SERVER_WORKSPACE_TMP_DIR at ${SERVER_WORKSPACE_TMP_DIR}"
echo "--------------------------------------------------------------------------------"
mkdir -p "${SERVER_WORKSPACE_TMP_DIR}" "${DEFAULT_ROLES_PATH}" \
    "${ANSIBLE_ROLES_PATH}" "${ANSIBLE_COLLECTIONS_PATH}" \
    "$(dirname "${ANSIBLE_INVENTORY}")" "$(dirname "${SERVER_WORKSPACE_EXTRA_VARS_JSON}")"

if [[ -z "${VIRTUAL_ENV+x}" ]]; then
    printf "\n\n================================================================================\n"
    echo "server-workspace: Virtual environment is not activated"
    echo "--------------------------------------------------------------------------------"
else
    printf "\n\n================================================================================\n"
    echo "server-workspace: Already in python virtual environment ${VIRTUAL_ENV}, deactivate and run again, exiting"
    echo "--------------------------------------------------------------------------------"
    exit 1
fi

# shellcheck source=/dev/null
if [[ ! -d "${_server_workspace_venv_directory}" ]]; then
    $(readlink -f "$(which "$(which_os_python)")") -m venv "${_server_workspace_venv_directory}"
    printf "\n\n================================================================================\n"
    echo "server-workspace: Virtual Environment created at ${_server_workspace_venv_directory}"
    echo "--------------------------------------------------------------------------------"
else
    printf "\n\n================================================================================\n"
    echo "server-workspace: Virtual Environment already exists at ${_server_workspace_venv_directory}"
    echo "--------------------------------------------------------------------------------"
fi

if [[ -f "${_server_workspace_venv_directory}/local/bin/activate" ]]; then
    printf "\n\n================================================================================\n"
    echo "server-workspace: Activating ${_server_workspace_venv_directory}/local/bin/activate"
    echo "--------------------------------------------------------------------------------"
    # shellcheck source=/dev/null
    source "${_server_workspace_venv_directory}/local/bin/activate"
else
    printf "\n\n================================================================================\n"
    echo "server-workspace: Activating ${_server_workspace_venv_directory}/bin/activate"
    echo "--------------------------------------------------------------------------------"
    # shellcheck source=/dev/null
    source "${_server_workspace_venv_directory}/bin/activate"
fi

printf "\n\n================================================================================\n"
echo "server-workspace: Python :: $(python --version)"
echo "server-workspace: Virtual Env :: ${VIRTUAL_ENV}"
echo "server-workspace: Working dir :: ${PWD}"
echo "server-workspace: Installing ansible, hvac and arpanrec.nebula"
echo "--------------------------------------------------------------------------------"
pip3 install --upgrade pip
pip3 install setuptools-rust wheel setuptools --upgrade
pip3 install ansible hvac --upgrade

curl "https://raw.githubusercontent.com/arpanrec/arpanrec.nebula/refs/tags/${NEBULA_VERSION}/requirements.yml" \
    -o "/tmp/requirements-${NEBULA_VERSION}.yml"
ansible-galaxy install -r "/tmp/requirements-${NEBULA_VERSION}.yml"
ansible-galaxy collection install "git+https://github.com/arpanrec/arpanrec.nebula.git,${NEBULA_VERSION}"

printf "\n\n================================================================================\n"
echo "server-workspace: SERVER_WORKSPACE_EXTRA_VARS_JSON :: ${SERVER_WORKSPACE_EXTRA_VARS_JSON}"
echo "--------------------------------------------------------------------------------"
if [[ ! -f "${SERVER_WORKSPACE_EXTRA_VARS_JSON}" ]]; then
    printf "\n\n================================================================================\n"
    echo "server-workspace: Creating ${SERVER_WORKSPACE_EXTRA_VARS_JSON}"
    echo "--------------------------------------------------------------------------------"
    echo "Creating directory $(dirname "${SERVER_WORKSPACE_EXTRA_VARS_JSON}")"
    mkdir -p "$(dirname "${SERVER_WORKSPACE_EXTRA_VARS_JSON}")"
    echo "{}" >"${SERVER_WORKSPACE_EXTRA_VARS_JSON}"
else
    printf "\n\n================================================================================\n"
    echo "server-workspace: ${SERVER_WORKSPACE_EXTRA_VARS_JSON} exists"
    echo "--------------------------------------------------------------------------------"
fi

printf "\n\n================================================================================\n"
echo "server-workspace: Creating ansible inventory yaml file. ANSIBLE_INVENTORY :: ${ANSIBLE_INVENTORY}"
echo "--------------------------------------------------------------------------------"
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
    ansible-playbook arpanrec.nebula.server_workspace --extra-vars "@${SERVER_WORKSPACE_EXTRA_VARS_JSON}" \
        --tags "${__ansible_tags::-1}"
elif [[ -z ${__ansible_tags} && -n $* ]]; then
    ansible-playbook arpanrec.nebula.server_workspace --extra-vars "@${SERVER_WORKSPACE_EXTRA_VARS_JSON}" "$@"
fi
