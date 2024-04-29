#!/usr/bin/env bash
set -ex

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive
export CLOUD_INIT_COPY_ROOT_SSH_KEYS=${CLOUD_INIT_COPY_ROOT_SSH_KEYS:-false}
export CLOUD_INIT_GROUPNAME=${CLOUD_INIT_GROUPNAME:-cloudinit}
export CLOUD_INIT_USERNAME=${CLOUD_INIT_USERNAME:-clouduser}
export CLOUD_INIT_USE_SSHPUBKEY=${CLOUD_INIT_USE_SSHPUBKEY:-'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJXzoi1QAbLmxnyudx+7Dm+FGTYU+TP02MTtxqq9w82Rm2kIDtGf4xVGxaidYEP/WcgpOHacjKDa7p2skBYljmk= arpan.rec@gmail.com'}
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
    export CLOUD_INIT_DOMAINNAME=${CLOUD_INIT_DOMAINNAME:-clouddomain}
else
    CLOUD_INIT_DOMAINNAME=$(domainname)
    export CLOUD_INIT_DOMAINNAME
fi

if [[ ! "${CLOUD_INIT_IS_DEV_MACHINE}" =~ ^true|false$ ]]; then
    echo "CLOUD_INIT_IS_DEV_MACHINE must be a boolean (true|false)"
    exit 1
fi

apt update
apt install -y git python3-venv python3-pip

deactivate || true

rm -rf "/tmp/cloudinit"

mkdir -p "/tmp/cloudinit" "${DEFAULT_ROLES_PATH}" "${ANSIBLE_COLLECTIONS_PATH}"
python3 -m venv "/tmp/cloudinit/venv"
source "/tmp/cloudinit/venv/bin/activate"
pip install ansible --upgrade
ansible-galaxy collection install git+https://github.com/arpanrec/arpanrec.nebula.git,feature/cloudinit -f

tee "/tmp/cloudinit/hosts.yml" <<EOF >/dev/null
all:
    children:
        server_workspace:
            hosts:
                localhost:
            vars:
                ansible_user: "${CLOUD_INIT_USERNAME}"
                ansible_become: false
        cloudinit:
            hosts:
                localhost:
            vars:
                ansible_user: root
                ansible_become: false
                pv_cloud_username: "${CLOUD_INIT_USERNAME}"
                pv_cloud_is_dev_machine: "${CLOUD_INIT_IS_DEV_MACHINE}"
                pv_cloud_groupname: "${CLOUD_INIT_GROUPNAME}"
                pv_cloud_hostname: "${CLOUD_INIT_HOSTNAME}"
                pv_cloud_domainname: ${CLOUD_INIT_DOMAINNAME}
                pv_cloud_user_ssh_public_key: ${CLOUD_INIT_USE_SSHPUBKEY}
    hosts:
        localhost:
            ansible_connection: local
            ansible_python_interpreter: /usr/bin/python3
EOF

ansible-playbook -i "/tmp/cloudinit/hosts.yml" arpanrec.nebula.cloudinit

deactivate

chown -R "${CLOUD_INIT_USERNAME}:${CLOUD_INIT_GROUPNAME}" "/tmp/cloudinit"

sudo DEFAULT_ROLES_PATH="${DEFAULT_ROLES_PATH}" \
    ANSIBLE_ROLES_PATH="${ANSIBLE_ROLES_PATH}" \
    ANSIBLE_COLLECTIONS_PATH="${ANSIBLE_COLLECTIONS_PATH}" \
    -H -u "${CLOUD_INIT_USERNAME}" bash -c '
    set -ex
    source "/tmp/cloudinit/venv/bin/activate"
    if [ "${CLOUD_INIT_IS_DEV_MACHINE}" = true ]; then
        ansible-playbook -i "/tmp/cloudinit/hosts.yml" arpanrec.nebula.server_workspace --tags all
    else
        ansible-playbook -i "/tmp/cloudinit/hosts.yml" arpanrec.nebula.server_workspace \
            --tags all --skip-tags java,bw,go,terraform,vault,nodejs
    fi
    git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" reset --hard HEAD
'
