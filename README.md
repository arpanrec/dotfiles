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

## Install Dotfiles

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

- [Set Up Development Workspace](docs/setup-workspace.md) — Ansible-based developer toolchain provisioning

## Server Provisioning

- [Setup Debian](docs/setup-debian.md) — Bootstrap a Debian machine with Ansible
- [Linode Stack Script](docs/linode-stack-script.md) — Extends Setup Debian for Akamai/Linode VMs

## Arch Linux Setup

- [Setup Arch Server](docs/setup-arch-server.md) — Base system configuration for Arch Linux
- [Setup Arch Workstation](docs/setup-arch-workstation.md) — Full graphical workstation environment

## Fedora Setup

- [Setup Fedora KDE](docs/setup-fedora-kde.md) — Fedora KDE workstation setup

## Application Installers

All installers download to `~/.cache/dotfiles-tmp-download-dir` and skip re-downloading if the file already exists. Desktop entries are written to `~/.local/share/applications/`.

- [Install Themes](docs/install-themes.md) — GTK, KDE, icon, cursor, and font assets
- [Install Rustup](docs/install-rustup.md) — Rust toolchain with cargo-binstall extras
- [Install Neovim](docs/install-neovim.md) — Build Neovim from source
- [Install Visual Studio Code](docs/install-vscode.md) — VS Code with extensions
- [Install JetBrains Toolbox](docs/install-jetbrains-toolbox.md) — JetBrains Toolbox App
- [Install Bitwarden Desktop](docs/install-bitwarden-desktop.md) — Bitwarden Desktop AppImage
- [Install Bruno](docs/install-bruno.md) — Bruno API client
- [Install DBeaver Community](docs/install-dbeaver-community.md) — DBeaver CE database tool
- [Install Nextcloud Desktop](docs/install-nextcloud-desktop.md) — Nextcloud Desktop AppImage
- [Install Postman](docs/install-postman.md) — Postman API client
- [Install Trilium Notes](docs/install-trilium.md) — TriliumNext note-taking app
- [Install Joplin](docs/install-joplin.md) — Joplin Desktop note-taking app
- [Install Telegram Desktop](docs/install-telegram-desktop.md) — Telegram Desktop client

## Bitwarden Utilities

These scripts require `bw` (Bitwarden CLI) to be installed and unlocked. Run `bw-login.sh` first.

- [bw-login.sh](docs/bw-login.md) — Bitwarden CLI authentication flow
- [bw-import-ssh.sh](docs/bw-import-ssh.md) — Import SSH keys from Bitwarden vault
- [bw-import-gpg.sh](docs/bw-import-gpg.md) — Import GPG key from Bitwarden vault

---

## Notes

> If some of my choices trigger you, always remember the legend named `xkcd` and his wisdom about workflow: [xkcd 1172](https://xkcd.com/1172/).
>
> **TL;DR:** My setup works for me.
