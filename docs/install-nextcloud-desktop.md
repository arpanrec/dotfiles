# [Install Nextcloud Desktop](https://github.com/nextcloud-releases/desktop/releases)

Downloads the latest Nextcloud Desktop AppImage from GitHub Releases, extracts the bundled icon, and creates a desktop entry with a `nc://` URL scheme handler.

**Supported architectures:** `x86_64` only

## Environment Variables

| Variable                           | Default       | Description                                           |
| ---------------------------------- | ------------- | ----------------------------------------------------- |
| `NEXTCLOUD_DESKTOP_LATEST_VERSION` | auto-detected | Nextcloud Desktop version to install (e.g. `v33.0.5`) |

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-nextcloud-desktop.sh)
```
