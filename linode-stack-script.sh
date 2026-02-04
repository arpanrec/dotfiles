#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "Starting"

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root, exiting"
    exit 1
else
    echo "Running as root"
fi

echo "Updating package net-tools, git, curl, jq, unzip, zip, wget, gnupg2, tar"
apt-get update
apt-get install -y net-tools git curl jq unzip zip wget gnupg2 tar

if [ "${HOME}" != "/root" ]; then
    echo "HOME is not set to /root, exiting"
    exit 1
else
    echo "HOME is set to /root"
fi

# Exit if LINODE_ID, LINODE_LISHUSERNAME, LINODE_RAM, LINODE_DATACENTERID are not set

if [ -z "${LINODE_ID:-}" ]; then
    echo "LINODE_ID is not set, exiting"
    exit 1
else
    echo "LINODE_ID is set to ${LINODE_ID}"
fi

if [ -z "${LINODE_LISHUSERNAME:-}" ]; then
    echo "LINODE_LISHUSERNAME is not set, exiting"
    exit 1
else
    echo "LINODE_LISHUSERNAME is set to ${LINODE_LISHUSERNAME}"
fi

if [ -z "${LINODE_RAM:-}" ]; then
    echo "LINODE_RAM is not set, exiting"
    exit 1
else
    echo "LINODE_RAM is set to ${LINODE_RAM}"
fi

if [ -z "${LINODE_DATACENTERID:-}" ]; then
    echo "LINODE_DATACENTERID is not set, exiting"
    exit 1
else
    echo "LINODE_DATACENTERID is set to ${LINODE_DATACENTERID}"
fi

export LINODE_STACK_SCRIPT_LOCK_FILE="/tmp/linode-stack-script.lock"
if [ -f "${LINODE_STACK_SCRIPT_LOCK_FILE}" ]; then
    echo "Lock file ${LINODE_STACK_SCRIPT_LOCK_FILE} exists, exiting"
    exit 1
else
    echo "Creating lock file ${LINODE_STACK_SCRIPT_LOCK_FILE}"
    touch "${LINODE_STACK_SCRIPT_LOCK_FILE}"
fi

echo "Setting up environment"

if [ ! -f /etc/environment ]; then
    echo "Creating /etc/environment"
    touch /etc/environment
else
    echo "/etc/environment already exists"
fi

echo "Setting up environment variables in /etc/environment"

declare -A env_vars=(
    ["LINODE_ID"]="${LINODE_ID}"
    ["LINODE_LISHUSERNAME"]="${LINODE_LISHUSERNAME}"
    ["LINODE_RAM"]="${LINODE_RAM}"
    ["LINODE_DATACENTERID"]="${LINODE_DATACENTERID}"
    ["CLOUD_INIT_COPY_ROOT_SSH_KEYS"]="${CLOUD_INIT_COPY_ROOT_SSH_KEYS:-true}"
    ["CLOUD_INIT_IS_DEV_MACHINE"]="${CLOUD_INIT_IS_DEV_MACHINE:-false}"
    ["CLOUD_INIT_INSTALL_DOCKER"]="${CLOUD_INIT_INSTALL_DOCKER:-false}"
    ["CLOUD_INIT_INSTALL_DOTFILES"]="${CLOUD_INIT_INSTALL_DOTFILES:-true}"
    ["CLOUD_INIT_HOSTNAME"]="${CLOUD_INIT_HOSTNAME:-${LINODE_LISHUSERNAME:-cloudinit-debian-linode}}"
    ["CLOUD_INIT_DOMAIN"]="${CLOUD_INIT_DOMAIN:-arpanrec.com}"
    ["CLOUD_INIT_WEB_SERVER_FQDN"]="${CLOUD_INIT_WEB_SERVER_FQDN:-}"
)

for var in "${!env_vars[@]}"; do
    sed -i "/export ${var}=.*/d" /etc/environment
    sed -i "/^${var}=.*/d" /etc/environment
    echo "${var}=${env_vars[$var]}" | tee -a /etc/environment
done

echo "Sourcing /etc/environment after setting environment variables"
# shellcheck source=/dev/null
source /etc/environment

echo "Installing cron"
apt-get install -y cron
echo "Enabling and starting cron.service"
systemctl enable --now cron.service

echo "Adding cron job to run linode-stack-script every day at 1 AM"

echo "Dumping root crontab to /tmp/root-crontab"
crontab -l -u root | tee /tmp/root-crontab || true

echo "Removing existing linode-stack-script cron job"
sed -i '/.*linode-stack-script.*/d' /tmp/root-crontab

echo "Adding new linode-stack-script cron job"
echo "0 1 * * * /bin/bash -c 'mkdir -p /var/log/linode-stack-script; /bin/bash <(curl -sSL --connect-timeout 10 --max-time 10 https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/linode-stack-script.sh) | tee -a /var/log/linode-stack-script/linode-stack-script-cron.log'" |
    tee -a /tmp/root-crontab

echo "Installing new crontab"
crontab -u root /tmp/root-crontab

if [ -z "${CLOUD_INIT_WEB_SERVER_FQDN:-}" ]; then
    echo "CLOUD_INIT_WEB_SERVER_FQDN is not set"
else
    echo "CLOUD_INIT_WEB_SERVER_FQDN is set to ${CLOUD_INIT_WEB_SERVER_FQDN}"

    IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')
    sed -i "/${IPADDR}.*/d" /etc/hosts
    echo "${IPADDR} ${CLOUD_INIT_WEB_SERVER_FQDN}" | tee -a /etc/hosts
fi

/bin/bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/setup-debian.sh)

echo "Removing lock file ${LINODE_STACK_SCRIPT_LOCK_FILE}"
rm -f "${LINODE_STACK_SCRIPT_LOCK_FILE}"

echo "Completed"
