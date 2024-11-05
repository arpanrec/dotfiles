#!/usr/bin/env bash
set -euo pipefail

# <UDF name="CLOUD_INIT_COPY_ROOT_SSH_KEYS" Label="Copy Root SSH Keys to current user" oneOf="true,false" default="true"/>
# <UDF name="CLOUD_INIT_IS_DEV_MACHINE" Label="Install development tool chain" oneOf="true,false" default="false"/>
# <UDF name="CLOUD_INIT_INSTALL_DOTFILES" Label="Install dotfiles" oneOf="true,false" default="true"/>
# <udf name="LINODE_WEB_SERVER_FQDN" label="Web server fully qualified domain name" example="example.com" />

export DEBIAN_FRONTEND=noninteractive

printf "\n\n================================================================================\n"
echo "$(date) debian-cloudinit-linode-stackscript: Starting"
echo "--------------------------------------------------------------------------------"

sudo apt update && sudo apt install -y python3-venv python3-pip git curl ca-certificates gnupg tar unzip wget \
    jq net-tools

touch /etc/environment

# shellcheck source=/dev/null
source /etc/environment

sed -i '/^LINODE_ID=.*/d' /etc/environment
echo "LINODE_ID=${LINODE_ID}" | sudo tee -a /etc/environment

sed -i '/^LINODE_LISHUSERNAME=.*/d' /etc/environment
echo "LINODE_LISHUSERNAME=${LINODE_LISHUSERNAME}" | sudo tee -a /etc/environment

sed -i '/^LINODE_RAM=.*/d' /etc/environment
echo "LINODE_RAM=${LINODE_RAM}" | sudo tee -a /etc/environment

sed -i '/^LINODE_DATACENTERID=.*/d' /etc/environment
echo "LINODE_DATACENTERID=${LINODE_DATACENTERID}" | sudo tee -a /etc/environment

sed -i '/^CLOUD_INIT_COPY_ROOT_SSH_KEYS=.*/d' /etc/environment
echo "CLOUD_INIT_COPY_ROOT_SSH_KEYS=${CLOUD_INIT_COPY_ROOT_SSH_KEYS:-true}" | sudo tee -a /etc/environment

sed -i '/^CLOUD_INIT_IS_DEV_MACHINE=.*/d' /etc/environment
echo "CLOUD_INIT_IS_DEV_MACHINE=${CLOUD_INIT_IS_DEV_MACHINE:-false}" | sudo tee -a /etc/environment

sed -i '/^CLOUD_INIT_INSTALL_DOTFILES=.*/d' /etc/environment
echo "CLOUD_INIT_INSTALL_DOTFILES=${CLOUD_INIT_INSTALL_DOTFILES:-true}" | sudo tee -a /etc/environment

sed -i '/^CLOUD_INIT_HOSTNAME=.*/d' /etc/environment
echo "CLOUD_INIT_HOSTNAME=${CLOUD_INIT_HOSTNAME:-${LINODE_LISHUSERNAME:-"cloudinit-debian-linode"}}" |
    sudo tee -a /etc/environment

sed -i '/^CLOUD_INIT_DOMAIN=.*/d' /etc/environment
echo "CLOUD_INIT_DOMAIN=${CLOUD_INIT_DOMAIN:-"cloudinit-debian-linode"}" | sudo tee -a /etc/environment

if [ -z "${LINODE_WEB_SERVER_FQDN:-}" ]; then
    echo "LINODE_WEB_SERVER_FQDN is not set"
else
    echo "LINODE_WEB_SERVER_FQDN is set to ${LINODE_WEB_SERVER_FQDN}"

    sed -i '/^LINODE_WEB_SERVER_FQDN=.*/d' /etc/environment
    echo "LINODE_WEB_SERVER_FQDN=${LINODE_WEB_SERVER_FQDN}" | sudo tee -a /etc/environment

    IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')
    sed -i "/${IPADDR}.*/d" /etc/hosts
    echo "${IPADDR} ${LINODE_WEB_SERVER_FQDN}" | sudo tee -a /etc/hosts
fi

# shellcheck source=/dev/null
source /etc/environment

sudo -E -H -u root bash -c '/bin/bash <(curl -sSL \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/debian-cloudinit.sh)' |
    tee -a /root/debian-cloudinit.log
