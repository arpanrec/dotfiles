# [Debian Cloudinit](/.script.d/debian-cloudinit.sh)

Bootstrap a Debian machine with a user and some basic tools using [cloudinit playbook](https://github.com/arpanrec/arpanrec.nebula/blob/main/playbooks/cloudinit.md).
And then setup user workspace using [server-workspace](/docs/.script.d/server-workspace.md)

Any variable ends with `_FILE` will be written to a file and the directory will be created if it does not exist, also ownership will be changed to the root user.
Variables:

* `CLOUD_INIT_GROUP` : Group name for the user to be created. Default `cloudinit`.
* `CLOUD_INIT_USER` : Username for the user to be created. Default `cloudinit`.
* `CLOUD_INIT_USE_SSH_PUB` : Use SSH public key for the user, Default `ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJXzoi1QAbLmxnyudx+7Dm+FGTYU+TP02MTtxqq9w82Rm2kIDtGf4xVGxaidYEP/WcgpOHacjKDa7p2skBYljmk=`.
* `CLOUD_INIT_IS_DEV_MACHINE` : Install development tools. Default `false`.
* `CLOUD_INIT_COPY_ROOT_SSH_KEYS` : Copy root SSH keys to the user. Default `false`.
* `CLOUD_INIT_HOSTNAME` : Hostname for the machine. Default `cloudinit`.
* `CLOUD_INIT_DOMAIN` : Domain name for the machine. Default `cloudinit`.
* `CLOUD_INIT_INSTALL_DOTFILES` : Install dotfiles for the user. Default `true`.
* `CLOUD_INIT_INSTALL_DOCKER` : Install docker. Default `false`.

* `NEBULA_TMP_DIR` : Directory to clone the ansible playbook. Default `/tmp/cloudinit`.
* `NEBULA_VERSION` : Version of the nebula playbook to be used. Default `1.11.5`.
* `NEBULA_VENV_DIR` : Directory to create the ansible virtual environment. Default `${NEBULA_TMP_DIR}/venv`.
* `NEBULA_CLOUDINIT_AUTHORIZED_KEYS_FILE` : Authorized keys file for the user. Default `${NEBULA_TMP_DIR}/authorized_keys`.
* `NEBULA_REQUIREMENTS_FILE` : Ansible requirements file. Default `${NEBULA_TMP_DIR}/requirements.yml`.
  
* `DEFAULT_ROLES_PATH` : Directory to clone the ansible roles. Default `${NEBULA_TMP_DIR}/roles`.
* `ANSIBLE_ROLES_PATH` : Ansible roles path. Default `${DEFAULT_ROLES_PATH}`.
* `ANSIBLE_COLLECTIONS_PATH` : Ansible collections path. Default `${NEBULA_TMP_DIR}/collections`.
* `ANSIBLE_INVENTORY` : Ansible inventory. Default `${NEBULA_TMP_DIR}/inventory.yml`.

```bash
sudo -E -H -u root bash -c '/bin/bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/debian-cloudinit.sh)'
```

or for development machine

```bash
CLOUD_INIT_IS_DEV_MACHINE=true CLOUD_INIT_INSTALL_DOCKER=true sudo -E -H -u root \
    bash -c '/bin/bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/debian-cloudinit.sh)'
```

or for development machine with a domain

```bash
CLOUD_INIT_DOMAIN=blr-home.arpanrec.com CLOUD_INIT_IS_DEV_MACHINE=true CLOUD_INIT_INSTALL_DOCKER=true sudo -E -H -u root \
    bash -c '/bin/bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/debian-cloudinit.sh)'
```
