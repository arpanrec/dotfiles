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

## Linode Stack Script

```bash
#!/usr/bin/env bash
set -euo pipefail

# <UDF name="CLOUD_INIT_COPY_ROOT_SSH_KEYS" Label="Copy Root SSH Keys to current user" oneOf="true,false" default="true"/>
# <UDF name="CLOUD_INIT_IS_DEV_MACHINE" Label="Install development tool chain" oneOf="true,false" default="false"/>
# <UDF name="CLOUD_INIT_INSTALL_DOTFILES" Label="Install dotfiles" oneOf="true,false" default="true"/>
# <udf name="CLOUD_INIT_WEB_SERVER_FQDN" label="Web server fully qualified domain name" example="example.com" default=""/>

/bin/bash <(curl -sSL https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/linode-stack-script.sh) |
    tee -a /root/linode-stack-script.log

```
