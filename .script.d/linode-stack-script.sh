#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

log_message() {
    printf "\n\n================================================================================\n %s \
debian-cloudinit: \
%s\n--------------------------------------------------------------------------------\n\n" "$(date)" "$*"
}

export -f log_message

log_message "debian-cloudinit-linode-stackscript: Starting"

log_message "Installing packages"
sudo apt update
sudo apt install -y python3-venv python3-pip git curl ca-certificates gnupg tar unzip wget \
    jq net-tools cron

log_message "Enabling and starting cron"
sudo systemctl enable --now cron

log_message "Adding cron job"
mkdir -p /var/log/linode-stack-script
sudo crontab -l -u root | tee /tmp/root-crontab || true
sed -i '/.*linode-stack-script.*/d' /tmp/root-crontab
echo "*/1 * * * * /bin/bash -c 'mkdir -p /var/log/linode-stack-script; /bin/bash <(curl -sSL https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/linode-stack-script.sh) | tee -a /var/log/linode-stack-script/linode-stack-script.log'" | sudo tee -a /tmp/root-crontab
sudo crontab -u root /tmp/root-crontab

if [ -z "${CLOUD_INIT_WEB_SERVER_FQDN:-}" ]; then
    log_message "CLOUD_INIT_WEB_SERVER_FQDN is not set"
else
    log_message "CLOUD_INIT_WEB_SERVER_FQDN is set to ${CLOUD_INIT_WEB_SERVER_FQDN}"

    IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')
    sed -i "/${IPADDR}.*/d" /etc/hosts
    echo "${IPADDR} ${CLOUD_INIT_WEB_SERVER_FQDN}" | sudo tee -a /etc/hosts
fi

log_message "Delegate to https://github.com/arpanrec/dotfiles/blob/main/docs/.script.d/debian-cloudinit.md"

/bin/bash <(curl -sSL \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/debian-cloudinit.sh) |
    tee -a /var/log/linode-stack-script/linode-stack-script.log
