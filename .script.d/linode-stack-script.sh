#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

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

if [ -f /etc/environment ]; then
    log_message "Sourcing /etc/environment"
    # shellcheck source=/dev/null
    source /etc/environment
else
    log_message "File /etc/environment does not exist"
fi

log_message "Installing packages"
apt update
apt install -y python3-venv python3-pip git curl ca-certificates \
    gnupg tar unzip wget jq net-tools cron sudo

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
