#!/usr/bin/env bash
set -euo pipefail

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Starting debian cloudinit"
echo "--------------------------------------------------------------------------------"

export CLOUD_INIT_USER=${CLOUD_INIT_USER:-cloudinit}
export CLOUD_INIT_USE_SSH_PUB=${CLOUD_INIT_USE_SSH_PUB:-'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJXzoi1QAbLmxnyudx+7Dm+FGTYU+TP02MTtxqq9w82Rm2kIDtGf4xVGxaidYEP/WcgpOHacjKDa7p2skBYljmk= arpan.rec@gmail.com'}

if [ -f /etc/environment ]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Sourcing /etc/environment"
    # shellcheck source=/dev/null
    source /etc/environment
    echo "--------------------------------------------------------------------------------"
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: File /etc/environment does not exist"
    echo "--------------------------------------------------------------------------------"
fi

export DEBIAN_FRONTEND=noninteractive
export CLOUD_INIT_COPY_ROOT_SSH_KEYS=${CLOUD_INIT_COPY_ROOT_SSH_KEYS:-false}
export CLOUD_INIT_GROUP=${CLOUD_INIT_GROUP:-cloudinit}
export CLOUD_INIT_IS_DEV_MACHINE=${CLOUD_INIT_IS_DEV_MACHINE:-false}
export CLOUD_INIT_HOSTNAME=${CLOUD_INIT_HOSTNAME:-cloudinit}
export CLOUD_INIT_DOMAIN=${CLOUD_INIT_DOMAIN:-cloudinit}

if [ -z "${CLOUD_INIT_USE_SSH_PUB}" ]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: CLOUD_INIT_USE_SSH_PUB is not set, exiting"
    echo "--------------------------------------------------------------------------------"
    exit 1
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: CLOUD_INIT_USE_SSH_PUB is set as ${CLOUD_INIT_USE_SSH_PUB}"
    echo "--------------------------------------------------------------------------------"
fi

if [[ ! "${CLOUD_INIT_COPY_ROOT_SSH_KEYS}" =~ ^true|false$ ]]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: CLOUD_INIT_COPY_ROOT_SSH_KEYS must be a boolean (true|false), exiting"
    echo "--------------------------------------------------------------------------------"
    exit 1
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: CLOUD_INIT_COPY_ROOT_SSH_KEYS is set as ${CLOUD_INIT_COPY_ROOT_SSH_KEYS}"
    echo "--------------------------------------------------------------------------------"
fi

if [[ ! "${CLOUD_INIT_IS_DEV_MACHINE}" =~ ^true|false$ ]]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: CLOUD_INIT_IS_DEV_MACHINE must be a boolean (true|false), exiting"
    echo "--------------------------------------------------------------------------------"
    exit 1
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: CLOUD_INIT_IS_DEV_MACHINE is set as ${CLOUD_INIT_IS_DEV_MACHINE}"
    echo "--------------------------------------------------------------------------------"
fi

if [ "$(id -u)" -ne 0 ]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Please run as root, exiting"
    echo "--------------------------------------------------------------------------------"
    exit 1
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Running as root"
    echo "--------------------------------------------------------------------------------"
fi

if [ "${HOME}" != "/root" ]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: HOME is not set to /root, exiting"
    echo "--------------------------------------------------------------------------------"
    exit 1
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: debian-cloudinit: HOME is set to /root"
    echo "--------------------------------------------------------------------------------"
fi

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Trying to deactivate virtual environment if already activated"
echo "--------------------------------------------------------------------------------"
deactivate || true

export CLOUD_INIT_ANSIBLE_DIR="/tmp/cloudinit"
export DEFAULT_ROLES_PATH="${CLOUD_INIT_ANSIBLE_DIR}/roles"
export ANSIBLE_ROLES_PATH="${DEFAULT_ROLES_PATH}"
export ANSIBLE_COLLECTIONS_PATH="${CLOUD_INIT_ANSIBLE_DIR}/collections"
export ANSIBLE_INVENTORY="${CLOUD_INIT_ANSIBLE_DIR}/inventory.yml"
export CLOUD_INIT_ANSIBLE_VENV_PATH="${CLOUD_INIT_ANSIBLE_DIR}/venv"

# rm -rf "${CLOUD_INIT_ANSIBLE_DIR}"
if [ -d "${CLOUD_INIT_ANSIBLE_DIR}" ]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Directory ${CLOUD_INIT_ANSIBLE_DIR} already exists, Changing ownership to root"
    echo "--------------------------------------------------------------------------------"
    chown -R root:root "${CLOUD_INIT_ANSIBLE_DIR}"
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Directory ${CLOUD_INIT_ANSIBLE_DIR} does not exist"
    echo "--------------------------------------------------------------------------------"
fi

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Creating directories"
echo "--------------------------------------------------------------------------------"
mkdir -p "${CLOUD_INIT_ANSIBLE_DIR}" "${DEFAULT_ROLES_PATH}" "${ANSIBLE_ROLES_PATH}" \
    "${ANSIBLE_COLLECTIONS_PATH}" "$(dirname "${ANSIBLE_INVENTORY}")"

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Creating authorized_keys file at ${CLOUD_INIT_ANSIBLE_DIR}/authorized_keys"
echo "--------------------------------------------------------------------------------"
tee "${CLOUD_INIT_ANSIBLE_DIR}/authorized_keys" <<EOF >/dev/null
${CLOUD_INIT_USE_SSH_PUB}
EOF

if [ "${CLOUD_INIT_COPY_ROOT_SSH_KEYS}" = true ] && [ -f "/root/.ssh/authorized_keys" ]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Copying root's authorized_keys to ${CLOUD_INIT_ANSIBLE_DIR}/authorized_keys"
    echo "--------------------------------------------------------------------------------"
    cat "/root/.ssh/authorized_keys" >>"${CLOUD_INIT_ANSIBLE_DIR}/authorized_keys"
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: CLOUD_INIT_COPY_ROOT_SSH_KEYS is set to false or /root/.ssh/authorized_keys does not exist, not adding any extra keys to ${CLOUD_INIT_USER}"
    echo "--------------------------------------------------------------------------------"
fi

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Installing dependencies, python3-venv python3-pip git curl ca-certificates gnupg tar unzip wget"
echo "--------------------------------------------------------------------------------"
apt update
apt install -y python3-venv python3-pip git curl ca-certificates gnupg tar unzip wget

if [ ! -d "${CLOUD_INIT_ANSIBLE_VENV_PATH}" ]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Creating virtual environment at ${CLOUD_INIT_ANSIBLE_VENV_PATH}"
    echo "--------------------------------------------------------------------------------"
    python3 -m venv "${CLOUD_INIT_ANSIBLE_VENV_PATH}"
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Virtual environment already exists at ${CLOUD_INIT_ANSIBLE_VENV_PATH}"
    echo "--------------------------------------------------------------------------------"
fi

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Activating virtual environment at ${CLOUD_INIT_ANSIBLE_VENV_PATH}"
echo "--------------------------------------------------------------------------------"
# shellcheck source=/dev/null
source "${CLOUD_INIT_ANSIBLE_VENV_PATH}/bin/activate"

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Installing ansible and hvac using pip3"
echo "--------------------------------------------------------------------------------"
pip3 install --upgrade pip
pip3 install setuptools-rust wheel setuptools --upgrade
pip3 install ansible hvac --upgrade

export NEBULA_VERSION=${NEBULA_VERSION:-"1.9.1"}

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Installing nebula version ${NEBULA_VERSION}"
echo "--------------------------------------------------------------------------------"

curl "https://raw.githubusercontent.com/arpanrec/arpanrec.nebula/refs/tags/${NEBULA_VERSION}/requirements.yml" \
    -o "/tmp/requirements-${NEBULA_VERSION}.yml"
ansible-galaxy install -r "/tmp/requirements-${NEBULA_VERSION}.yml"
ansible-galaxy collection install "git+https://github.com/arpanrec/arpanrec.nebula.git,${NEBULA_VERSION}"

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Creating inventory file at ${ANSIBLE_INVENTORY}"
echo "--------------------------------------------------------------------------------"
tee "${ANSIBLE_INVENTORY}" <<EOF >/dev/null
---
all:
    children:
        server_workspace:
            hosts:
                localhost:
            vars:
                ansible_user: ${CLOUD_INIT_USER}
                ansible_become: false
        cloudinit:
            hosts:
                localhost:
            vars:
                ansible_user: root
                ansible_become: false
                pv_cloud_init_user: ${CLOUD_INIT_USER}
                pv_cloud_init_group: ${CLOUD_INIT_GROUP}
                pv_cloud_init_authorized_keys: ${CLOUD_INIT_ANSIBLE_DIR}/authorized_keys
                pv_cloud_init_is_dev_machine: ${CLOUD_INIT_IS_DEV_MACHINE}
                pv_cloud_init_hostname: ${CLOUD_INIT_HOSTNAME}
                pv_cloud_init_domain: ${CLOUD_INIT_DOMAIN}
    hosts:
        localhost:
            ansible_connection: local
            ansible_python_interpreter: "/usr/bin/python3"
EOF

#             ansible_python_interpreter: "$(which python3)"

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Running ansible-playbook arpanrec.nebula.cloudinit"
echo "--------------------------------------------------------------------------------"

ansible-playbook arpanrec.nebula.cloudinit

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Deactivating virtual environment at ${CLOUD_INIT_ANSIBLE_VENV_PATH}"
echo "--------------------------------------------------------------------------------"

deactivate

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Changing ownership of ${CLOUD_INIT_ANSIBLE_DIR} to ${CLOUD_INIT_USER}:${CLOUD_INIT_GROUP}"
echo "debian-cloudinit: Running ansible-playbook arpanrec.nebula.server_workspace"
echo "--------------------------------------------------------------------------------"

chown -R "${CLOUD_INIT_USER}:${CLOUD_INIT_GROUP}" "${CLOUD_INIT_ANSIBLE_DIR}"

sudo -E -H -u "${CLOUD_INIT_USER}" bash -c '
    set -euo pipefail

    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Activating virtual environment at ${CLOUD_INIT_ANSIBLE_VENV_PATH}"
    echo "--------------------------------------------------------------------------------"
    source "${CLOUD_INIT_ANSIBLE_VENV_PATH}/bin/activate"

    if [ "${CLOUD_INIT_IS_DEV_MACHINE}" = true ]; then
        printf "\n\n================================================================================\n"
        echo "debian-cloudinit: Running ansible-playbook arpanrec.nebula.server_workspace with all tags in dev mode"
        echo "--------------------------------------------------------------------------------"
        ansible-playbook arpanrec.nebula.server_workspace --tags all
    else
        printf "\n\n================================================================================\n"
        echo "debian-cloudinit: Running ansible-playbook arpanrec.nebula.server_workspace without java, go, terraform, vault, nodejs, bws, pulumi tags"
        echo "--------------------------------------------------------------------------------"
        ansible-playbook arpanrec.nebula.server_workspace --tags all \
            --skip-tags java,go,terraform,vault,nodejs,bws,pulumi
    fi

    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Deactivating virtual environment at ${CLOUD_INIT_ANSIBLE_VENV_PATH}"
    echo "--------------------------------------------------------------------------------"
    deactivate

    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Installing/Reseting dotfiles"
    echo "--------------------------------------------------------------------------------"
    bash <(curl https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/dot-install.sh)
'

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Changing ownership of ${CLOUD_INIT_ANSIBLE_DIR} to root:root"
echo "--------------------------------------------------------------------------------"
chown -R root:root "${CLOUD_INIT_ANSIBLE_DIR}"

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Completed"
echo "--------------------------------------------------------------------------------"
