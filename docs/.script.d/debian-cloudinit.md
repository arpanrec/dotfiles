# [Debian Cloudinit](/.script.d/debian-cloudinit.sh)

Bootstrap a Debian machine with a user and some basic tools using [cloudinit playbook](https://github.com/arpanrec/arpanrec.nebula/blob/main/playbooks/cloudinit.md).
And then setup user workspace using [server-workspace](/docs/.script.d/server-workspace.md)

Variables:

* `CLOUD_INIT_GROUP` : Group name for the user to be created. Default `cloudinit`.
* `CLOUD_INIT_USER` : Username for the user to be created. Default `cloudinit`.
* `CLOUD_INIT_USE_SSH_PUB` : Use SSH public key for the user, Default `ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJXzoi1QAbLmxnyudx+7Dm+FGTYU+TP02MTtxqq9w82Rm2kIDtGf4xVGxaidYEP/WcgpOHacjKDa7p2skBYljmk= arpan.rec@gmail.com`.
* `CLOUD_INIT_IS_DEV_MACHINE` : Install development tools. Default `false`.
* `CLOUD_INIT_COPY_ROOT_SSH_KEYS` : Copy root SSH keys to the user. Default `false`.
* `CLOUD_INIT_HOSTNAME` : Hostname for the machine. Default `cloudinit`.
* `CLOUD_INIT_DOMAIN` : Domain name for the machine. Default `cloudinit`.
* `CLOUD_INIT_INSTALL_DOTFILES` : Install dotfiles for the user. Default `true`.

* `NEBULA_TMP_DIR` : Directory to clone the ansible playbook. Default `/tmp/cloudinit`.
* `NEBULA_VERSION` : Version of the nebula playbook to be used. Default `1.9.6`.
* `NEBULA_VENV_DIR` : Directory to create the ansible virtual environment. Default `${NEBULA_TMP_DIR}/venv`.
  
* `DEFAULT_ROLES_PATH` : Directory to clone the ansible roles. Default `${NEBULA_TMP_DIR}/roles`.
* `ANSIBLE_ROLES_PATH` : Ansible roles path. Default `${DEFAULT_ROLES_PATH}`.
* `ANSIBLE_COLLECTIONS_PATH` : Ansible collections path. Default `${NEBULA_TMP_DIR}/collections`.
* `ANSIBLE_INVENTORY` : Ansible inventory file. Default `${NEBULA_TMP_DIR}/inventory.yml`.

```bash
sudo -E -H -u root bash -c '/bin/bash <(curl -sSL \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/debian-cloudinit.sh)'
```

or for development machine

```bash
CLOUD_INIT_IS_DEV_MACHINE=true sudo -E -H -u root \
    bash -c '/bin/bash <(curl -sSL https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/debian-cloudinit.sh)'

```
