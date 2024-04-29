#!/usr/bin/env bash
set -ex

export DEBIAN_FRONTEND=noninteractive

apt update

export CLOUD_INIT_COPY_ROOT_SSH_KEYS=false

if [ -n "${LINODE_ID}" ]; then
    CLOUD_INIT_COPY_ROOT_SSH_KEYS=true
fi

export CLOUD_INIT_GROUPNAME=${CLOUD_INIT_GROUPNAME:-cloudinit}
export CLOUD_INIT_USERNAME=${CLOUD_INIT_USERNAME:-clouduser}

export CLOUD_INIT_USE_SSHPUBKEY=${CLOUD_INIT_USE_SSHPUBKEY:-'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJXzoi1QAbLmxnyudx+7Dm+FGTYU+TP02MTtxqq9w82Rm2kIDtGf4xVGxaidYEP/WcgpOHacjKDa7p2skBYljmk= arpan.rec@gmail.com'}

if [ "$(hostname)" = 'localhost' ]; then
    CLOUD_INIT_HOSTNAME=${CLOUD_INIT_HOSTNAME:-cloudvm}
else
    CLOUD_INIT_HOSTNAME=$(hostname)
fi

if [ "$(domainname)" = '(none)' ]; then
    CLOUD_INIT_DOMAINNAME=${CLOUD_INIT_DOMAINNAME:-clouddomain}
else
    CLOUD_INIT_DOMAINNAME=$(domainname)
fi

export CLOUD_INIT_IS_DEV_MACHINE=${CLOUD_INIT_IS_DEV_MACHINE:-false}

if [[ ! "${CLOUD_INIT_IS_DEV_MACHINE}" =~ ^true|false$ ]]; then
    echo "CLOUD_INIT_IS_DEV_MACHINE must be a boolean (true|false)"
    exit 1
fi

apt install -y git python3-venv python3-pip

deactivate || true

export DEFAULT_ROLES_PATH="/tmp/cloudinit/roles"
export ANSIBLE_ROLES_PATH="${DEFAULT_ROLES_PATH}"
export ANSIBLE_COLLECTIONS_PATH="/tmp/cloudinit/collections"
mkdir -p "/tmp/cloudinit" "${DEFAULT_ROLES_PATH}" "${ANSIBLE_COLLECTIONS_PATH}"
rm -rf "/tmp/cloudinit/venv"
python3 -m venv "/tmp/cloudinit/venv"
source "/tmp/cloudinit/venv/bin/activate"
pip install ansible --upgrade
ansible-galaxy collection install git+https://github.com/arpanrec/arpanrec.nebula.git -f
ansible-galaxy role install git+https://github.com/geerlingguy/ansible-role-docker.git,,geerlingguy.docker -f

tee "/tmp/cloudinit/hosts.yml" <<EOF >/dev/null
all:
    children:
        server_workspace:
            hosts:
                localhost:
            vars:
                ansible_user: "${CLOUD_INIT_USERNAME}"
        cloudinit:
            hosts:
                localhost:
            vars:
                ansible_user: root
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

# ansible-playbook -i "/tmp/cloudinit/hosts.yml" arpanrec.nebula.cloudinit

chown -R "${CLOUD_INIT_USERNAME}:${CLOUD_INIT_GROUPNAME}" "/tmp/cloudinit"

sudo -H -u "${CLOUD_INIT_USERNAME}" bash -c '
    set -ex
    source "/tmp/cloudinit/venv/bin/activate"
    if [ "${CLOUD_INIT_IS_DEV_MACHINE}" = true ]; then
        ansible-playbook -i "/tmp/cloudinit/hosts.yml" arpanrec.nebula.server_workspace --tags all
    else
        ansible-playbook -i "/tmp/cloudinit/hosts.yml" arpanrec.nebula.server_workspace \
            --tags all --skip-tags java,bw,go,terraform,vault,nodejs
    fi
'
