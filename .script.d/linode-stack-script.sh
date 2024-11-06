#!/usr/bin/env bash
set -euo pipefail
#
#
# Stack Script at: https://cloud.linode.com/stackscripts/1164660
# Source: https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/linode-stack-script.sh
# Docs: https://github.com/arpanrec/dotfiles/blob/main/docs/.script.d/linode-stack-script.md
#
#
export DEBIAN_FRONTEND=noninteractive

# <UDF name="CLOUD_INIT_COPY_ROOT_SSH_KEYS" Label="Copy Root SSH Keys to current user" oneOf="true,false" default="true"/>
# <UDF name="CLOUD_INIT_IS_DEV_MACHINE" Label="Install development tool chain" oneOf="true,false" default="false"/>
# <UDF name="CLOUD_INIT_INSTALL_DOTFILES" Label="Install dotfiles" oneOf="true,false" default="true"/>
# <udf name="CLOUD_INIT_WEB_SERVER_FQDN" label="Web server fully qualified domain name" example="example.com" default=""/>

log_message() {
    printf "\n\n================================================================================\n %s \
linode-stack-script: \
%s\n--------------------------------------------------------------------------------\n\n" "$(date)" "$*"
}

export -f log_message

log_message "Starting"

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

log_message "Installing apt dependencies"
apt update
apt install -y python3-venv python3-pip git curl ca-certificates \
    gnupg tar unzip wget jq net-tools cron sudo vim

log_message "Setting up environment"

if [ ! -f /etc/environment ]; then
    log_message "Creating /etc/environment"
    touch /etc/environment
else
    log_message "/etc/environment already exists, sourcing"
    # shellcheck source=/dev/null
    source /etc/environment
fi

log_message "Setting up environment variables in /etc/environment"

declare -A env_vars=(
    ["LINODE_ID"]="${LINODE_ID}"
    ["LINODE_LISHUSERNAME"]="${LINODE_LISHUSERNAME}"
    ["LINODE_RAM"]="${LINODE_RAM}"
    ["LINODE_DATACENTERID"]="${LINODE_DATACENTERID}"
    ["CLOUD_INIT_COPY_ROOT_SSH_KEYS"]="${CLOUD_INIT_COPY_ROOT_SSH_KEYS:-true}"
    ["CLOUD_INIT_IS_DEV_MACHINE"]="${CLOUD_INIT_IS_DEV_MACHINE:-false}"
    ["CLOUD_INIT_INSTALL_DOTFILES"]="${CLOUD_INIT_INSTALL_DOTFILES:-true}"
    ["CLOUD_INIT_HOSTNAME"]="${CLOUD_INIT_HOSTNAME:-${LINODE_LISHUSERNAME:-cloudinit-debian-linode}}"
    ["CLOUD_INIT_DOMAIN"]="${CLOUD_INIT_DOMAIN:-cloudinit-debian-linode}"
    ["CLOUD_INIT_WEB_SERVER_FQDN"]="${CLOUD_INIT_WEB_SERVER_FQDN:-}"
)

for var in "${!env_vars[@]}"; do
    sed -i "/^${var}=.*/d" /etc/environment
    echo "${var}=${env_vars[$var]}" | tee -a /etc/environment
done

# shellcheck source=/dev/null
source /etc/environment

log_message "Enabling and starting cron"
systemctl enable --now cron

log_message "Adding cron job"
mkdir -p /var/log/linode-stack-script
crontab -l -u root | tee /tmp/root-crontab || true
sed -i '/.*linode-stack-script.*/d' /tmp/root-crontab
echo "0 */1 * * * /bin/bash -c 'mkdir -p /var/log/linode-stack-script; /bin/bash <(curl -sSL https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/linode-stack-script.sh) | tee -a /var/log/linode-stack-script/linode-stack-script-cron.log'" | tee -a /tmp/root-crontab
crontab -u root /tmp/root-crontab

if [ -z "${CLOUD_INIT_WEB_SERVER_FQDN:-}" ]; then
    log_message "CLOUD_INIT_WEB_SERVER_FQDN is not set"
else
    log_message "CLOUD_INIT_WEB_SERVER_FQDN is set to ${CLOUD_INIT_WEB_SERVER_FQDN}"

    IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')
    sed -i "/${IPADDR}.*/d" /etc/hosts
    echo "${IPADDR} ${CLOUD_INIT_WEB_SERVER_FQDN}" | tee -a /etc/hosts
fi

log_message "Delegate to https://github.com/arpanrec/dotfiles/blob/main/docs/.script.d/debian-cloudinit.md"

/bin/bash <(curl -sSL \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/debian-cloudinit.sh) |
    tee -a /var/log/linode-stack-script/debian-cloudinit.log

log_message "Completed"
