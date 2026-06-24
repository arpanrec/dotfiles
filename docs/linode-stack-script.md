# Linode Stack Script

Extends [Setup Debian](setup-debian.md) for Akamai/Linode VMs. Validates required Linode metadata variables (`LINODE_ID`, `LINODE_LISHUSERNAME`, `LINODE_RAM`, `LINODE_DATACENTERID`), persists them to `/etc/environment`, installs cron, and schedules itself to re-run daily at 01:00 from the latest version on GitHub. Uses a lock file to prevent concurrent executions.

Deployed at: [Linode Stack Script #1164660](https://cloud.linode.com/stackscripts/1164660)

## Linode-injected Variables

| Variable              | Example          |
| --------------------- | ---------------- |
| `LINODE_ID`           | `66627286`       |
| `LINODE_LISHUSERNAME` | `linode66627286` |
| `LINODE_RAM`          | `2048`           |
| `LINODE_DATACENTERID` | `14`             |

## Configurable Variables

| Variable                        | Default       |
| ------------------------------- | ------------- |
| `CLOUD_INIT_COPY_ROOT_SSH_KEYS` | `true`        |
| `CLOUD_INIT_IS_DEV_MACHINE`     | `false`       |
| `CLOUD_INIT_INSTALL_DOTFILES`   | `true`        |
| `CLOUD_INIT_INSTALL_DOCKER`     | `false`       |
| `CLOUD_INIT_WEB_SERVER_FQDN`    | `""`          |
| `CLOUD_INIT_DOMAIN`             | `easyiac.com` |

## Stack Script Body

Paste into Linode dashboard:

```bash
#!/usr/bin/env bash
set -euo pipefail

# <UDF name="CLOUD_INIT_COPY_ROOT_SSH_KEYS" Label="Copy Root SSH Keys to current user" oneOf="true,false" default="true"/>
# <UDF name="CLOUD_INIT_IS_DEV_MACHINE" Label="Install development tool chain" oneOf="true,false" default="false"/>
# <UDF name="CLOUD_INIT_INSTALL_DOTFILES" Label="Install dotfiles" oneOf="true,false" default="true"/>
# <UDF name="CLOUD_INIT_INSTALL_DOCKER" Label="Install Docker" oneOf="true,false" default="false"/>
# <udf name="CLOUD_INIT_WEB_SERVER_FQDN" label="Web server fully qualified domain name" example="example.com" default=""/>

/bin/bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/linode-stack-script.sh) |
    tee -a /root/linode-stack-script.log
```
