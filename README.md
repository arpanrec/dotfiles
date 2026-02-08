# My Dotfiles and Scripts Repository

* Caution: If some of my choices trigger you, always remember the legend named `xkcd` and his wisdom about workflow which can be found [here in 1172](https://xkcd.com/1172/). If you are too lazy to read, just know "My setup works for me".

This repository contains my dotfiles and scripts, which I use to set up and configure my development environment. These files are essential for my workflow and help me maintain a consistent environment across different machines.

Dotfiles are configuration files in Linux that start with a dot (e.g. `.bashrc`, `.zshrc`).
They are used to customize and configure your system and applications.
In this repository, you'll find my personal dotfiles for various applications and tools, including:

* Bash: `.bashrc`, `.bash_profile`
* Zsh: `.zshrc`, `.p10k.zsh`
* SSH: `.ssh/config`
* And more...

Wayland is the way to go forward.

## Branches

* Dotfiles are present in [dotfiles-main branch](https://github.com/arpanrec/dotfiles/tree/dotfiles-main)
* Static assets are present in [dotfiles-assets branch](https://github.com/arpanrec/dotfiles/tree/dotfiles-assets), like certificates, public keys, themes, wallpapers etc.

## Hardcoded session files outside session manager directories, like: `~/.config/xfce4/xfconf/xfce-perchannel-xml/` or `~/.config/hype/hype.conf`

Files which might break functions like keyring, XDG portal, or display render

KDE

* `.config/chrome-flags.conf`: password-store is pinned to kwallet6.
* `.config/brave-flags.conf`: password-store is pinned to kwallet6.
* `.config/xdg-desktop-portal/portals.conf`: FileChooser is pinned to kde.
* `.local/share/dbus-1/services/org.freedesktop.secrets.service`: secret manager is pinned to /usr/bin/kwalletd6.
* `install-vscode.sh`: password-store is pinned to kwallet5 in ~/.vscode/argv.json

## Installation

Environment variables:

* `CLEAN_DOT_INSTALL`: This will delete existing dotfiles bare repository at `~/.dotfiles` if set to `yes`.

```bash
export CLEAN_DOT_INSTALL=no; \
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-dotfiles.sh)
```

## Scripts

### Set up Workspace

Set up workspace for development using [server workspace playbook](https://github.com/arpanrec/arpanrec.nebula/blob/main/playbooks/server_workspace.md)

Variables

* `NEBULA_TMP_DIR`: Temporary directory to download the playbook. Default `${HOME}/.tmp`.
* `NEBULA_VERSION`: Version of the nebula playbook to be used. Default `1.14.63`.
* `NEBULA_VENV_DIR`: Directory to create the ansible virtual environment. Default `${NEBULA_TMP_DIR}/venv`.
* `NEBULA_EXTRA_VARS_JSON_FILE`: Extra vars for the playbook in JSON format. Default `${NEBULA_TMP_DIR}/extra_vars.json`.

* `DEFAULT_ROLES_PATH`: Default roles path. Default `${NEBULA_TMP_DIR}/roles`.
* `ANSIBLE_ROLES_PATH`: Ansible roles path. Default `${DEFAULT_ROLES_PATH}`.
* `ANSIBLE_COLLECTIONS_PATH`: Ansible collections path. Default `${NEBULA_TMP_DIR}/collections`.
* `ANSIBLE_INVENTORY`: Ansible YAML inventory file. Default `${NEBULA_TMP_DIR}/inventory`.

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/setup-workspace.sh)
```

For custom/silent install tags, extra-vars are optional

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/setup-workspace.sh) \
    --tags all,code --extra-vars='pv_ua_nodejs_version=16 pv_ua_code_version=1.64.2'
```

### Install themes

* [Nordic](https://github.com/EliverLara/Nordic)
* [Nordic KDE](https://github.com/EliverLara/Nordic-kde)
* [Layan KDE](https://github.com/vinceliuice/Layan-kde)
* [Layan GTK Theme](https://github.com/vinceliuice/Layan-gtk-theme)
* [Sweet](https://github.com/EliverLara/Sweet)
* [Sweet Mars](https://github.com/EliverLara/Sweet/tree/mars)
* [Tela Icons](https://github.com/vinceliuice/Tela-icon-theme)
* [Candy Icons](https://github.com/EliverLara/candy-icons)
* [Layan Cursors](https://github.com/vinceliuice/Layan-cursors)
* [BeautyLine](https://github.com/gvolpe/BeautyLine)
* [Nerd Fonts: JetBrainsMono, Hack, Meslo](https://github.com/ryanoasis/nerd-fonts)
* [Cascadia Code](https://github.com/microsoft/cascadia-code)

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-themes.sh)
```

### [Install Rustus](https://rust-lang.org/tools/install/)

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-rustus.sh)
```

### [Install Neovim from Source](https://github.com/neovim/neovim/wiki/Building-Neovim/688be28f98c18e73b5043879b5963287a9b13d6c)

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-neovim.sh)
```

### [Install Visual Studio Code](https://code.visualstudio.com/Download)

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-vscode.sh)
```

### [Install JetBrains Toolbox App](https://www.jetbrains.com/toolbox-app/)

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-jetbrains-toolbox.sh)
```

### [Install Bitwarden Desktop AppImage](https://bitwarden.com/download/#downloads-desktop)

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-bitwarden-desktop.sh)
```

### [Install Postman](https://www.postman.com/downloads/)

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-postman.sh)
```

### [Install DBeaver Community](https://dbeaver.io/download/)

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-dbeaver-community.sh)
```

### Setup Debian

Bootstrap a Debian machine with a user and some basic tools using [cloudinit playbook](https://github.com/arpanrec/arpanrec.nebula/blob/main/playbooks/cloudinit.md).
And then set up the user workspace using [setup-workspace](#set-up-workspace)

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
* `NEBULA_VERSION` : Version of the nebula playbook to be used. Default `1.14.63`.
* `NEBULA_VENV_DIR` : Directory to create the ansible virtual environment. Default `${NEBULA_TMP_DIR}/venv`.
* `NEBULA_CLOUD_INIT_AUTHORIZED_KEYS_FILE` : Authorized keys file for the user. Default `${NEBULA_TMP_DIR}/authorized_keys`.
* `NEBULA_REQUIREMENTS_FILE` : Ansible requirements file. Default `${NEBULA_TMP_DIR}/requirements.yml`.
  
* `DEFAULT_ROLES_PATH` : Directory to clone the ansible roles. Default `${NEBULA_TMP_DIR}/roles`.
* `ANSIBLE_ROLES_PATH` : Ansible roles path. Default `${DEFAULT_ROLES_PATH}`.
* `ANSIBLE_COLLECTIONS_PATH` : Ansible collections path. Default `${NEBULA_TMP_DIR}/collections`.
* `ANSIBLE_INVENTORY` : Ansible inventory. Default `${NEBULA_TMP_DIR}/inventory.yml`.

```bash
CLOUD_INIT_DOMAIN=arpanrec.com sudo -E -H -u root bash -c '/bin/bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/setup-debian.sh)'
```

or for development machine

```bash
CLOUD_INIT_IS_DEV_MACHINE=true CLOUD_INIT_INSTALL_DOCKER=true sudo -E -H -u root \
    bash -c '/bin/bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/setup-debian.sh)'
```

or for a development machine with a domain

```bash
CLOUD_INIT_DOMAIN=blr-home.arpanrec.com CLOUD_INIT_IS_DEV_MACHINE=true CLOUD_INIT_INSTALL_DOCKER=true sudo -E -H -u root \
    bash -c '/bin/bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/setup-debian.sh)'
```

### [Linode Stack Script](https://cloud.linode.com/stackscripts/1164660)

Specific script for Linode to set up a new machine using [setup-debian](#setup-debian) script.
It also adds itself to root crontab to run on every day.
Every time it will pull the script from [GitHub](https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/linode-stack-script.sh).

Variables:

* `CLOUD_INIT_COPY_ROOT_SSH_KEYS` : Copy root SSH keys to the user. Default `true`.
* `CLOUD_INIT_IS_DEV_MACHINE` : Install development tools. Default `false`.
* `CLOUD_INIT_INSTALL_DOTFILES` : Install dotfiles for the user. Default `true`.
* `CLOUD_INIT_WEB_SERVER_FQDN` : Web server fully qualified domain name. Default `""`.
* `CLOUD_INIT_INSTALL_DOCKER` : Install docker. Default `false`.

Variables from Linode:

* `LINODE_ID`: Example: `66627286`
* `LINODE_LISHUSERNAME` Example: `linode66627286`
* `LINODE_RAM`: Example: `2048`
* `LINODE_DATACENTERID`: Example: `14`

## Script

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
