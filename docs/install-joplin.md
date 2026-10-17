# [Install Joplin](https://joplinapp.org/help/install/)

Downloads the latest Joplin Desktop AppImage from GitHub Releases, extracts the bundled icon, and creates a desktop entry.

**Supported architectures:** `x86_64` only

## Environment Variables

| Variable                | Default       | Description                                |
| ----------------------- | ------------- | ------------------------------------------ |
| `JOPLIN_LATEST_VERSION` | auto-detected | Joplin version to install (e.g. `v3.7.21`) |

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-joplin)
```
