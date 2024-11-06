#!/usr/bin/env bash
set -euo pipefail

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
    log_message "/etc/environment already exists, sourcing"
    # shellcheck source=/dev/null
    source /etc/environment
fi

export CLOUD_INIT_USER="${CLOUD_INIT_USER:-"cloudinit"}"
export CLOUD_INIT_USE_SSH_PUB="${CLOUD_INIT_USE_SSH_PUB:-"ecdsa-sha2-nistp256 \
AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJXzoi1QAbLmxnyudx+7Dm+FGTYU+TP02MTtxqq9w82Rm2kIDtGf4xVGxaidYEP/\
WcgpOHacjKDa7p2skBYljmk= arpan.rec@gmail.com"}"

log_message "
CLOUD_INIT_USER: ${CLOUD_INIT_USER}
CLOUD_INIT_USE_SSH_PUB: ${CLOUD_INIT_USE_SSH_PUB}"

export DEBIAN_FRONTEND="noninteractive"
export CLOUD_INIT_COPY_ROOT_SSH_KEYS="${CLOUD_INIT_COPY_ROOT_SSH_KEYS:-"false"}"
export CLOUD_INIT_GROUP="${CLOUD_INIT_GROUP:-"cloudinit"}"
export CLOUD_INIT_IS_DEV_MACHINE="${CLOUD_INIT_IS_DEV_MACHINE:-"false"}"
export CLOUD_INIT_HOSTNAME="${CLOUD_INIT_HOSTNAME:-"cloudinit"}"
export CLOUD_INIT_DOMAIN="${CLOUD_INIT_DOMAIN:-"cloudinit"}"
export CLOUD_INIT_INSTALL_DOTFILES="${CLOUD_INIT_INSTALL_DOTFILES:-"true"}"

log_message "
CLOUD_INIT_COPY_ROOT_SSH_KEYS: ${CLOUD_INIT_COPY_ROOT_SSH_KEYS}
CLOUD_INIT_GROUP: ${CLOUD_INIT_GROUP}
CLOUD_INIT_IS_DEV_MACHINE: ${CLOUD_INIT_IS_DEV_MACHINE}
CLOUD_INIT_HOSTNAME: ${CLOUD_INIT_HOSTNAME}
CLOUD_INIT_DOMAIN: ${CLOUD_INIT_DOMAIN}
CLOUD_INIT_INSTALL_DOTFILES: ${CLOUD_INIT_INSTALL_DOTFILES}"

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

export NEBULA_TMP_DIR="${NEBULA_TMP_DIR:-"${HOME}/.tmp/cloudinit"}"
export NEBULA_VERSION="${NEBULA_VERSION:-"1.9.6"}"
export NEBULA_VENV_DIR=${NEBULA_VENV_DIR:-"${NEBULA_TMP_DIR}/venv"}

log_message "
NEBULA_TMP_DIR: ${NEBULA_TMP_DIR}
NEBULA_VERSION: ${NEBULA_VERSION}
NEBULA_VENV_DIR: ${NEBULA_VENV_DIR}

Creating directories"

mkdir -p "${NEBULA_TMP_DIR}"

export DEFAULT_ROLES_PATH="${DEFAULT_ROLES_PATH:-"${NEBULA_TMP_DIR}/roles"}"
export ANSIBLE_ROLES_PATH="${ANSIBLE_ROLES_PATH:-"${DEFAULT_ROLES_PATH}"}"
export ANSIBLE_COLLECTIONS_PATH="${ANSIBLE_COLLECTIONS_PATH:-"${NEBULA_TMP_DIR}/collections"}"
export ANSIBLE_INVENTORY="${ANSIBLE_INVENTORY:-"${NEBULA_TMP_DIR}/inventory.yml"}"

log_message "
DEFAULT_ROLES_PATH: ${DEFAULT_ROLES_PATH}
ANSIBLE_ROLES_PATH: ${ANSIBLE_ROLES_PATH}
ANSIBLE_COLLECTIONS_PATH: ${ANSIBLE_COLLECTIONS_PATH}
ANSIBLE_INVENTORY: ${ANSIBLE_INVENTORY}"

# rm -rf "${NEBULA_TMP_DIR}"
if [ -d "${NEBULA_TMP_DIR}" ]; then
    log_message "Directory ${NEBULA_TMP_DIR} already exists, Changing ownership to root"
    chown -R root:root "${NEBULA_TMP_DIR}"
else
    log_message "Directory ${NEBULA_TMP_DIR} does not exist"
fi

log_message "Creating directories"
mkdir -p "${NEBULA_TMP_DIR}" "${DEFAULT_ROLES_PATH}" "${ANSIBLE_ROLES_PATH}" \
    "${ANSIBLE_COLLECTIONS_PATH}" "$(dirname "${ANSIBLE_INVENTORY}")"

log_message "Creating authorized_keys file at ${NEBULA_TMP_DIR}/authorized_keys"
tee "${NEBULA_TMP_DIR}/authorized_keys" <<EOF >/dev/null
${CLOUD_INIT_USE_SSH_PUB}
EOF

if [ "${CLOUD_INIT_COPY_ROOT_SSH_KEYS}" = true ] && [ -f "/root/.ssh/authorized_keys" ]; then
    log_message "Copying root's authorized_keys to ${NEBULA_TMP_DIR}/authorized_keys"
    cat "/root/.ssh/authorized_keys" >>"${NEBULA_TMP_DIR}/authorized_keys"
else
    log_message "CLOUD_INIT_COPY_ROOT_SSH_KEYS is set to false or /root/.ssh/authorized_keys does not exist, not adding any extra keys to ${CLOUD_INIT_USER}"
fi

log_message "Installing apt dependencies"
apt-get update
apt-get install -y git curl ca-certificates gnupg tar unzip wget jq net-tools sudo

log_message "Installing Python 3 venv and pip"
apt-get install -y python3-venv python3-pip

log_message "Installing fail2ban and sendmail"
apt-get install -y fail2ban sendmail

log_message "Installing postfix and rsyslog"
apt-get install -y postfix rsyslog
log_message "Enabling and starting postfix.service"
systemctl enable --now postfix.service
log_message "Enabling and starting rsyslog.service"
systemctl enable --now rsyslog.service

log_message "Installing vim"
apt-get install -y vim
log_message "Setting vim as default editor"
sed -i '/^EDITOR=.*/d' /etc/environment
echo "EDITOR=vim" | tee -a /etc/environment

if [ ! -d "${NEBULA_VENV_DIR}" ]; then
    log_message "Creating virtual environment at ${NEBULA_VENV_DIR}"
    python3 -m venv "${NEBULA_VENV_DIR}"
else
    log_message "Virtual environment already exists at ${NEBULA_VENV_DIR}"
fi

log_message "Activating virtual environment at ${NEBULA_VENV_DIR}"
# shellcheck source=/dev/null
source "${NEBULA_VENV_DIR}/bin/activate"

log_message "Installing ansible and hvac using pip3"
pip3 install --upgrade pip
pip3 install setuptools-rust wheel setuptools --upgrade
pip3 install ansible hvac --upgrade

log_message "Installing nebula version ${NEBULA_VERSION}"

if [[ ! -f "/tmp/requirements-${NEBULA_VERSION}.yml" ]]; then
    log_message "Downloading requirements-${NEBULA_VERSION}.yml to /tmp"
    curl -sSL \
        "https://raw.githubusercontent.com/arpanrec/arpanrec.nebula/refs/tags/${NEBULA_VERSION}/requirements.yml" \
        -o "/tmp/requirements-${NEBULA_VERSION}.yml"
else
    log_message "requirements-${NEBULA_VERSION}.yml already exists"
fi

log_message "Installing roles and collections dependencies"
ansible-galaxy install -r "/tmp/requirements-${NEBULA_VERSION}.yml"

log_message "Installing arpanrec.nebula collection version ${NEBULA_VERSION}"
ansible-galaxy collection install "git+https://github.com/arpanrec/arpanrec.nebula.git,${NEBULA_VERSION}"

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
                pv_cloud_init_authorized_keys: ${NEBULA_TMP_DIR}/authorized_keys
                pv_cloud_init_is_dev_machine: ${CLOUD_INIT_IS_DEV_MACHINE}
                pv_cloud_init_hostname: ${CLOUD_INIT_HOSTNAME}
                pv_cloud_init_domain: ${CLOUD_INIT_DOMAIN}
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

log_message Changing ownership of "${NEBULA_TMP_DIR}" "${NEBULA_VENV_DIR}" "${DEFAULT_ROLES_PATH}" \
    "${ANSIBLE_ROLES_PATH}" "${ANSIBLE_COLLECTIONS_PATH}" "$(dirname "${ANSIBLE_INVENTORY}")" to \
    "${CLOUD_INIT_USER}:${CLOUD_INIT_GROUP}"

chown -R "${CLOUD_INIT_USER}:${CLOUD_INIT_GROUP}" "${NEBULA_TMP_DIR}" "${NEBULA_VENV_DIR}" "${DEFAULT_ROLES_PATH}" \
    "${ANSIBLE_ROLES_PATH}" "${ANSIBLE_COLLECTIONS_PATH}" "$(dirname "${ANSIBLE_INVENTORY}")"

sudo -E -H -u "${CLOUD_INIT_USER}" bash -c '
#!/usr/bin/env bash
set -exuo pipefail

if [ "${CLOUD_INIT_INSTALL_DOTFILES}" = true ]; then
    bash <(curl -sSL https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/dot-install.sh)
fi

ANSIBLE_INVENTORY="$(dirname "${ANSIBLE_INVENTORY}")/server-workspace-inventory.yml"
export ANSIBLE_INVENTORY

if [ "${CLOUD_INIT_IS_DEV_MACHINE}" = true ]; then
    bash <(curl -sSL \
        https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/server-workspace.sh) \
        --tags all
else
    bash <(curl -sSL \
        https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/server-workspace.sh) \
        --tags all --skip-tags java,go,terraform,vault,nodejs,bws,pulumi
fi

'

log_message Changing ownership of "${NEBULA_TMP_DIR}" "${NEBULA_VENV_DIR}" "${DEFAULT_ROLES_PATH}" \
    "${ANSIBLE_ROLES_PATH}" "${ANSIBLE_COLLECTIONS_PATH}" "$(dirname "${ANSIBLE_INVENTORY}")" to root:root

chown -R root:root "${NEBULA_TMP_DIR}" "${NEBULA_VENV_DIR}" "${DEFAULT_ROLES_PATH}" \
    "${ANSIBLE_ROLES_PATH}" "${ANSIBLE_COLLECTIONS_PATH}" "$(dirname "${ANSIBLE_INVENTORY}")"

log_message "Completed"
