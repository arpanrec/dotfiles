# [Install Telegram Desktop](https://github.com/telegramdesktop/tdesktop)

Downloads the latest Telegram Desktop tarball from GitHub Releases, verifies its SHA-256 checksum against the digest GitHub publishes for the release asset, extracts it to `~/.local/share/Telegram`, and launches the app once so it can auto-generate its own desktop entry.

**Supported architectures:** `x86_64` only

## Environment Variables

| Variable                          | Default       | Description                                         |
| --------------------------------- | ------------- | --------------------------------------------------- |
| `TELEGRAM_DESKTOP_LATEST_VERSION` | auto-detected | Telegram Desktop version to install (e.g. `v7.3.1`) |

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-telegram-desktop)
```
