# Setup Debian

Bootstraps a Debian machine as root using the [Ansible cloudinit playbook](https://github.com/arpanrec/ansible-collection-nebula/blob/main/playbooks/cloudinit.md). It sets up the locale, timezone, and a non-root user with SSH key access, and can install dotfiles, development workspace tools, and Docker.

The script validates every setting before it changes anything: booleans must be `true` or `false`, user, group, host and domain names must be well formed, and each line of `CLOUD_INIT_USE_SSH_PUB` must be an SSH public key.

Only one run can happen at a time. A run holds a `flock` on `CLOUD_INIT_LOCK_FILE`, and the kernel releases it when the script exits, even after a crash.

`NEBULA_TMP_DIR` is a dedicated working directory. The script changes its ownership recursively, to root while the cloudinit playbook runs and to the created user afterwards, so it must be an absolute path at least two levels deep, and every other path variable below must point inside it. Each run reinstalls uv from the release tarball after verifying it against the SHA-256 digest published on the uv GitHub release.

Dotfiles and `setup-workspace` are downloaded from the `main` branch of this repository and run as the created user. A failed download stops the run.

The login banner uses `fastfetch` when the release's repositories have it. When they don't, the script skips that banner and carries on.

## Environment Variables

| Variable                                 | Default                                         | Description                                                     |
| ---------------------------------------- | ----------------------------------------------- | --------------------------------------------------------------- |
| `CLOUD_INIT_USER`                        | `cloudinit`                                     | Username for the user to create                                 |
| `CLOUD_INIT_GROUP`                       | `${CLOUD_INIT_USER}`                            | Primary group for the created user                              |
| `CLOUD_INIT_USE_SSH_PUB`                 | Owner's public key from assets branch           | SSH public keys to authorize for the created user, one per line |
| `CLOUD_INIT_HOSTNAME`                    | Current hostname, or `cloudinit` on `localhost` | Hostname for the machine                                        |
| `CLOUD_INIT_DOMAIN`                      | `easyiac.com`                                   | Domain name for the machine                                     |
| `CLOUD_INIT_TIMEZONE`                    | `Asia/Kolkata`                                  | Timezone, a name under `/usr/share/zoneinfo`                    |
| `CLOUD_INIT_COPY_ROOT_SSH_KEYS`          | `false`                                         | Copy root's authorized_keys to the created user                 |
| `CLOUD_INIT_IS_DEV_MACHINE`              | `false`                                         | Run `setup-workspace` with `--tags all` after provisioning      |
| `CLOUD_INIT_INSTALL_DOTFILES`            | `true`                                          | Install dotfiles for the created user                           |
| `CLOUD_INIT_INSTALL_DOCKER`              | `false`                                         | Install Docker                                                  |
| `NEBULA_TMP_DIR`                         | `/cloudinit/.tmp`                               | Working directory for Ansible                                   |
| `CLOUD_INIT_LOCK_FILE`                   | `${NEBULA_TMP_DIR}/setup-debian.lock`           | Lock file that stops concurrent runs                            |
| `UV_VERSION`                             | `0.13.6`                                        | uv release used to run Ansible                                  |
| `UV_TARBALL`                             | `${NEBULA_TMP_DIR}/uv-<arch>-<ver>.tar.gz`      | Cached uv release tarball, verified by SHA-256 before use       |
| `UV_INSTALL_DIR`                         | `${NEBULA_TMP_DIR}/uv`                          | Directory the `uv` and `uvx` binaries are installed to          |
| `NEBULA_VERSION`                         | `1.23.0`                                        | Nebula collection and playbook version                          |
| `NEBULA_PYTHON_VERSION`                  | `3.14.8`                                        | Python version uv uses to run Ansible                           |
| `NEBULA_CLOUD_INIT_AUTHORIZED_KEYS_FILE` | `${NEBULA_TMP_DIR}/authorized_keys`             | Authorized keys file for the created user                       |
| `NEBULA_REQUIREMENTS_FILE`               | `${NEBULA_TMP_DIR}/requirements-<version>.yml`  | Cached Ansible Galaxy requirements of the collection            |
| `DEFAULT_ROLES_PATH`                     | `${NEBULA_TMP_DIR}/roles`                       | Default Ansible roles path                                      |
| `ANSIBLE_ROLES_PATH`                     | `${DEFAULT_ROLES_PATH}`                         | Ansible roles path override                                     |
| `ANSIBLE_COLLECTIONS_PATH`               | `${NEBULA_TMP_DIR}/collections`                 | Ansible collections path                                        |
| `ANSIBLE_INVENTORY`                      | `${NEBULA_TMP_DIR}/inventory.yml`               | Ansible inventory file, rewritten on every run                  |

## Usage

### Minimal

```bash
CLOUD_INIT_DOMAIN=easyiac.com sudo -E -H -u root bash -c '/bin/bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/setup-debian)'
```

### Development machine

```bash
CLOUD_INIT_IS_DEV_MACHINE=true CLOUD_INIT_INSTALL_DOCKER=true sudo -E -H -u root \
    bash -c '/bin/bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/setup-debian)'
```

### Development machine with a custom domain

```bash
CLOUD_INIT_DOMAIN=blr-home.easyiac.com CLOUD_INIT_IS_DEV_MACHINE=true CLOUD_INIT_INSTALL_DOCKER=true sudo -E -H -u root \
    bash -c '/bin/bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/setup-debian)'
```
