# [Linode Stack Script](/.script.d/linode-stack-script.sh)

[Public Script: 1164660](https://cloud.linode.com/stackscripts/1164660)

Specific script for Linode to set up a new machine. It also adds itself to root crontab to run on every day.
Every time it will pull the script from [GitHub](https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/linode-stack-script.sh).

Variables:

* `CLOUD_INIT_COPY_ROOT_SSH_KEYS` : Copy root SSH keys to the user. Default `true`.
* `CLOUD_INIT_IS_DEV_MACHINE` : Install development tools. Default `false`.
* `CLOUD_INIT_INSTALL_DOTFILES` : Install dotfiles for the user. Default `true`.
* `CLOUD_INIT_WEB_SERVER_FQDN` : Web server fully qualified domain name. Default `""`.

Variables from Linode:

* `LINODE_ID`: Example: `66627286`
* `LINODE_LISHUSERNAME` Example: `linode66627286`
* `LINODE_RAM`: Example: `2048`
* `LINODE_DATACENTERID`: Example: `14`

## Validate

Make sure the script is the same as the one in the repository.

```bash
curl -sSL --output /tmp/linode-stack-script-github.sh \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/linode-stack-script.sh
curl -sSL --request GET --header 'accept: application/json' \
     --url https://api.linode.com/v4/linode/stackscripts/1164660 |
    jq -r -c -j '.script' | tee /tmp/linode-stack-script-linode.sh
diff /tmp/linode-stack-script-github.sh /tmp/linode-stack-script-linode.sh
```
