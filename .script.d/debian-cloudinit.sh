#!/usr/bin/env bash
set -ex
export CLOUD_INIT_USE_SSH_PUB=${CLOUD_INIT_USE_SSH_PUB:-'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJXzoi1QAbLmxnyudx+7Dm+FGTYU+TP02MTtxqq9w82Rm2kIDtGf4xVGxaidYEP/WcgpOHacjKDa7p2skBYljmk= arpan.rec@gmail.com'}

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

if [ "${HOME}" != "/root" ]; then
    echo "HOME is not set to /root"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive
export CLOUD_INIT_COPY_ROOT_SSH_KEYS=${CLOUD_INIT_COPY_ROOT_SSH_KEYS:-false}
export CLOUD_INIT_GROUP=${CLOUD_INIT_GROUP:-cloudinit}
export CLOUD_INIT_USER=${CLOUD_INIT_USER:-clouduser}
export CLOUD_INIT_IS_DEV_MACHINE=${CLOUD_INIT_IS_DEV_MACHINE:-false}
export DEFAULT_ROLES_PATH="/tmp/cloudinit/roles"
export ANSIBLE_ROLES_PATH="${DEFAULT_ROLES_PATH}"
export ANSIBLE_COLLECTIONS_PATH="/tmp/cloudinit/collections"

if [[ ! "${CLOUD_INIT_COPY_ROOT_SSH_KEYS}" =~ ^true|false$ ]]; then
    echo "CLOUD_INIT_COPY_ROOT_SSH_KEYS must be a boolean (true|false)"
    exit 1
fi

if [ -n "${LINODE_ID}" ]; then
    export CLOUD_INIT_COPY_ROOT_SSH_KEYS=true
fi

if [ "$(hostname)" = 'localhost' ]; then
    export CLOUD_INIT_HOSTNAME=${CLOUD_INIT_HOSTNAME:-cloudvm}
else
    CLOUD_INIT_HOSTNAME=$(hostname)
    export CLOUD_INIT_HOSTNAME
fi

if [ "$(domainname)" = '(none)' ]; then
    export CLOUD_INIT_DOMAIN=${CLOUD_INIT_DOMAIN:-clouddomain}
else
    CLOUD_INIT_DOMAIN=$(domainname)
    export CLOUD_INIT_DOMAIN
fi

if [[ ! "${CLOUD_INIT_IS_DEV_MACHINE}" =~ ^true|false$ ]]; then
    echo "CLOUD_INIT_IS_DEV_MACHINE must be a boolean (true|false)"
    exit 1
fi

apt update
apt install -y python3-venv python3-pip

deactivate || true
export CLOUD_INIT_ANSIBLE_DIR="/tmp/cloudinit"
rm -rf "${CLOUD_INIT_ANSIBLE_DIR}"

mkdir -p "${CLOUD_INIT_ANSIBLE_DIR}" "${DEFAULT_ROLES_PATH}" "${ANSIBLE_COLLECTIONS_PATH}"
echo "${CLOUD_INIT_USE_SSH_PUB}" >"${CLOUD_INIT_ANSIBLE_DIR}/authorized_keys"

if [ "${CLOUD_INIT_COPY_ROOT_SSH_KEYS}" = true ] && [ -f "/root/.ssh/authorized_keys" ]; then
    cat "/root/.ssh/authorized_keys" >>"${CLOUD_INIT_ANSIBLE_DIR}/authorized_keys"
fi

python3 -m venv "${CLOUD_INIT_ANSIBLE_DIR}/venv"
# shellcheck source=/dev/null
source "${CLOUD_INIT_ANSIBLE_DIR}/venv/bin/activate"
pip install ansible --upgrade
# ansible-galaxy collection install arpanrec.nebula:5.0.2

apt install -y git
ansible-galaxy collection install git+https://github.com/arpanrec/arpanrec.nebula.git,feature/inprogress --force
# ansible-galaxy role install git+https://github.com/geerlingguy/ansible-role-docker.git,,geerlingguy.docker -f

tee "${CLOUD_INIT_ANSIBLE_DIR}/hosts.yml" <<EOF >/dev/null
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
            ansible_python_interpreter: /usr/bin/python3
EOF

ansible-playbook -i "${CLOUD_INIT_ANSIBLE_DIR}/hosts.yml" arpanrec.nebula.cloudinit

deactivate

chown -R "${CLOUD_INIT_USER}:${CLOUD_INIT_GROUP}" "${CLOUD_INIT_ANSIBLE_DIR}"

sudo DEFAULT_ROLES_PATH="${DEFAULT_ROLES_PATH}" \
    CLOUD_INIT_IS_DEV_MACHINE="${CLOUD_INIT_IS_DEV_MACHINE}" \
    ANSIBLE_ROLES_PATH="${ANSIBLE_ROLES_PATH}" \
    ANSIBLE_COLLECTIONS_PATH="${ANSIBLE_COLLECTIONS_PATH}" \
    CLOUD_INIT_ANSIBLE_DIR="${CLOUD_INIT_ANSIBLE_DIR}" \
    -H -u "${CLOUD_INIT_USER}" bash -c '
    set -ex
    source "${CLOUD_INIT_ANSIBLE_DIR}/venv/bin/activate"
    if [ "${CLOUD_INIT_IS_DEV_MACHINE}" = true ]; then
        ansible-playbook -i "${CLOUD_INIT_ANSIBLE_DIR}/hosts.yml" arpanrec.nebula.server_workspace --tags all
    else
        ansible-playbook -i "${CLOUD_INIT_ANSIBLE_DIR}/hosts.yml" arpanrec.nebula.server_workspace \
            --tags all --skip-tags java,go,terraform,vault,nodejs
    fi
    git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" reset --hard HEAD
'
