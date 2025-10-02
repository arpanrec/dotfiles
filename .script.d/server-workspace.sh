#!/usr/bin/env bash
set -euo pipefail

log_message() {
    printf "\n\n================================================================================\n %s \
server-workspace: %s\n--------------------------------------------------------------------------------\n\n" "$(date)" "$*"
}
export -f log_message

log_message "Starting"

export NEBULA_TMP_DIR="${NEBULA_TMP_DIR:-"${HOME}/.tmp"}"

export SERVER_WORKSPACE_LOCK_FILE="${NEBULA_TMP_DIR}/server-workspace.lock"

if [[ -f "${SERVER_WORKSPACE_LOCK_FILE}" ]]; then
    log_message "Lock file ${SERVER_WORKSPACE_LOCK_FILE} exists, Exiting"
    exit 1
else
    log_message "Creating lock file ${SERVER_WORKSPACE_LOCK_FILE}"
    mkdir -p "$(dirname "${SERVER_WORKSPACE_LOCK_FILE}")"
    touch "${SERVER_WORKSPACE_LOCK_FILE}"
fi

if [[ "$(id -u)" -eq 0 || "${HOME}" == "/root" ]]; then
    log_message "Root user detected, Please run this script as a non-root user, Exiting"
    exit 1
fi

if [[ -z "${VIRTUAL_ENV:-}" ]]; then
    log_message "Virtual environment is not activated"
else
    log_message "Already in python virtual environment ${VIRTUAL_ENV}, deactivate and run again, exiting"
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
    log_message "Supported Python version not found, Only Python3.6+ >< 4 is supported, Exiting"
    exit 1
}

if [[ -z $* ]]; then

    __install_tags=()

    read -n1 -s -r -p 'Enter "Y" to install node js (Press any other key to Skip*) : ' install_node_js
    if [[ "${install_node_js}" == "Y" || "${install_node_js}" == "y" ]]; then
        log_message "Nodejs installation selected"
        __install_tags+=('nodejs')
    else
        log_message "Skipping nodejs installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install go (Press any other key to Skip*) : ' install_go
    if [[ "${install_go}" == "Y" || "${install_go}" == "y" ]]; then
        log_message "Go installation selected"
        __install_tags+=('go')
    else
        log_message "Skipping go installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install Oracle JDK17 (Press any other key to Skip*) : ' install_java
    if [[ "${install_java}" == "Y" || "${install_java}" == "y" ]]; then
        log_message "Java installation selected"
        __install_tags+=('java')
    else
        log_message "Skipping Java installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to terminal tools (Press any other key to Skip*) : ' download_terminal
    if [[ "${download_terminal}" == "Y" || "${download_terminal}" == "y" ]]; then
        log_message "Terminal tools installation selected"
        __install_tags+=('terminal')
    else
        log_message "Skipping terminal tools installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install Vault (Press any other key to Skip*) : ' install_vault
    if [[ "${install_vault}" == "Y" || "${install_vault}" == "y" ]]; then
        log_message "Vault installation selected"
        __install_tags+=('vault')
    else
        log_message "Skipping Vault installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install Terraform (Press any other key to Skip*) : ' install_terraform
    if [[ "${install_terraform}" == "Y" || "${install_terraform}" == "y" ]]; then
        log_message "Terraform installation selected"
        __install_tags+=('terraform')
    else
        log_message "Skipping Terraform installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install pulumi (Press any other key to Skip*) : ' install_pulumi
    if [[ "${install_pulumi}" == "Y" || "${install_pulumi}" == "y" ]]; then
        log_message "Pulumi installation selected"
        __install_tags+=('pulumi')
    else
        log_message "Skipping Pulumi installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install Bitwarden SDK (Press any other key to Skip*) : ' install_bitwarden_sdk
    if [[ "${install_bitwarden_sdk}" == "Y" || "${install_bitwarden_sdk}" == "y" ]]; then
        log_message "Bitwarden SDK installation selected"
        __install_tags+=('bws')
    else
        log_message "Skipping Bitwarden SDK installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install Bitwarden (Press any other key to Skip*) : ' install_bitwarden_app_image
    if [[ "${install_bitwarden_app_image}" == "Y" || "${install_bitwarden_app_image}" == "y" ]]; then
        log_message "Bitwarden installation selected"
        __install_tags+=('bitwarden_desktop')
    else
        log_message "Skipping Bitwarden installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install Mattermost (Press any other key to Skip*) : ' install_mattermost
    if [[ "${install_mattermost}" == "Y" || "${install_mattermost}" == "y" ]]; then
        log_message "Mattermost installation selected"
        __install_tags+=('mattermost_desktop')
    else
        log_message "Skipping Mattermost installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install Telegram (Press any other key to Skip*) : ' install_telegram_desktop
    if [[ "${install_telegram_desktop}" == "Y" || "${install_telegram_desktop}" == "y" ]]; then
        log_message "Telegram installation selected"
        __install_tags+=('telegram_desktop')
    else
        log_message "Skipping Telegram installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install Postman (Press any other key to Skip*) : ' install_postman
    if [[ "${install_postman}" == "Y" || "${install_postman}" == "y" ]]; then
        log_message "Postman installation selected"
        __install_tags+=('postman')
    else
        log_message "Skipping Postman installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install Visual Studio Code (Press any other key to Skip*) : ' install_vscode
    if [[ "${install_vscode}" == "Y" || "${install_vscode}" == "y" ]]; then
        log_message "Visual Studio Code installation selected"
        __install_tags+=('code')
    else
        log_message "Skipping Visual Studio Code installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install gnome (Press any other key to Skip*) : ' install_gnome
    if [[ "${install_gnome}" == "Y" || "${install_gnome}" == "y" ]]; then
        log_message "Gnome installation selected"
        __install_tags+=('gnome')
    else
        log_message "Skipping Gnome installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to download themes (Press any other key to Skip*) : ' download_themes
    if [[ "${download_themes}" == "Y" || "${download_themes}" == "y" ]]; then
        log_message "Themes installation selected"
        __install_tags+=('themes')
    else
        log_message "Skipping Themes installation"
    fi

    __ansible_tags=$(printf "%s," "${__install_tags[@]}")
    log_message "Running with default tags :: ${__ansible_tags::-1}"
    read -n1 -s -r -p 'Press any key to continue or Ctrl+C to exit' continue_script
    if [[ "${continue_script}" == "" ]]; then
        log_message "Continuing with default tags :: ${__ansible_tags::-1}"
    else
        log_message "Exiting"
        exit 1
    fi
else
    log_message "Running with custom tags :: $*"
fi

export PATH="${HOME}/.local/bin:${PATH}"

export NEBULA_VERSION="${NEBULA_VERSION:-"1.14.42"}"
export NEBULA_VENV_DIR="${NEBULA_VENV_DIR:-"${NEBULA_TMP_DIR}/venv"}"
export NEBULA_EXTRA_VARS_JSON_FILE="${NEBULA_EXTRA_VARS_JSON_FILE:-"${NEBULA_TMP_DIR}/extra_vars.json"}"
export NEBULA_REQUIREMENTS_FILE="${NEBULA_REQUIREMENTS_FILE:-"${NEBULA_TMP_DIR}/requirements-${NEBULA_VERSION}.yml"}"

log_message "
NEBULA_TMP_DIR: ${NEBULA_TMP_DIR}
NEBULA_VERSION: ${NEBULA_VERSION}
NEBULA_VENV_DIR: ${NEBULA_VENV_DIR}
NEBULA_EXTRA_VARS_JSON_FILE: ${NEBULA_EXTRA_VARS_JSON_FILE}
NEBULA_REQUIREMENTS_FILE: ${NEBULA_REQUIREMENTS_FILE}"

export DEFAULT_ROLES_PATH="${DEFAULT_ROLES_PATH:-"${NEBULA_TMP_DIR}/roles"}"
export ANSIBLE_ROLES_PATH="${ANSIBLE_ROLES_PATH:-"${DEFAULT_ROLES_PATH}"}"
export ANSIBLE_COLLECTIONS_PATH="${ANSIBLE_COLLECTIONS_PATH:-"${NEBULA_TMP_DIR}/collections"}"
export ANSIBLE_INVENTORY="${ANSIBLE_INVENTORY:-"${NEBULA_TMP_DIR}/inventory.yml"}"

log_message "
DEFAULT_ROLES_PATH: ${DEFAULT_ROLES_PATH}
ANSIBLE_ROLES_PATH: ${ANSIBLE_ROLES_PATH}
ANSIBLE_COLLECTIONS_PATH: ${ANSIBLE_COLLECTIONS_PATH}
ANSIBLE_INVENTORY: ${ANSIBLE_INVENTORY}"

log_message Creating NEBULA_TMP_DIR at "${NEBULA_TMP_DIR}" "$(dirname "${NEBULA_EXTRA_VARS_JSON_FILE}")" \
    "${DEFAULT_ROLES_PATH}" "${ANSIBLE_ROLES_PATH}" "${ANSIBLE_COLLECTIONS_PATH}" "$(dirname "${ANSIBLE_INVENTORY}")"
mkdir -p "${NEBULA_TMP_DIR}" "$(dirname "${NEBULA_EXTRA_VARS_JSON_FILE}")" \
    "${DEFAULT_ROLES_PATH}" "${ANSIBLE_ROLES_PATH}" "${ANSIBLE_COLLECTIONS_PATH}" "$(dirname "${ANSIBLE_INVENTORY}")"

# shellcheck source=/dev/null
if [[ ! -d "${NEBULA_VENV_DIR}" ]]; then
    $(readlink -f "$(which "$(which_os_python)")") -m venv "${NEBULA_VENV_DIR}"
    log_message "Virtual Environment created at ${NEBULA_VENV_DIR}"
else
    log_message "Virtual Environment already exists at ${NEBULA_VENV_DIR}"
fi

if [[ -f "${NEBULA_VENV_DIR}/local/bin/activate" ]]; then
    log_message "Activating ${NEBULA_VENV_DIR}/local/bin/activate"
    # shellcheck source=/dev/null
    source "${NEBULA_VENV_DIR}/local/bin/activate"
else
    log_message "Activating ${NEBULA_VENV_DIR}/bin/activate"
    # shellcheck source=/dev/null
    source "${NEBULA_VENV_DIR}/bin/activate"
fi

log_message "
Python :: $(python --version)
Virtual Env :: ${VIRTUAL_ENV}
Working dir :: ${PWD}
Installing ansible, hvac and arpanrec.nebula"
pip3 install --upgrade pip
pip3 install setuptools-rust wheel setuptools --upgrade
pip3 install ansible hvac konsave --upgrade

if [[ ! -f "${NEBULA_REQUIREMENTS_FILE}" ]]; then
    log_message "Downloading ${NEBULA_REQUIREMENTS_FILE}"
    mkdir -p "$(dirname "${NEBULA_REQUIREMENTS_FILE}")"
    curl -sSL --connect-timeout 10 --max-time 10 \
        "https://raw.githubusercontent.com/arpanrec/arpanrec.nebula/refs/tags/${NEBULA_VERSION}/requirements.yml" \
        -o "${NEBULA_REQUIREMENTS_FILE}"
else
    log_message "Requirements file ${NEBULA_REQUIREMENTS_FILE} exists"
fi

ansible-galaxy install -r "${NEBULA_REQUIREMENTS_FILE}"
ansible-galaxy collection install arpanrec.nebula:"${NEBULA_VERSION}"

log_message "NEBULA_EXTRA_VARS_JSON_FILE :: ${NEBULA_EXTRA_VARS_JSON_FILE}"
if [[ ! -f "${NEBULA_EXTRA_VARS_JSON_FILE}" ]]; then
    log_message "Creating ${NEBULA_EXTRA_VARS_JSON_FILE}"
    echo "Creating directory $(dirname "${NEBULA_EXTRA_VARS_JSON_FILE}")"
    mkdir -p "$(dirname "${NEBULA_EXTRA_VARS_JSON_FILE}")"
    echo "{}" >"${NEBULA_EXTRA_VARS_JSON_FILE}"
else
    log_message "${NEBULA_EXTRA_VARS_JSON_FILE} exists"
fi

log_message "Creating ansible inventory yaml file. ANSIBLE_INVENTORY :: ${ANSIBLE_INVENTORY}"
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

if [[ -n "${__ansible_tags:-}" && "${__ansible_tags:-}" != "," && -z $* ]]; then
    ansible-playbook arpanrec.nebula.server_workspace --extra-vars "@${NEBULA_EXTRA_VARS_JSON_FILE}" \
        --tags "${__ansible_tags::-1}"
elif [[ -z "${__ansible_tags:-}" && -n $* ]]; then
    ansible-playbook arpanrec.nebula.server_workspace --extra-vars "@${NEBULA_EXTRA_VARS_JSON_FILE}" "$@"
else
    log_message "Not sure what to do, Exiting"
    exit 1
fi

log_message "Removing lock file ${SERVER_WORKSPACE_LOCK_FILE}"
rm -f "${SERVER_WORKSPACE_LOCK_FILE}"

log_message "Completed"
