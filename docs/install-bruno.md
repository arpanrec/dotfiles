# [Install Bruno](https://www.usebruno.com/downloads/)

Downloads the latest Bruno API client AppImage from GitHub Releases, extracts the bundled icon, and creates a desktop entry.

**Supported architectures:** `x86_64`, `aarch64`

## Environment Variables

| Variable               | Default       | Description                              |
| ---------------------- | ------------- | ---------------------------------------- |
| `BRUNO_LATEST_VERSION` | auto-detected | Bruno version to install (e.g. `v4.2.1`) |

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-bruno)
```
