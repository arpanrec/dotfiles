# [Debian](/.script.d/debian-cloudinit.sh)

Bootstrap a Debian machine with a user and some basic tools using [cloudinit playbook](https://github.com/arpanrec/arpanrec.nebula/blob/main/playbooks/cloudinit.md).
And then setup user workspace using [server-workspace](/docs/.script.d/server-workspace.md)

Variables:

* `NEBULA_VERSION` - Version of the nebula playbook to be used. Default `1.9.1`.
* `CLOUD_INIT_GROUP` - Group name for the user to be created. Default `cloudinit`.
* `CLOUD_INIT_USER` - Username for the user to be created. Default `cloudinit`.
* `CLOUD_INIT_USE_SSH_PUB` - Use SSH public key for the user, Default `ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJXzoi1QAbLmxnyudx+7Dm+FGTYU+TP02MTtxqq9w82Rm2kIDtGf4xVGxaidYEP/WcgpOHacjKDa7p2skBYljmk= arpan.rec@gmail.com`.
* `CLOUD_INIT_IS_DEV_MACHINE` - Install development tools. Default `false`.
* `CLOUD_INIT_COPY_ROOT_SSH_KEYS` - Copy root SSH keys to the user. Default `false`.
* `CLOUD_INIT_HOSTNAME` - Hostname for the machine. Default `cloudinit`.
* `CLOUD_INIT_DOMAIN` - Domain name for the machine. Default `cloudinit`.
* `CLOUD_INIT_INSTALL_DOTFILES` - Install dotfiles for the user. Default `true`.

```bash
sudo -E -H -u root bash -c '/bin/bash <(curl \
    -s https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/debian-cloudinit.sh)'
```

or for development machine

```bash
CLOUD_INIT_IS_DEV_MACHINE=true sudo -E -H -u root \
    bash -c '/bin/bash <(curl -s https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/debian-cloudinit.sh)'
```

## [Linode stack script](https://cloud.linode.com/stackscripts/1164660)

For Linode stack script `CLOUD_INIT_COPY_ROOT_SSH_KEYS` is set to `true` by default, `CLOUD_INIT_IS_DEV_MACHINE` is set to `false` by default and `CLOUD_INIT_INSTALL_DOTFILES` is set to `true` by default.

```bash
#!/usr/bin/env bash
set -euo pipefail

# <UDF name="CLOUD_INIT_COPY_ROOT_SSH_KEYS" Label="Copy Root SSH Keys to current user" oneOf="true,false" default="true"/>
# <UDF name="CLOUD_INIT_IS_DEV_MACHINE" Label="Install development tool chain" oneOf="true,false" default="false"/>
# <UDF name="CLOUD_INIT_INSTALL_DOTFILES" Label="Install dotfiles" oneOf="true,false" default="true"/>

printf "\n\n================================================================================\n"
echo "debian-cloudinit-linode-stackscript: Starting"
echo "--------------------------------------------------------------------------------"

echo "LINODE_ID=${LINODE_ID}" >> /etc/environment
echo "LINODE_LISHUSERNAME=${LINODE_LISHUSERNAME}" >> /etc/environment
echo "LINODE_RAM=${LINODE_RAM}" >> /etc/environment
echo "LINODE_DATACENTERID=${LINODE_DATACENTERID}" >> /etc/environment

source /etc/environment

sudo -E -H -u root bash -c '/bin/bash <(curl -s \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/debian-cloudinit.sh)'

```
