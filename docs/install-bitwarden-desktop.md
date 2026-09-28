# [Install Bitwarden Desktop](https://bitwarden.com/download/#downloads-desktop)

Downloads the latest Bitwarden Desktop AppImage. Because `bitwarden/clients` is a monorepo with mixed release types, the script searches the most recent 100 GitHub releases for the newest `desktop-v*` tag. It configures the desktop entry with Wayland and Ozone platform flags and sets the password store to `kwallet6`.

**Supported architectures:** `x86_64`

## Environment Variables

| Variable                           | Default       | Description                                            |
| ---------------------------------- | ------------- | ------------------------------------------------------ |
| `BITWARDEN_DESKTOP_LATEST_VERSION` | auto-detected | Bitwarden Desktop version to install (e.g. `2026.5.0`) |

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-bitwarden-desktop.sh)
```
