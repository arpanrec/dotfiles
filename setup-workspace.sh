#!/usr/bin/env bash
set -euo pipefail

echo "Starting"

export NEBULA_TMP_DIR="${NEBULA_TMP_DIR:-"${HOME}/.tmp"}"

export SERVER_WORKSPACE_LOCK_FILE="${NEBULA_TMP_DIR}/setup-workspace.lock"

if [[ -f "${SERVER_WORKSPACE_LOCK_FILE}" ]]; then
    echo "Lock file ${SERVER_WORKSPACE_LOCK_FILE} exists, Exiting"
    exit 1
else
    echo "Creating lock file ${SERVER_WORKSPACE_LOCK_FILE}"
    mkdir -p "$(dirname "${SERVER_WORKSPACE_LOCK_FILE}")"
    touch "${SERVER_WORKSPACE_LOCK_FILE}"
fi

if [[ "$(id -u)" -eq 0 || "${HOME}" == "/root" ]]; then
    echo "Root user detected, Please run this script as a non-root user, Exiting"
    exit 1
fi

if [[ -z "${VIRTUAL_ENV:-}" ]]; then
    echo "Virtual environment is not activated"
else
    echo "Already in python virtual environment ${VIRTUAL_ENV}, deactivate and run again, exiting"
    exit 1
fi

which_os_python() {
    # Simply don't use python, /usr/bin/python etc, try to find the highest version of python3
    declare -a PYTHON_VERSIONS=("python3.14" "python3.13" "python3.12" "python3.11")

    for python_version in "${PYTHON_VERSIONS[@]}"; do
        if command -v "${python_version}" &>/dev/null; then
            echo "${python_version}"
            return
        fi
    done
    echo "Supported Python version not found, Only Python3.6+ >< 4 is supported, Exiting"
    exit 1
}

if [[ -z $* ]]; then

    __install_tags=()

    read -n1 -s -r -p 'Enter "Y" to install node js (Press any other key to Skip*) : ' install_node_js
    if [[ "${install_node_js}" == "Y" || "${install_node_js}" == "y" ]]; then
        echo "Nodejs installation selected"
        __install_tags+=('nodejs')
    else
        echo "Skipping nodejs installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install go (Press any other key to Skip*) : ' install_go
    if [[ "${install_go}" == "Y" || "${install_go}" == "y" ]]; then
        echo "Go installation selected"
        __install_tags+=('go')
    else
        echo "Skipping go installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install Oracle JDK (Press any other key to Skip*) : ' install_java
    if [[ "${install_java}" == "Y" || "${install_java}" == "y" ]]; then
        echo "Java installation selected"
        __install_tags+=('java')
    else
        echo "Skipping Java installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install Vault (Press any other key to Skip*) : ' install_vault
    if [[ "${install_vault}" == "Y" || "${install_vault}" == "y" ]]; then
        echo "Vault installation selected"
        __install_tags+=('vault')
    else
        echo "Skipping Vault installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install Terraform (Press any other key to Skip*) : ' install_terraform
    if [[ "${install_terraform}" == "Y" || "${install_terraform}" == "y" ]]; then
        echo "Terraform installation selected"
        __install_tags+=('terraform')
    else
        echo "Skipping Terraform installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install pulumi (Press any other key to Skip*) : ' install_pulumi
    if [[ "${install_pulumi}" == "Y" || "${install_pulumi}" == "y" ]]; then
        echo "Pulumi installation selected"
        __install_tags+=('pulumi')
    else
        echo "Skipping Pulumi installation"
    fi

    read -n1 -s -r -p 'Enter "Y" to install Bitwarden SDK (Press any other key to Skip*) : ' install_bitwarden_sdk
    if [[ "${install_bitwarden_sdk}" == "Y" || "${install_bitwarden_sdk}" == "y" ]]; then
        echo "Bitwarden SDK installation selected"
        __install_tags+=('bws')
    else
        echo "Skipping Bitwarden SDK installation"
    fi

    __ansible_tags=$(printf "%s," "${__install_tags[@]}")
    echo "Running with default tags :: ${__ansible_tags::-1}"
    read -n1 -s -r -p 'Press any key to continue or Ctrl+C to exit' continue_script
    if [[ "${continue_script}" == "" ]]; then
        echo "Continuing with default tags :: ${__ansible_tags::-1}"
    else
        echo "Exiting"
        exit 1
    fi
else
    echo "Running with custom tags :: $*"
fi

export PATH="${HOME}/.local/bin:${PATH}"

export NEBULA_VERSION="${NEBULA_VERSION:-"1.14.63"}"
export NEBULA_VENV_DIR="${NEBULA_VENV_DIR:-"${NEBULA_TMP_DIR}/venv"}"
export NEBULA_EXTRA_VARS_JSON_FILE="${NEBULA_EXTRA_VARS_JSON_FILE:-"${NEBULA_TMP_DIR}/extra_vars.json"}"
export NEBULA_REQUIREMENTS_FILE="${NEBULA_REQUIREMENTS_FILE:-"${NEBULA_TMP_DIR}/requirements-${NEBULA_VERSION}.yml"}"

echo "
NEBULA_TMP_DIR: ${NEBULA_TMP_DIR}
NEBULA_VERSION: ${NEBULA_VERSION}
NEBULA_VENV_DIR: ${NEBULA_VENV_DIR}
NEBULA_EXTRA_VARS_JSON_FILE: ${NEBULA_EXTRA_VARS_JSON_FILE}
NEBULA_REQUIREMENTS_FILE: ${NEBULA_REQUIREMENTS_FILE}"

export DEFAULT_ROLES_PATH="${DEFAULT_ROLES_PATH:-"${NEBULA_TMP_DIR}/roles"}"
export ANSIBLE_ROLES_PATH="${ANSIBLE_ROLES_PATH:-"${DEFAULT_ROLES_PATH}"}"
export ANSIBLE_COLLECTIONS_PATH="${ANSIBLE_COLLECTIONS_PATH:-"${NEBULA_TMP_DIR}/collections"}"
export ANSIBLE_INVENTORY="${ANSIBLE_INVENTORY:-"${NEBULA_TMP_DIR}/inventory.yml"}"

echo "
DEFAULT_ROLES_PATH: ${DEFAULT_ROLES_PATH}
ANSIBLE_ROLES_PATH: ${ANSIBLE_ROLES_PATH}
ANSIBLE_COLLECTIONS_PATH: ${ANSIBLE_COLLECTIONS_PATH}
ANSIBLE_INVENTORY: ${ANSIBLE_INVENTORY}"

echo Creating NEBULA_TMP_DIR at "${NEBULA_TMP_DIR}" "$(dirname "${NEBULA_EXTRA_VARS_JSON_FILE}")" \
    "${DEFAULT_ROLES_PATH}" "${ANSIBLE_ROLES_PATH}" "${ANSIBLE_COLLECTIONS_PATH}" "$(dirname "${ANSIBLE_INVENTORY}")"
mkdir -p "${NEBULA_TMP_DIR}" "$(dirname "${NEBULA_EXTRA_VARS_JSON_FILE}")" \
    "${DEFAULT_ROLES_PATH}" "${ANSIBLE_ROLES_PATH}" "${ANSIBLE_COLLECTIONS_PATH}" "$(dirname "${ANSIBLE_INVENTORY}")"

# shellcheck source=/dev/null
if [[ ! -d "${NEBULA_VENV_DIR}" ]]; then
    $(readlink -f "$(which "$(which_os_python)")") -m venv "${NEBULA_VENV_DIR}"
    echo "Virtual Environment created at ${NEBULA_VENV_DIR}"
else
    echo "Virtual Environment already exists at ${NEBULA_VENV_DIR}"
fi

if [[ -f "${NEBULA_VENV_DIR}/local/bin/activate" ]]; then
    echo "Activating ${NEBULA_VENV_DIR}/local/bin/activate"
    # shellcheck source=/dev/null
    source "${NEBULA_VENV_DIR}/local/bin/activate"
else
    echo "Activating ${NEBULA_VENV_DIR}/bin/activate"
    # shellcheck source=/dev/null
    source "${NEBULA_VENV_DIR}/bin/activate"
fi

echo "
Python :: $(python --version)
Virtual Env :: ${VIRTUAL_ENV}
Working dir :: ${PWD}
Installing ansible, hvac and arpanrec.nebula"
pip3 install --upgrade pip
pip3 install setuptools-rust wheel setuptools --upgrade
pip3 install ansible hvac --upgrade

if [[ ! -f "${NEBULA_REQUIREMENTS_FILE}" ]]; then
    echo "Downloading ${NEBULA_REQUIREMENTS_FILE}"
    mkdir -p "$(dirname "${NEBULA_REQUIREMENTS_FILE}")"
    curl -sSL --connect-timeout 10 --max-time 10 \
        "https://raw.githubusercontent.com/arpanrec/arpanrec.nebula/refs/tags/${NEBULA_VERSION}/requirements.yml" \
        -o "${NEBULA_REQUIREMENTS_FILE}"
else
    echo "Requirements file ${NEBULA_REQUIREMENTS_FILE} exists"
fi

ansible-galaxy install -r "${NEBULA_REQUIREMENTS_FILE}"
ansible-galaxy collection install git+https://github.com/arpanrec/arpanrec.nebula.git,"${NEBULA_VERSION}"

echo "NEBULA_EXTRA_VARS_JSON_FILE :: ${NEBULA_EXTRA_VARS_JSON_FILE}"
if [[ ! -f "${NEBULA_EXTRA_VARS_JSON_FILE}" ]]; then
    echo "Creating ${NEBULA_EXTRA_VARS_JSON_FILE}"
    echo "Creating directory $(dirname "${NEBULA_EXTRA_VARS_JSON_FILE}")"
    mkdir -p "$(dirname "${NEBULA_EXTRA_VARS_JSON_FILE}")"
    echo "{}" >"${NEBULA_EXTRA_VARS_JSON_FILE}"
else
    echo "${NEBULA_EXTRA_VARS_JSON_FILE} exists"
fi

echo "Creating ansible inventory yaml file. ANSIBLE_INVENTORY :: ${ANSIBLE_INVENTORY}"
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
    echo "Not sure what to do, Exiting"
    exit 1
fi

echo "Removing lock file ${SERVER_WORKSPACE_LOCK_FILE}"
rm -f "${SERVER_WORKSPACE_LOCK_FILE}"

echo "Completed"
