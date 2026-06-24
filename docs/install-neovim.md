# [Install Neovim from Source](https://github.com/neovim/neovim/blob/master/BUILD.md)

Fetches the latest Neovim release tag, clones the source, and builds with `CMAKE_BUILD_TYPE=Release` using all available CPU cores. Installs to `NEOVIM_INSTALL_DIR` (default: `~/.local`).

**Prerequisites:** `curl`, `git`, `unzip`, `ninja`, `cmake`, `gcc`, `gettext`, `yarn`, `jq`

## Environment Variables

| Variable             | Default          | Description                               |
| -------------------- | ---------------- | ----------------------------------------- |
| `NEOVIM_INSTALL_DIR` | `${HOME}/.local` | Install prefix                            |
| `NVIM_APPNAME`       | `nvim`           | App name used for state/cache directories |

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-neovim.sh)
```
