#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

mkdir -p /var/log/cloudinit-cron

log_message() {
    printf "\n\n================================================================================\n %s \
debian-cloudinit: \
%s\n--------------------------------------------------------------------------------\n\n" "$(date)" "$*" | tee -a /var/log/cloudinit-cron/linode-cron.log
}

export -f log_message

log_message "debian-cloudinit-linode-stackscript: Starting"

sudo apt update && sudo apt install -y python3-venv python3-pip git curl ca-certificates gnupg tar unzip wget \
    jq net-tools cron

sudo systemctl enable --now cron

if [ -z "${CLOUD_INIT_WEB_SERVER_FQDN:-}" ]; then
    log_message "CLOUD_INIT_WEB_SERVER_FQDN is not set"
else
    log_message "CLOUD_INIT_WEB_SERVER_FQDN is set to ${CLOUD_INIT_WEB_SERVER_FQDN}"

    IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')
    sed -i "/${IPADDR}.*/d" /etc/hosts
    echo "${IPADDR} ${CLOUD_INIT_WEB_SERVER_FQDN}" | sudo tee -a /etc/hosts
fi

exit 1
log_message "Delegate to debian-cloudinit.sh"

sudo -E -H -u root bash -c '/bin/bash <(curl -sSL \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/debian-cloudinit.sh)' |
    tee -a /root/linode-stack-script.log
