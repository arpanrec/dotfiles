# Set Up Development Workspace

Provisions a full developer toolchain using the [arpanrec.nebula server_workspace playbook](https://github.com/arpanrec/arpanrec.nebula/blob/main/playbooks/server_workspace.md) via Ansible. Run as a **non-root user**. When called without arguments, an interactive prompt selects which optional tool tags to install (Node.js, Go, Java, Vault, Terraform, Pulumi, Bitwarden SDK). Custom tags and extra vars can be passed directly.

## Environment Variables

| Variable                      | Default                             | Description                                |
| ----------------------------- | ----------------------------------- | ------------------------------------------ |
| `NEBULA_TMP_DIR`              | `${HOME}/.tmp`                      | Temporary directory for playbook downloads |
| `NEBULA_VERSION`              | `1.14.70`                           | Version of the nebula playbook             |
| `NEBULA_VENV_DIR`             | `${NEBULA_TMP_DIR}/venv`            | Python virtual environment directory       |
| `NEBULA_EXTRA_VARS_JSON_FILE` | `${NEBULA_TMP_DIR}/extra_vars.json` | Extra vars for the playbook in JSON format |
| `DEFAULT_ROLES_PATH`          | `${NEBULA_TMP_DIR}/roles`           | Default Ansible roles path                 |
| `ANSIBLE_ROLES_PATH`          | `${DEFAULT_ROLES_PATH}`             | Ansible roles path override                |
| `ANSIBLE_COLLECTIONS_PATH`    | `${NEBULA_TMP_DIR}/collections`     | Ansible collections path                   |
| `ANSIBLE_INVENTORY`           | `${NEBULA_TMP_DIR}/inventory`       | Ansible inventory file                     |

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/setup-workspace.sh)
```

With custom tags and extra vars:

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/setup-workspace.sh) \
    --tags all,code --extra-vars='pv_ua_nodejs_version=16 pv_ua_code_version=1.64.2'
```
