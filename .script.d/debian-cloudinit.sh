#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND="noninteractive"

log_message() {
    printf "\n\n================================================================================\n %s \
debian-cloudinit: \
%s\n--------------------------------------------------------------------------------\n\n" "$(date)" "$*"
}

export -f log_message

log_message "Starting"

if [[ -z "${VIRTUAL_ENV:-}" ]]; then
    log_message "Virtual environment is not activated"
else
    log_message "Already in python virtual environment ${VIRTUAL_ENV}, deactivate and run again, exiting"
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    log_message "Please run as root, exiting"
    exit 1
else
    log_message "Running as root"
fi

if [ "${HOME}" != "/root" ]; then
    log_message "HOME is not set to /root, exiting"
    exit 1
else
    log_message "debian-cloudinit: HOME is set to /root"
fi

if [ ! -f /etc/environment ]; then
    log_message "Creating /etc/environment"
    touch /etc/environment
else
    log_message "/etc/environment already exists"
fi

export CLOUD_INIT_USER="${CLOUD_INIT_USER:-"cloudinit"}"
export CLOUD_INIT_USE_SSH_PUB="${CLOUD_INIT_USE_SSH_PUB:-"ecdsa-sha2-nistp256 \
AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJXzoi1QAbLmxnyudx+7Dm+FGTYU+TP02MTtxqq9w82Rm2kIDtGf4xVGxaidYEP/\
WcgpOHacjKDa7p2skBYljmk= arpan.rec@gmail.com"}"

log_message "
CLOUD_INIT_USER: ${CLOUD_INIT_USER}
CLOUD_INIT_USE_SSH_PUB: ${CLOUD_INIT_USE_SSH_PUB}"

current_hostname="$(hostname)"

if [ "${current_hostname}" == "localhost" ]; then
    export CLOUD_INIT_HOSTNAME="${CLOUD_INIT_HOSTNAME:-"cloudinit"}"
else
    export CLOUD_INIT_HOSTNAME="${CLOUD_INIT_HOSTNAME:-"${current_hostname}"}"
fi

export CLOUD_INIT_COPY_ROOT_SSH_KEYS="${CLOUD_INIT_COPY_ROOT_SSH_KEYS:-"false"}"
export CLOUD_INIT_GROUP="${CLOUD_INIT_GROUP:-"${CLOUD_INIT_USER:-"cloudinit"}"}"
export CLOUD_INIT_IS_DEV_MACHINE="${CLOUD_INIT_IS_DEV_MACHINE:-"false"}"
export CLOUD_INIT_DOMAIN="${CLOUD_INIT_DOMAIN:-"cloudinit"}"
export CLOUD_INIT_INSTALL_DOTFILES="${CLOUD_INIT_INSTALL_DOTFILES:-"true"}"
export CLOUD_INIT_INSTALL_DOCKER="${CLOUD_INIT_INSTALL_DOCKER:-"false"}"

log_message "
CLOUD_INIT_COPY_ROOT_SSH_KEYS: ${CLOUD_INIT_COPY_ROOT_SSH_KEYS}
CLOUD_INIT_GROUP: ${CLOUD_INIT_GROUP}
CLOUD_INIT_IS_DEV_MACHINE: ${CLOUD_INIT_IS_DEV_MACHINE}
CLOUD_INIT_HOSTNAME: ${CLOUD_INIT_HOSTNAME}
CLOUD_INIT_DOMAIN: ${CLOUD_INIT_DOMAIN}
CLOUD_INIT_INSTALL_DOTFILES: ${CLOUD_INIT_INSTALL_DOTFILES}
CLOUD_INIT_INSTALL_DOCKER: ${CLOUD_INIT_INSTALL_DOCKER}"

if [ -z "${CLOUD_INIT_USE_SSH_PUB}" ]; then
    log_message "CLOUD_INIT_USE_SSH_PUB is not set, exiting"
    exit 1
else
    log_message "CLOUD_INIT_USE_SSH_PUB is set as ${CLOUD_INIT_USE_SSH_PUB}"
fi

if [[ ! "${CLOUD_INIT_COPY_ROOT_SSH_KEYS}" =~ ^true|false$ ]]; then
    log_message "CLOUD_INIT_COPY_ROOT_SSH_KEYS must be a boolean (true|false), exiting"
    exit 1
else
    log_message "CLOUD_INIT_COPY_ROOT_SSH_KEYS is set as ${CLOUD_INIT_COPY_ROOT_SSH_KEYS}"
fi

if [[ ! "${CLOUD_INIT_IS_DEV_MACHINE}" =~ ^true|false$ ]]; then
    log_message "CLOUD_INIT_IS_DEV_MACHINE must be a boolean (true|false), exiting"
    exit 1
else
    if [ "${CLOUD_INIT_IS_DEV_MACHINE}" = true ]; then
        log_message "server_workspace will be run with all tags in dev mode"
    else
        log_message "server_workspace will be run without java, go, terraform, vault, nodejs, bws, pulumi tags"
    fi
fi

if [[ ! "${CLOUD_INIT_INSTALL_DOTFILES}" =~ ^true|false$ ]]; then
    log_message "CLOUD_INIT_INSTALL_DOTFILES must be a boolean (true|false), exiting"
    exit 1
else
    if [ "${CLOUD_INIT_INSTALL_DOTFILES}" = true ]; then
        log_message "Dotfiles will be installed/reset"
    else
        log_message "Dotfiles will not be installed/reset"
    fi
fi

if [[ ! "${CLOUD_INIT_INSTALL_DOCKER}" =~ ^true|false$ ]]; then
    log_message "CLOUD_INIT_INSTALL_DOCKER must be a boolean (true|false), exiting"
    exit 1
else
    if [ "${CLOUD_INIT_INSTALL_DOCKER}" = true ]; then
        log_message "Docker will be installed"
    else
        log_message "Docker will not be installed"
    fi
fi

export CLOUD_INIT_LOCK_FILE="/tmp/debian-cloudinit.lock"

if [ -f "${CLOUD_INIT_LOCK_FILE}" ] || [ -d "${CLOUD_INIT_LOCK_FILE}" ] || [ -L "${CLOUD_INIT_LOCK_FILE}" ]; then
    log_message "Lock file ${CLOUD_INIT_LOCK_FILE} exists, If you are sure then delete it and run again, exiting"
    exit 1
else
    log_message "Creating lock file ${CLOUD_INIT_LOCK_FILE}"
    touch "${CLOUD_INIT_LOCK_FILE}"
fi

log_message "Installing apt dependencies"
apt-get update
apt-get install -y git curl ca-certificates gnupg tar unzip wget jq net-tools sudo bash

log_message "Installing Python 3 venv and pip"
apt-get install -y python3-venv python3-pip

log_message "Installing rsyslog"
apt-get install -y rsyslog
log_message "Enabling and starting rsyslog.service"
systemctl enable --now rsyslog.service

log_message "Installing fail2ban and sendmail"
apt-get install -y fail2ban sendmail

log_message "Installing vim"
apt-get install -y vim
log_message "Setting vim as default editor"
sed -i '/^EDITOR=.*/d' /etc/environment
sed -i '/^export EDITOR=.*/d' /etc/environment
echo "export EDITOR=vim" | tee -a /etc/environment

export NEBULA_TMP_DIR="${NEBULA_TMP_DIR:-"/tmp/cloudinit"}"
export NEBULA_VERSION="${NEBULA_VERSION:-"1.11.3"}"
export NEBULA_VENV_DIR=${NEBULA_VENV_DIR:-"${NEBULA_TMP_DIR}/venv"} # Do not create this directory if it does not exist, it will be created by `python3 -m venv`
export NEBULA_CLOUDINIT_AUTHORIZED_KEYS_FILE="${NEBULA_CLOUDINIT_AUTHORIZED_KEYS_FILE:-"${NEBULA_TMP_DIR}/authorized_keys"}"
export NEBULA_REQUIREMENTS_FILE="${NEBULA_REQUIREMENTS_FILE:-"${NEBULA_TMP_DIR}/requirements-${NEBULA_VERSION}.yml"}"

log_message "
NEBULA_TMP_DIR: ${NEBULA_TMP_DIR}
NEBULA_VERSION: ${NEBULA_VERSION}
NEBULA_VENV_DIR: ${NEBULA_VENV_DIR} 
NEBULA_CLOUDINIT_AUTHORIZED_KEYS_FILE: ${NEBULA_CLOUDINIT_AUTHORIZED_KEYS_FILE}
NEBULA_REQUIREMENTS_FILE: ${NEBULA_REQUIREMENTS_FILE}

Creating directories if not exists and changing ownership to root:root"

if [ -d "${NEBULA_VENV_DIR}" ]; then
    log_message "Virtual environment already exists at ${NEBULA_VENV_DIR}"
else

    log_message "Creating virtual environment at ${NEBULA_VENV_DIR}"
    python3 -m venv "${NEBULA_VENV_DIR}"
fi

mkdir -p "${NEBULA_TMP_DIR}" "$(dirname "${NEBULA_CLOUDINIT_AUTHORIZED_KEYS_FILE}")" \
    "$(dirname "${NEBULA_REQUIREMENTS_FILE}")"

log_message Changing ownership of "${NEBULA_TMP_DIR}" "${NEBULA_VENV_DIR}" \
    "$(dirname "${NEBULA_CLOUDINIT_AUTHORIZED_KEYS_FILE}")" "$(dirname "${NEBULA_REQUIREMENTS_FILE}")" \
    to root:root
chown -R root:root "${NEBULA_TMP_DIR}" "${NEBULA_VENV_DIR}" \
    "$(dirname "${NEBULA_CLOUDINIT_AUTHORIZED_KEYS_FILE}")" "$(dirname "${NEBULA_REQUIREMENTS_FILE}")"

log_message "Creating authorized_keys file at ${NEBULA_CLOUDINIT_AUTHORIZED_KEYS_FILE}"
tee "${NEBULA_CLOUDINIT_AUTHORIZED_KEYS_FILE}" <<EOF >/dev/null
${CLOUD_INIT_USE_SSH_PUB}
EOF

if [ "${CLOUD_INIT_COPY_ROOT_SSH_KEYS}" = true ] && [ -f "/root/.ssh/authorized_keys" ]; then
    log_message "Copying root's authorized_keys to ${NEBULA_CLOUDINIT_AUTHORIZED_KEYS_FILE}"
    cat "/root/.ssh/authorized_keys" >>"${NEBULA_CLOUDINIT_AUTHORIZED_KEYS_FILE}"
else
    log_message "CLOUD_INIT_COPY_ROOT_SSH_KEYS is set to false or /root/.ssh/authorized_keys does not exist, not adding
 any extra keys to ${CLOUD_INIT_USER}"
fi

if [[ ! -f "${NEBULA_REQUIREMENTS_FILE}" ]]; then
    log_message "Downloading nebula ansible requirements ${NEBULA_VERSION} file to ${NEBULA_REQUIREMENTS_FILE}"
    curl -sSL --connect-timeout 10 --max-time 10 \
        "https://raw.githubusercontent.com/arpanrec/arpanrec.nebula/refs/tags/${NEBULA_VERSION}/requirements.yml" \
        -o "${NEBULA_REQUIREMENTS_FILE}"
else
    log_message "${NEBULA_REQUIREMENTS_FILE} already exists"
fi

export DEFAULT_ROLES_PATH="${DEFAULT_ROLES_PATH:-"${NEBULA_TMP_DIR}/roles"}"
export ANSIBLE_ROLES_PATH="${ANSIBLE_ROLES_PATH:-"${DEFAULT_ROLES_PATH}"}"
export ANSIBLE_COLLECTIONS_PATH="${ANSIBLE_COLLECTIONS_PATH:-"${NEBULA_TMP_DIR}/collections"}"
export ANSIBLE_INVENTORY="${ANSIBLE_INVENTORY:-"${NEBULA_TMP_DIR}/inventory.yml"}"

log_message "
DEFAULT_ROLES_PATH: ${DEFAULT_ROLES_PATH}
ANSIBLE_ROLES_PATH: ${ANSIBLE_ROLES_PATH}
ANSIBLE_COLLECTIONS_PATH: ${ANSIBLE_COLLECTIONS_PATH}
ANSIBLE_INVENTORY: ${ANSIBLE_INVENTORY}

Creating directories if not exists and changing ownership to root:root"

mkdir -p "${DEFAULT_ROLES_PATH}" "${ANSIBLE_ROLES_PATH}" "${ANSIBLE_COLLECTIONS_PATH}" \
    "$(dirname "${ANSIBLE_INVENTORY}")"
chown -R root:root "${DEFAULT_ROLES_PATH}" "${ANSIBLE_ROLES_PATH}" "${ANSIBLE_COLLECTIONS_PATH}" \
    "$(dirname "${ANSIBLE_INVENTORY}")"

log_message "Activating virtual environment at ${NEBULA_VENV_DIR}"
# shellcheck source=/dev/null
source "${NEBULA_VENV_DIR}/bin/activate"

log_message "Installing ansible and hvac using pip3"
pip3 install --upgrade pip
pip3 install setuptools-rust wheel setuptools --upgrade
pip3 install ansible hvac --upgrade

log_message "Installing nebula version ${NEBULA_VERSION}"

log_message "Installing roles and collections dependencies"
ansible-galaxy install -r "${NEBULA_REQUIREMENTS_FILE}"

log_message "Installing arpanrec.nebula collection version ${NEBULA_VERSION}"
ansible-galaxy collection install arpanrec.nebula:"${NEBULA_VERSION}"

log_message Creating inventory file at "${ANSIBLE_INVENTORY}"
tee "${ANSIBLE_INVENTORY}" <<EOF >/dev/null
---
all:
    children:
        cloudinit:
            hosts:
                localhost:
            vars:
                ansible_user: root
                ansible_become: false
                pv_cloud_init_user: ${CLOUD_INIT_USER}
                pv_cloud_init_group: ${CLOUD_INIT_GROUP}
                pv_cloud_init_authorized_keys: ${NEBULA_CLOUDINIT_AUTHORIZED_KEYS_FILE}
                pv_cloud_init_is_dev_machine: ${CLOUD_INIT_IS_DEV_MACHINE}
                pv_cloud_init_hostname: ${CLOUD_INIT_HOSTNAME}
                pv_cloud_init_domain: ${CLOUD_INIT_DOMAIN}
                pv_cloud_init_install_docker: ${CLOUD_INIT_INSTALL_DOCKER}
    hosts:
        localhost:
            ansible_connection: local
            ansible_python_interpreter: "/usr/bin/python3"
EOF

#             ansible_python_interpreter: "$(which python3)"

log_message Running ansible-playbook arpanrec.nebula.cloudinit

ansible-playbook arpanrec.nebula.cloudinit

log_message Deactivating virtual environment at "${NEBULA_VENV_DIR}"

deactivate

log_message Changing ownership of "${NEBULA_TMP_DIR}" "${NEBULA_VENV_DIR}" \
    "$(dirname "${NEBULA_CLOUDINIT_AUTHORIZED_KEYS_FILE}")" "$(dirname "${NEBULA_REQUIREMENTS_FILE}")" \
    to "${CLOUD_INIT_USER}:${CLOUD_INIT_GROUP}"
chown -R "${CLOUD_INIT_USER}":"${CLOUD_INIT_GROUP}" "${NEBULA_TMP_DIR}" "${NEBULA_VENV_DIR}" \
    "$(dirname "${NEBULA_CLOUDINIT_AUTHORIZED_KEYS_FILE}")" "$(dirname "${NEBULA_REQUIREMENTS_FILE}")"

log_message Changing ownership of "${DEFAULT_ROLES_PATH}" "${ANSIBLE_ROLES_PATH}" "${ANSIBLE_COLLECTIONS_PATH}" \
    "$(dirname "${ANSIBLE_INVENTORY}")" to "${CLOUD_INIT_USER}:${CLOUD_INIT_GROUP}"
chown -R "${CLOUD_INIT_USER}":"${CLOUD_INIT_GROUP}" "${DEFAULT_ROLES_PATH}" "${ANSIBLE_ROLES_PATH}" \
    "${ANSIBLE_COLLECTIONS_PATH}" "$(dirname "${ANSIBLE_INVENTORY}")"

ANSIBLE_INVENTORY="$(dirname "${ANSIBLE_INVENTORY}")/server-workspace-inventory.yml"
export ANSIBLE_INVENTORY

log_message ANSIBLE_INVENTORY for server_workspace: "${ANSIBLE_INVENTORY}"

log_message "Running server_workspace playbook as ${CLOUD_INIT_USER}"

sudo -E -H -u "${CLOUD_INIT_USER}" bash -c '
#!/usr/bin/env bash
set -exuo pipefail

if [ "${CLOUD_INIT_INSTALL_DOTFILES}" = true ]; then
    bash <(curl -sSL --connect-timeout 10 --max-time 10 \
        https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/dot-install.sh)
fi

if [ "${CLOUD_INIT_IS_DEV_MACHINE}" = true ]; then
    bash <(curl -sSL --connect-timeout 10 --max-time 10 \
        https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/server-workspace.sh) \
        --tags all
else
    bash <(curl -sSL --connect-timeout 10 --max-time 10 \
        https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/server-workspace.sh) \
        --tags all --skip-tags java,go,terraform,vault,nodejs,bws,pulumi
fi

'

if [ -f /etc/update-motd.d/10-uname ]; then
    log_message "Removing /etc/update-motd.d/10-uname"
    rm -f /etc/update-motd.d/10-uname
fi

function install_fastfetch() {
    fastfetch_version="2.29.0"
    log_message "Installing fastfetch"

    if command -v fastfetch &>/dev/null; then
        fastfetch_installed_version="$(fastfetch --version | awk '{print $2}')"
        if [ "${fastfetch_installed_version}" = "${fastfetch_version}" ]; then
            log_message "fastfetch ${fastfetch_version} already installed"
            return
        else
            log_message "fastfetch ${fastfetch_installed_version} installed, upgrading to ${fastfetch_version}"
            log_message "Removing existing fastfetch"
            apt-get purge -y fastfetch
        fi
    fi

    if ! command -v fastfetch &>/dev/null; then
        system_architecture="$(uname -m)"
        case "${system_architecture}" in
        x86_64)
            fastfetch_architecture="amd64"
            ;;
        aarch64)
            fastfetch_architecture="aarch64"
            ;;
        *)
            log_message "Unsupported system architecture ${system_architecture}, exiting"
            exit 1
            ;;
        esac
        fastfetch_url="https://github.com/fastfetch-cli/fastfetch/releases/download/${fastfetch_version}/fastfetch-linux-${fastfetch_architecture}.deb"
        download_location="/tmp/fastfetch-linux-${fastfetch_version}-${fastfetch_architecture}.deb"
        if [ -f "${download_location}" ]; then
            log_message "fastfetch ${fastfetch_version} already downloaded to ${download_location}"
        else
            log_message "Downloading fastfetch ${fastfetch_version} from ${fastfetch_url} to ${download_location}"
            curl -sSL --connect-timeout 10 --max-time 10 "${fastfetch_url}" -o "${download_location}"
        fi
        log_message "Installing fastfetch ${fastfetch_version} from ${download_location}"
        dpkg -i "${download_location}"
    else
        log_message "fastfetch already installed"
    fi
}

install_fastfetch
log_message "Creating /etc/update-motd.d/10-osinfo-debian-cloudinit"
tee /etc/update-motd.d/10-osinfo-debian-cloudinit <<EOF >/dev/null
#!/bin/bash
fastfetch || true
EOF

log_message "Setting permissions for /etc/update-motd.d/10-osinfo-debian-cloudinit"
chmod +x /etc/update-motd.d/10-osinfo-debian-cloudinit
chown root:root /etc/update-motd.d/10-osinfo-debian-cloudinit

log_message "Creating /etc/motd"

tee /etc/motd <<EOF >/dev/null
############################################################
#       First of all, if you are not me,                   #
#       Get the fuck out of here                           #
#       or                                                 #
#       fuck around and find out.                          #
############################################################
#       STOP! You’ve reached the peak                      #
#       of your questionable life choices                  #
############################################################
#       Hey, fancy seeing *you* here.                      #
#       Remember, every command you type                   #
#       reminds the server it deserves a better user.      #
#                                                          #
#       Please don’t mess things up (again).               #
#       And if you do, IT knows.                           #
############################################################
#       Type ‘exit’ to repent.                             #
############################################################
EOF

log_message "Removing lock file ${CLOUD_INIT_LOCK_FILE}"
rm -f "${CLOUD_INIT_LOCK_FILE}"

log_message "Completed"
