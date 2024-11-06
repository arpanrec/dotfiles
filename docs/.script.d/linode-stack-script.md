# [Linode Stack Script](/.script.d/linode-stack-script.sh)

[Public Script](https://cloud.linode.com/stackscripts/1164660)

Variables:

* `CLOUD_INIT_COPY_ROOT_SSH_KEYS` : Copy root SSH keys to the user. Default `true`.
* `CLOUD_INIT_IS_DEV_MACHINE` : Install development tools. Default `false`.
* `CLOUD_INIT_INSTALL_DOTFILES` : Install dotfiles for the user. Default `true`.
* `CLOUD_INIT_WEB_SERVER_FQDN` : Web server fully qualified domain name. Default `""`.

Variables from Linode:

* `LINODE_ID`: Example: `66627286`
* `LINODE_LISHUSERNAME` Example: `linode66627286`
* `LINODE_RAM`: Example: `2048`
* `LINODE_DATACENTERID`: Example: `14`

```bash
#!/usr/bin/env bash
set -euo pipefail

# <UDF name="CLOUD_INIT_COPY_ROOT_SSH_KEYS" Label="Copy Root SSH Keys to current user" oneOf="true,false" default="true"/>
# <UDF name="CLOUD_INIT_IS_DEV_MACHINE" Label="Install development tool chain" oneOf="true,false" default="false"/>
# <UDF name="CLOUD_INIT_INSTALL_DOTFILES" Label="Install dotfiles" oneOf="true,false" default="true"/>
# <udf name="CLOUD_INIT_WEB_SERVER_FQDN" label="Web server fully qualified domain name" example="example.com" default=""/>

export DEBIAN_FRONTEND=noninteractive

apt update
apt install -y python3-venv python3-pip git curl ca-certificates \
    gnupg tar unzip wget jq net-tools cron sudo

mkdir -p /var/log/linode-stack-script

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
    echo "${var}=${env_vars[$var]}" | tee -a /etc/environment
done

# shellcheck source=/dev/null
source /etc/environment

echo "Delegate to https://github.com/arpanrec/dotfiles/blob/main/docs/.script.d/linode-stack-script.md"

/bin/bash <(curl -sSL \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/linode-stack-script.sh) |
    tee -a /var/log/linode-stack-script/firstrun.log

```
