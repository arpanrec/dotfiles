# [Server Workspace](/.script.d/server-workspace.sh)

Setup workspace for development using [server workspace playbook](https://github.com/arpanrec/arpanrec.nebula/blob/main/playbooks/server_workspace.md)

## Variables

* `SERVER_WORKSPACE_TMP_DIR`: Temporary directory to download the playbook. Default `${HOME}/.tmp`.
* `DEFAULT_ROLES_PATH`: Default roles path. Default `${SERVER_WORKSPACE_TMP_DIR}/roles`.
* `ANSIBLE_ROLES_PATH`: Ansible roles path. Default `${DEFAULT_ROLES_PATH}`.
* `ANSIBLE_COLLECTIONS_PATH`: Ansible collections path. Default `${SERVER_WORKSPACE_TMP_DIR}/collections`.
* `ANSIBLE_INVENTORY`: Ansible YAML inventory file. Default `${SERVER_WORKSPACE_TMP_DIR}/inventory`.
* `SERVER_WORKSPACE_EXTRA_VARS_JSON`: Extra vars for the playbook in JSON format. Default `${SERVER_WORKSPACE_TMP_DIR}/server_workspace.json`.
* `NEBULA_VERSION`: Version of the nebula playbook to be used. Default `1.9.1`.

```bash
bash <(curl https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/server-workspace.sh)
```

For custom/silent install tags, extra-vars are optional

```bash
bash <(curl https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/server-workspace.sh) \
    --tags all,code \
    --extra-vars='pv_ua_nodejs_version=16 pv_ua_code_version=1.64.2'
```
