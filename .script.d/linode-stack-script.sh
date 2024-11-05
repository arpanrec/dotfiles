#!/usr/bin/env bash
set -euo pipefail

######### >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> End actual script
######### >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> End actual script
######### >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> End actual script
######### >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> End actual script
export DEBIAN_FRONTEND=noninteractive

touch /etc/environment

# shellcheck source=/dev/null
source /etc/environment

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
    echo "${var}=${env_vars[$var]}" | sudo tee -a /etc/environment
done

# shellcheck source=/dev/null
source /etc/environment
######### >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> End actual script
######### >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> End actual script
######### >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> End actual script
######### >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> End actual script

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

sudo -E -H -u root bash -c '/bin/bash <(curl -sSL \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/debian-cloudinit.sh)' |
    tee -a /root/linode-stack-script.log
