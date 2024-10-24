#!/usr/bin/env bash
set -euo pipefail
export CLOUD_INIT_USER=${CLOUD_INIT_USER:-cloudinit}
export CLOUD_INIT_USE_SSH_PUB=${CLOUD_INIT_USE_SSH_PUB:-'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJXzoi1QAbLmxnyudx+7Dm+FGTYU+TP02MTtxqq9w82Rm2kIDtGf4xVGxaidYEP/WcgpOHacjKDa7p2skBYljmk= arpan.rec@gmail.com'}

export DEBIAN_FRONTEND=noninteractive
export CLOUD_INIT_COPY_ROOT_SSH_KEYS=${CLOUD_INIT_COPY_ROOT_SSH_KEYS:-false}
export CLOUD_INIT_GROUP=${CLOUD_INIT_GROUP:-cloudinit}
export CLOUD_INIT_IS_DEV_MACHINE=${CLOUD_INIT_IS_DEV_MACHINE:-false}
export CLOUD_INIT_HOSTNAME=${CLOUD_INIT_HOSTNAME:-cloudinit}
export CLOUD_INIT_DOMAIN=${CLOUD_INIT_DOMAIN:-cloudinit}

if [ -z "${CLOUD_INIT_USE_SSH_PUB}" ]; then
    echo "CLOUD_INIT_USE_SSH_PUB is not set"
    exit 1
fi

if [[ ! "${CLOUD_INIT_COPY_ROOT_SSH_KEYS}" =~ ^true|false$ ]]; then
    echo "CLOUD_INIT_COPY_ROOT_SSH_KEYS must be a boolean (true|false)"
    exit 1
fi

if [[ ! "${CLOUD_INIT_IS_DEV_MACHINE}" =~ ^true|false$ ]]; then
    echo "CLOUD_INIT_IS_DEV_MACHINE must be a boolean (true|false)"
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

if [ "${HOME}" != "/root" ]; then
    echo "HOME is not set to /root"
    exit 1
fi

deactivate || true
export CLOUD_INIT_ANSIBLE_DIR="/tmp/cloudinit"
export DEFAULT_ROLES_PATH="${CLOUD_INIT_ANSIBLE_DIR}/roles"
export ANSIBLE_ROLES_PATH="${DEFAULT_ROLES_PATH}"
export ANSIBLE_COLLECTIONS_PATH="${CLOUD_INIT_ANSIBLE_DIR}/collections"
export ANSIBLE_INVENTORY="${CLOUD_INIT_ANSIBLE_DIR}/hosts.yml"

rm -rf "${CLOUD_INIT_ANSIBLE_DIR}"

mkdir -p "${CLOUD_INIT_ANSIBLE_DIR}" "${DEFAULT_ROLES_PATH}" "${ANSIBLE_COLLECTIONS_PATH}"
echo "${CLOUD_INIT_USE_SSH_PUB}" >"${CLOUD_INIT_ANSIBLE_DIR}/authorized_keys"

if [ "${CLOUD_INIT_COPY_ROOT_SSH_KEYS}" = true ] && [ -f "/root/.ssh/authorized_keys" ]; then
    cat "/root/.ssh/authorized_keys" >>"${CLOUD_INIT_ANSIBLE_DIR}/authorized_keys"
fi

apt update
apt install -y python3-venv python3-pip git curl ca-certificates gnupg tar unzip wget

python3 -m venv "${CLOUD_INIT_ANSIBLE_DIR}/venv"

# shellcheck source=/dev/null
source "${CLOUD_INIT_ANSIBLE_DIR}/venv/bin/activate"

pip3 install --upgrade pip
pip3 install setuptools-rust wheel setuptools --upgrade
pip3 install ansible hvac --upgrade

ansible-galaxy collection install git+https://github.com/arpanrec/arpanrec.nebula.git,1.3.0

ansible-galaxy collection install git+https://github.com/ansible-collections/community.general.git,9.4.0
ansible-galaxy collection install git+https://github.com/ansible-collections/community.crypto.git,2.22.2
ansible-galaxy collection install git+https://github.com/ansible-collections/amazon.aws.git,8.2.1
ansible-galaxy collection install git+https://github.com/ansible-collections/community.docker.git,4.0.0
ansible-galaxy collection install git+https://github.com/ansible-collections/ansible.posix.git,1.6.2
ansible-galaxy collection install git+https://github.com/kewlfft/ansible-aur.git,v0.11.1

ansible-galaxy role install git+https://github.com/geerlingguy/ansible-role-docker.git,7.4.1,geerlingguy.docker

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
            ansible_python_interpreter: "$(which python3)"
EOF

ansible-playbook arpanrec.nebula.cloudinit

deactivate

chown -R "${CLOUD_INIT_USER}:${CLOUD_INIT_GROUP}" "${CLOUD_INIT_ANSIBLE_DIR}"

sudo -E -H -u "${CLOUD_INIT_USER}" bash -c '
    set -euo pipefail

    source "${CLOUD_INIT_ANSIBLE_DIR}/venv/bin/activate"

    if [ "${CLOUD_INIT_IS_DEV_MACHINE}" = true ]; then
        ansible-playbook arpanrec.nebula.server_workspace --tags all
    else
        ansible-playbook arpanrec.nebula.server_workspace --tags all \
            --skip-tags java,go,terraform,vault,nodejs,bws,pulumi
    fi

    bash <(curl https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/dot-install.sh)
'
