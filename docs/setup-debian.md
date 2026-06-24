# Setup Debian

Bootstraps a Debian machine as root using the [arpanrec.nebula cloudinit playbook](https://github.com/arpanrec/arpanrec.nebula/blob/main/playbooks/cloudinit.md). Sets up locale, timezone, a non-root user with SSH key access, and optionally installs dotfiles, the development workspace toolchain, and Docker. Applies a lock file to prevent concurrent or duplicate runs.

> Any variable whose name ends with `_FILE` will be written to a file; the directory is created automatically and ownership is set to root.

## Environment Variables

| Variable                                 | Default                               | Description                                                |
| ---------------------------------------- | ------------------------------------- | ---------------------------------------------------------- |
| `CLOUD_INIT_USER`                        | `cloudinit`                           | Username for the user to create                            |
| `CLOUD_INIT_GROUP`                       | `cloudinit`                           | Primary group for the created user                         |
| `CLOUD_INIT_USE_SSH_PUB`                 | Owner's public key from assets branch | SSH public key to authorize for the created user           |
| `CLOUD_INIT_HOSTNAME`                    | `cloudinit`                           | Hostname for the machine                                   |
| `CLOUD_INIT_DOMAIN`                      | `easyiac.com`                         | Domain name for the machine                                |
| `CLOUD_INIT_COPY_ROOT_SSH_KEYS`          | `false`                               | Copy root's authorized_keys to the created user            |
| `CLOUD_INIT_IS_DEV_MACHINE`              | `false`                               | Run `setup-workspace` with `--tags all` after provisioning |
| `CLOUD_INIT_INSTALL_DOTFILES`            | `true`                                | Install dotfiles for the created user                      |
| `CLOUD_INIT_INSTALL_DOCKER`              | `false`                               | Install Docker                                             |
| `NEBULA_TMP_DIR`                         | `/cloudinit/.tmp`                     | Working directory for Ansible                              |
| `NEBULA_VERSION`                         | `1.14.70`                             | Nebula playbook version                                    |
| `NEBULA_VENV_DIR`                        | `${NEBULA_TMP_DIR}/venv`              | Python virtual environment directory                       |
| `NEBULA_CLOUD_INIT_AUTHORIZED_KEYS_FILE` | `${NEBULA_TMP_DIR}/authorized_keys`   | Authorized keys file for the created user                  |
| `NEBULA_REQUIREMENTS_FILE`               | `${NEBULA_TMP_DIR}/requirements.yml`  | Ansible requirements file                                  |
| `DEFAULT_ROLES_PATH`                     | `${NEBULA_TMP_DIR}/roles`             | Default Ansible roles path                                 |
| `ANSIBLE_ROLES_PATH`                     | `${DEFAULT_ROLES_PATH}`               | Ansible roles path override                                |
| `ANSIBLE_COLLECTIONS_PATH`               | `${NEBULA_TMP_DIR}/collections`       | Ansible collections path                                   |
| `ANSIBLE_INVENTORY`                      | `${NEBULA_TMP_DIR}/inventory.yml`     | Ansible inventory file                                     |

## Usage

```bash
# Minimal
CLOUD_INIT_DOMAIN=easyiac.com sudo -E -H -u root bash -c '/bin/bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/setup-debian.sh)'
```

```bash
# Development machine
CLOUD_INIT_IS_DEV_MACHINE=true CLOUD_INIT_INSTALL_DOCKER=true sudo -E -H -u root \
    bash -c '/bin/bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/setup-debian.sh)'
```

```bash
# Development machine with a custom domain
CLOUD_INIT_DOMAIN=blr-home.easyiac.com CLOUD_INIT_IS_DEV_MACHINE=true CLOUD_INIT_INSTALL_DOCKER=true sudo -E -H -u root \
    bash -c '/bin/bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/setup-debian.sh)'
```
