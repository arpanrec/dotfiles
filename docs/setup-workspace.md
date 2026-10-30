# Set Up Development Workspace

Provisions a developer toolchain with Ansible using the [Ansible server_workspace playbook](https://github.com/arpanrec/ansible-collection-nebula/blob/main/playbooks/server_workspace.md). Run this script as a non-root user on Linux. It needs `curl`, `jq`, `tar`, `sha256sum`, `flock` and `mktemp`.

When called without arguments, the script asks which tools to install (Node.js, Go, Oracle JDK, Terraform, Vault, Pulumi, Bitwarden SDK, Hadolint, Gitleaks, uv, Rclone, Bun), then asks for confirmation before it runs the playbook. The prompts need a terminal. In unattended runs, pass arguments; the script hands them straight to `ansible-playbook`.

Only one run can happen at a time. A run holds a `flock` on `${NEBULA_TMP_DIR}/setup-workspace.lock`, and the kernel releases it when the script exits, even after a crash.

The script installs uv into `UV_INSTALL_DIR` and verifies the release tarball against the SHA-256 digest published on the uv GitHub release. If that directory already has the requested uv version, the script skips the download.

## Environment Variables

| Variable                      | Default                                        | Description                                               |
| ----------------------------- | ---------------------------------------------- | --------------------------------------------------------- |
| `NEBULA_TMP_DIR`              | `${HOME}/.cache/ansible-nebula-cache`          | Cache directory for downloads, roles and collections      |
| `SERVER_WORKSPACE_LOCK_FILE`  | `${NEBULA_TMP_DIR}/setup-workspace.lock`       | Lock file that stops concurrent runs                      |
| `UV_VERSION`                  | `0.13.6`                                       | uv release used to run Ansible                            |
| `UV_TARBALL`                  | `${NEBULA_TMP_DIR}/uv-<arch>-<ver>.tar.gz`     | Cached uv release tarball, verified by SHA-256 before use |
| `UV_INSTALL_DIR`              | `${NEBULA_TMP_DIR}/uv`                         | Directory the `uv` and `uvx` binaries are installed to    |
| `NEBULA_VERSION`              | `1.23.0`                                       | Version of the nebula collection and playbook             |
| `NEBULA_PYTHON_VERSION`       | `3.14.8`                                       | Python version uv uses to run Ansible                     |
| `NEBULA_EXTRA_VARS_JSON_FILE` | `${NEBULA_TMP_DIR}/extra_vars.json`            | Extra vars for the playbook, as a JSON object             |
| `NEBULA_REQUIREMENTS_FILE`    | `${NEBULA_TMP_DIR}/requirements-<version>.yml` | Cached Ansible Galaxy requirements of the collection      |
| `DEFAULT_ROLES_PATH`          | `${NEBULA_TMP_DIR}/roles`                      | Default Ansible roles path                                |
| `ANSIBLE_ROLES_PATH`          | `${DEFAULT_ROLES_PATH}`                        | Ansible roles path override                               |
| `ANSIBLE_COLLECTIONS_PATH`    | `${NEBULA_TMP_DIR}/collections`                | Ansible collections path                                  |
| `ANSIBLE_INVENTORY`           | `${NEBULA_TMP_DIR}/inventory.yml`              | Ansible inventory file, rewritten on every run            |

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/setup-workspace)
```

Unattended, with all tools:

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/setup-workspace) \
    --tags all
```

With custom tags and extra vars:

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/setup-workspace) \
    --tags nodejs,go --extra-vars='pv_ua_nodejs_version=16'
```
