# [Server Workspace](/.script.d/server-workspace.sh)

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
