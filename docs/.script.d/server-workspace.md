# [Debian](/.script.d/debian-cloudinit.sh)

Variables:

* `CLOUD_INIT_GROUP` - Group name for the user to be created. Default `cloudinit`.
* `CLOUD_INIT_USER` - Username for the user to be created. Default `cloudinit`.
* `CLOUD_INIT_USE_SSH_PUB` - Use SSH public key for the user.
* `CLOUD_INIT_IS_DEV_MACHINE` - Install development tools. Default `false`.
* `CLOUD_INIT_COPY_ROOT_SSH_KEYS` - Copy root SSH keys to the user. Default `false`.
* `CLOUD_INIT_HOSTNAME` - Hostname for the machine. Default `cloudinit`.
* `CLOUD_INIT_DOMAIN` - Domain name for the machine. Default `cloudinit`.

```bash
sudo -E -H -u root bash -c '/bin/bash <(curl \
    -s https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/debian-cloudinit.sh)'
```

or for development machine

```bash
CLOUD_INIT_IS_DEV_MACHINE=true sudo -E -H -u root \
    bash -c '/bin/bash <(curl -s https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/debian-cloudinit.sh)'
```

## [Linode stack script](https://cloud.linode.com/stackscripts/1164660)

```bash
#!/bin/bash
# <UDF name="CLOUD_INIT_COPY_ROOT_SSH_KEYS" Label="Copy Root SSH Keys to current user" oneOf="true,false" default="true"/>
# <UDF name="CLOUD_INIT_IS_DEV_MACHINE" Label="Install development tool chain" oneOf="true,false" default="false"/>

echo "LINODE_ID=${LINODE_ID}" >> /etc/environment
echo "LINODE_LISHUSERNAME=${LINODE_LISHUSERNAME}" >> /etc/environment
echo "LINODE_RAM=${LINODE_RAM}" >> /etc/environment
echo "LINODE_DATACENTERID=${LINODE_DATACENTERID}" >> /etc/environment

source /etc/environment

sudo -E -H -u root bash -c '/bin/bash <(curl -s \
    https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/debian-cloudinit.sh)'

```
