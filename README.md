# Dotfiles

Personal dotfiles and setup scripts for Linux workstations. Wayland-native configuration targeting KDE Plasma and Hyprland on Arch Linux, with provisioning support for Debian-based servers.

## Platform Notes

Several configurations are hardcoded outside of session manager directories:

| File                                                           | Purpose                                                      |
| -------------------------------------------------------------- | ------------------------------------------------------------ |
| `.config/chrome-flags.conf`                                    | Password store pinned to `kwallet6`                          |
| `.config/brave-flags.conf`                                     | Password store pinned to `kwallet6`                          |
| `.config/xdg-desktop-portal/portals.conf`                      | FileChooser pinned to KDE portal                             |
| `.local/share/dbus-1/services/org.freedesktop.secrets.service` | Secret manager pinned to `/usr/bin/kwalletd6`                |
| `install-vscode.sh`                                            | Password store pinned to `kwallet5` in `~/.vscode/argv.json` |

## Repository Branches

| Branch                                                                     | Contents                                                     |
| -------------------------------------------------------------------------- | ------------------------------------------------------------ |
| [`dotfiles/main`](https://github.com/arpanrec/dotfiles/tree/dotfiles/main) | Dotfiles tracked via bare git repository                     |
| [`assets`](https://github.com/arpanrec/dotfiles/tree/assets)               | Static assets: certificates, public keys, themes, wallpapers |

---

## Installation

### Install Dotfiles

Clones the repository as a bare git repo into `~/.dotfiles`, checks out the `dotfiles/main` branch, and sets up shell enhancements: Oh My Zsh, Powerlevel10k, fzf, zsh-syntax-highlighting, zsh-autosuggestions, zsh-completions, and bash-it. Also appends the owner's public SSH key to `~/.ssh/authorized_keys`.

**Environment Variables:**

| Variable            | Default | Description                                                                                                |
| ------------------- | ------- | ---------------------------------------------------------------------------------------------------------- |
| `CLEAN_DOT_INSTALL` | `no`    | Set to `yes` to delete existing dotfiles bare repo and all shell framework directories before reinstalling |

```bash
export CLEAN_DOT_INSTALL=no
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-dotfiles.sh)
```

Clean reinstall (removes existing dotfiles bare repo and shell frameworks before installing):

```bash
CLEAN_DOT_INSTALL=yes bash <(curl -sSL --connect-timeout 10 --max-time 10 https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-dotfiles.sh)
```

---

## Workspace Setup

### Set Up Development Workspace

Provisions a full developer toolchain using the [arpanrec.nebula server_workspace playbook](https://github.com/arpanrec/arpanrec.nebula/blob/main/playbooks/server_workspace.md) via Ansible. Run as a **non-root user**. When called without arguments, an interactive prompt selects which optional tool tags to install (Node.js, Go, Java, Vault, Terraform, Pulumi, Bitwarden SDK). Custom tags and extra vars can be passed directly.

**Environment Variables:**

| Variable                      | Default                             | Description                                |
| ----------------------------- | ----------------------------------- | ------------------------------------------ |
| `NEBULA_TMP_DIR`              | `${HOME}/.tmp`                      | Temporary directory for playbook downloads |
| `NEBULA_VERSION`              | `1.14.67`                           | Version of the nebula playbook             |
| `NEBULA_VENV_DIR`             | `${NEBULA_TMP_DIR}/venv`            | Python virtual environment directory       |
| `NEBULA_EXTRA_VARS_JSON_FILE` | `${NEBULA_TMP_DIR}/extra_vars.json` | Extra vars for the playbook in JSON format |
| `DEFAULT_ROLES_PATH`          | `${NEBULA_TMP_DIR}/roles`           | Default Ansible roles path                 |
| `ANSIBLE_ROLES_PATH`          | `${DEFAULT_ROLES_PATH}`             | Ansible roles path override                |
| `ANSIBLE_COLLECTIONS_PATH`    | `${NEBULA_TMP_DIR}/collections`     | Ansible collections path                   |
| `ANSIBLE_INVENTORY`           | `${NEBULA_TMP_DIR}/inventory`       | Ansible inventory file                     |

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

---

## Server Provisioning

### Setup Debian

Bootstraps a Debian machine as root using the [arpanrec.nebula cloudinit playbook](https://github.com/arpanrec/arpanrec.nebula/blob/main/playbooks/cloudinit.md). Sets up locale, timezone, a non-root user with SSH key access, and optionally installs dotfiles, the development workspace toolchain, and Docker. Applies a lock file to prevent concurrent or duplicate runs.

> Any variable whose name ends with `_FILE` will be written to a file; the directory is created automatically and ownership is set to root.

**Environment Variables:**

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
| `NEBULA_VERSION`                         | `1.14.67`                             | Nebula playbook version                                    |
| `NEBULA_VENV_DIR`                        | `${NEBULA_TMP_DIR}/venv`              | Python virtual environment directory                       |
| `NEBULA_CLOUD_INIT_AUTHORIZED_KEYS_FILE` | `${NEBULA_TMP_DIR}/authorized_keys`   | Authorized keys file for the created user                  |
| `NEBULA_REQUIREMENTS_FILE`               | `${NEBULA_TMP_DIR}/requirements.yml`  | Ansible requirements file                                  |
| `DEFAULT_ROLES_PATH`                     | `${NEBULA_TMP_DIR}/roles`             | Default Ansible roles path                                 |
| `ANSIBLE_ROLES_PATH`                     | `${DEFAULT_ROLES_PATH}`               | Ansible roles path override                                |
| `ANSIBLE_COLLECTIONS_PATH`               | `${NEBULA_TMP_DIR}/collections`       | Ansible collections path                                   |
| `ANSIBLE_INVENTORY`                      | `${NEBULA_TMP_DIR}/inventory.yml`     | Ansible inventory file                                     |

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

### Linode Stack Script

Extends [Setup Debian](#setup-debian) for Akamai/Linode VMs. Validates required Linode metadata variables (`LINODE_ID`, `LINODE_LISHUSERNAME`, `LINODE_RAM`, `LINODE_DATACENTERID`), persists them to `/etc/environment`, installs cron, and schedules itself to re-run daily at 01:00 from the latest version on GitHub. Uses a lock file to prevent concurrent executions.

Deployed at: [Linode Stack Script #1164660](https://cloud.linode.com/stackscripts/1164660)

**Linode-injected Variables:**

| Variable              | Example          |
| --------------------- | ---------------- |
| `LINODE_ID`           | `66627286`       |
| `LINODE_LISHUSERNAME` | `linode66627286` |
| `LINODE_RAM`          | `2048`           |
| `LINODE_DATACENTERID` | `14`             |

**Configurable Variables:**

| Variable                        | Default       |
| ------------------------------- | ------------- |
| `CLOUD_INIT_COPY_ROOT_SSH_KEYS` | `true`        |
| `CLOUD_INIT_IS_DEV_MACHINE`     | `false`       |
| `CLOUD_INIT_INSTALL_DOTFILES`   | `true`        |
| `CLOUD_INIT_INSTALL_DOCKER`     | `false`       |
| `CLOUD_INIT_WEB_SERVER_FQDN`    | `""`          |
| `CLOUD_INIT_DOMAIN`             | `easyiac.com` |

**Stack Script body** (paste into Linode dashboard):

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

---

## Arch Linux Setup

### Setup Arch Server

Configures a freshly installed Arch Linux base system (run from within `arch-chroot` or on a live system). Sets timezone to `Asia/Kolkata`, locale to `en_US.UTF-8`, hostname, pacman, and installs a comprehensive package set covering networking, storage, dev toolchains, cross-compilers, monitoring, and optionally Docker and NVIDIA drivers. Randomises the root password, creates a `wheel`-group admin user, hardens SSH, and optionally sets up `systemd-boot` with Secure Boot signing via `sbctl`.

**Allowed Hostnames:** `s1-dev`, `s2-dev`

**Interactive Prompts:**

| Prompt                 | Description                                          |
| ---------------------- | ---------------------------------------------------- |
| Systemd Secure Boot    | Install and sign bootloader with `sbctl`             |
| Enable pacman multilib | Enable the multilib repository                       |
| NVIDIA with DRM        | Install `nvidia-open` and configure DRM mode-setting |
| Install Docker         | Install Docker and related packages                  |
| Update mirrorlist      | Run `reflector` to pick fastest Indian mirrors       |

```bash
bash setup-arch-server.sh [hostname]
```

### Setup Arch Workstation

Installs the full graphical workstation environment on top of an Arch base. Primary compositor is **Hyprland** with Waybar, Rofi, Dunst, and Kitty. KDE components (KWallet, Dolphin, Konsole, Gwenview, etc.) are installed for Wayland portal support, secret management, and file management, with an option to enable the full KDE Plasma session via SDDM.

Installs AUR packages (yay, NordVPN, Brave, Google Chrome, OnlyOffice, Yubico Authenticator, SDDM Silent theme) using a temporary unprivileged build user. Configures PipeWire audio, CUPS printing, Bluetooth, WireGuard, and GPU drivers (NVIDIA/AMD/Intel) as detected.

**Interactive Prompts:**

| Prompt               | Description                                      |
| -------------------- | ------------------------------------------------ |
| KDE as second option | Install KDE components and portal support        |
| Minimal KDE Plasma   | Install `plasma` and `plasma-meta` metapackages  |
| NVIDIA with DRM      | Install NVIDIA drivers and environment variables |

```bash
bash setup-arch-workstation.sh
```

---

## Application Installers

All installers download to `~/.cache/dotfiles-tmp-download-dir` and skip re-downloading if the file already exists. Desktop entries are written to `~/.local/share/applications/`.

### Install Themes

Installs GTK, KDE Plasma, icon, cursor, and font assets. Detects GNOME Shell and switches between Layan GTK and Layan KDE accordingly.

**Installed assets:**

| Category         | Assets                                                                                                                                                                                                                                                                                                                                |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GTK / KDE themes | [Nordic](https://github.com/EliverLara/Nordic), [Nordic KDE](https://github.com/EliverLara/Nordic-kde), [Layan KDE](https://github.com/vinceliuice/Layan-kde), [Layan GTK](https://github.com/vinceliuice/Layan-gtk-theme), [Sweet](https://github.com/EliverLara/Sweet), [Sweet Mars](https://github.com/EliverLara/Sweet/tree/mars) |
| Icon themes      | [Tela Icons](https://github.com/vinceliuice/Tela-icon-theme), [Candy Icons](https://github.com/EliverLara/candy-icons), [BeautyLine](https://github.com/gvolpe/BeautyLine)                                                                                                                                                            |
| Cursor themes    | [Layan Cursors](https://github.com/vinceliuice/Layan-cursors), [Bibata Cursor](https://github.com/ful1e5/Bibata_Cursor) (latest release)                                                                                                                                                                                              |
| Fonts            | [Nerd Fonts: JetBrainsMono, Hack, Meslo](https://github.com/ryanoasis/nerd-fonts), [Cascadia Code](https://github.com/microsoft/cascadia-code), MesloLGS NF (patched for Powerlevel10k)                                                                                                                                               |
| Wallpapers       | From the `assets` branch of this repository                                                                                                                                                                                                                                                                                           |

**Prerequisites:** `curl`, `git`, `unzip`, `gtk-update-icon-cache`, `jq`, `fc-cache`

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-themes.sh)
```

### [Install Rustup](https://rust-lang.org/tools/install/)

Installs Rust via `rustup` with the `complete` profile, then installs `cargo-binstall` and uses it to add `fd-find`, `ripgrep`, and `uv`.

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-rustup.sh)
```

### [Install Neovim from Source](https://github.com/neovim/neovim/blob/master/BUILD.md)

Fetches the latest Neovim release tag, clones the source, and builds with `CMAKE_BUILD_TYPE=Release` using all available CPU cores. Installs to `NEOVIM_INSTALL_DIR` (default: `~/.local`).

**Prerequisites:** `curl`, `git`, `unzip`, `ninja`, `cmake`, `gcc`, `gettext`, `yarn`, `jq`

**Environment Variables:**

| Variable             | Default          | Description                               |
| -------------------- | ---------------- | ----------------------------------------- |
| `NEOVIM_INSTALL_DIR` | `${HOME}/.local` | Install prefix                            |
| `NVIM_APPNAME`       | `nvim`           | App name used for state/cache directories |

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-neovim.sh)
```

### [Install Visual Studio Code](https://code.visualstudio.com/Download)

Downloads the latest stable VS Code tarball, extracts to `~/.local/share/vscode`, creates desktop entries (including a URL handler for `vscode://` scheme), symlinks the binary to `~/.local/bin/code`, configures `kwallet5` for secret storage, and installs a curated set of extensions (Python, Java, Go, Rust, Angular, Terraform, Ansible, Docker, GitHub, and more).

**Supported architectures:** `x86_64`, `aarch64`

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-vscode.sh)
```

### [Install JetBrains Toolbox App](https://www.jetbrains.com/toolbox-app/)

Fetches the latest Toolbox release metadata from the JetBrains API, downloads the archive with SHA-256 checksum verification, extracts to `~/.local/share/jetbrains-toolbox`, and launches the app.

**Supported architectures:** `x86_64`, `aarch64`

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-jetbrains-toolbox.sh)
```

### [Install Bitwarden Desktop](https://bitwarden.com/download/#downloads-desktop)

Downloads the Bitwarden Desktop AppImage. Version is pinned via the `LATEST_VERSION` variable (default: `2026.5.0`). Configured with Wayland/Ozone platform flags and `kwallet6` password store.

**Supported architectures:** `x86_64`

**Environment Variables:**

| Variable         | Default    | Description                          |
| ---------------- | ---------- | ------------------------------------ |
| `LATEST_VERSION` | `2026.5.0` | Bitwarden Desktop version to install |

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-bitwarden-desktop.sh)
```

### [Install Bruno](https://www.usebruno.com/downloads/)

Downloads the latest Bruno API client AppImage from GitHub Releases, extracts the bundled icon, and creates a desktop entry.

**Supported architectures:** `x86_64`, `aarch64`

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-bruno.sh)
```

### [Install DBeaver Community](https://dbeaver.io/download/)

Downloads the latest DBeaver CE tarball from dbeaver.io, verifies the SHA-256 checksum, extracts to `~/.local/share/dbeaver-ce`, and creates a desktop entry.

**Supported architectures:** `x86_64`, `aarch64`

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-dbeaver-community.sh)
```

### [Install Postman](https://www.postman.com/downloads/)

Downloads the Postman tarball. Version is pinned in the script (`12.11.3`). See [Postman release notes](https://www.postman.com/release-notes/postman-app/) to update.

**Supported architectures:** `x86_64`

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-postman.sh)
```

### [Install Trilium Notes](https://triliumnotes.org/en/get-started/)

Downloads the latest TriliumNext AppImage from GitHub Releases, extracts the bundled icon, and creates a desktop entry.

**Supported architectures:** `x86_64`, `aarch64`

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-trilium.sh)
```

### [Install Joplin](https://joplinapp.org/help/install/)

Downloads the latest Joplin Desktop AppImage from GitHub Releases, extracts the bundled icon, and creates a desktop entry.

**Supported architectures:** `x86_64` only

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-joplin.sh)
```

### [Install Telegram Desktop](https://github.com/telegramdesktop/tdesktop)

Downloads the latest Telegram Desktop tarball from GitHub Releases, extracts to `~/.local/share/Telegram`, and launches the app once so it can auto-generate its own desktop entry.

**Supported architectures:** `x86_64` only

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-telegram-desktop.sh)
```

---

## Bitwarden Utilities

These scripts require `bw` (Bitwarden CLI) to be installed and unlocked. Run `bw-login.sh` first.

### bw-login.sh

Handles the full Bitwarden CLI authentication flow: detects current status (`unauthenticated` / `locked` / `unlocked`), offers API key login or email/password login, unlocks the vault, and optionally saves credentials and the session token to a file (default: `~/.env`).

**Environment Variables:**

| Variable              | Default        | Description                                            |
| --------------------- | -------------- | ------------------------------------------------------ |
| `BW_API_KEY_FILE`     | `${HOME}/.env` | File to read/write `BW_CLIENTID` and `BW_CLIENTSECRET` |
| `BW_API_SESSION_FILE` | `${HOME}/.env` | File to write the `BW_SESSION` token                   |

### bw-import-ssh.sh

Interactive script to pull SSH private keys from a Bitwarden vault and install them to `~/.ssh/`. For each key it offers: overwrite protection, passphrase removal, public key generation, and PPK conversion (requires `puttygen`).

**Configured keys:**

| Bitwarden Item                   | Target File              |
| -------------------------------- | ------------------------ |
| `GitHub - arpanrec`              | `~/.ssh/github.com`      |
| `OPENSSH ID_ECDSA`               | `~/.ssh/id_ecdsa`        |
| `GitLab - arpanrec`              | `~/.ssh/gitlab.com`      |
| `Linode - arpanrecme`            | `~/.ssh/linode_ssh_key`  |
| `Router - BLR Flat - r1-tpla9v6` | `~/.ssh/r1-tpla9v6.key`  |
| `SCM - blr-home`                 | `~/.ssh/id_scm_blr_home` |

**Prerequisites:** `bw`, `jq`

### bw-import-gpg.sh

Imports a GPG private key from a Bitwarden vault attachment, sets the key's trust level to ultimate, and ensures `~/.gnupg` has correct permissions.

**Configured key:** `GPG_KEY - 1A2249D8FE12E5D3` (attachment: `Arpan_0x1A2249D8FE12E5D3_SECRET.asc`)

**Prerequisites:** `bw`, `jq`, `gpg`

---

## Notes

> If some of my choices trigger you, always remember the legend named `xkcd` and his wisdom about workflow: [xkcd 1172](https://xkcd.com/1172/).
>
> **TL;DR:** My setup works for me.
