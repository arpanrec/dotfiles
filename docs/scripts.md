# Scripts

The scripts in this repository automate various tasks, making it easier to set up and configure my environment. These scripts include:

## [Debian](/.script.d/debian-cloudinit.sh)

Variables:

* `CLOUD_INIT_GROUP` - Group name for the user to be created. Default `cloudinit`.
* `CLOUD_INIT_USER` - Username for the user to be created. Default `cloudinit`.
* `CLOUD_INIT_USE_SSH_PUB` - Use SSH public key for the user.
* `CLOUD_INIT_IS_DEV_MACHINE` - Install development tools. Default `false`.
* `CLOUD_INIT_COPY_ROOT_SSH_KEYS` - Copy root SSH keys to the user. Default `false`.
* `CLOUD_INIT_HOSTNAME` - Hostname for the machine. Default `cloudinit`.
* `CLOUD_INIT_DOMAIN` - Domain name for the machine. Default `cloudinit`.

```bash
sudo -E -H -u root bash -c '/bin/bash <(curl -s https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/debian-cloudinit.sh)'
```

or for development machine

```bash
CLOUD_INIT_IS_DEV_MACHINE=true sudo -E -H -u root bash -c '/bin/bash <(curl -s https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/debian-cloudinit.sh)'
```

[Linode stack script](https://cloud.linode.com/stackscripts/1164660) example:

```bash
#!/bin/bash
# <UDF name="CLOUD_INIT_COPY_ROOT_SSH_KEYS" Label="Copy Root SSH Keys to current user" oneOf="true,false" default="true"/>
# <UDF name="CLOUD_INIT_IS_DEV_MACHINE" Label="Install Devel tool chain" oneOf="true,false" default="false"/>
sudo -E -H -u root bash -c '/bin/bash <(curl -s https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/debian-cloudinit.sh)'
```

## [Server Workspace](/.script.d/server-workspace.sh)

Setup workspace for development using [server workspace playbook](https://github.com/arpanrec/arpanrec.nebula/blob/main/playbooks/server_workspace.md)

```bash
bash <(curl https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/server-workspace.sh)
```

For custom/silent install tags, extra-vars are optional

```bash
bash <(curl https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/server-workspace.sh) \
    --tags all,code \
    --extra-vars='pv_ua_nodejs_version=16 pv_ua_code_version=1.64.2'
```
