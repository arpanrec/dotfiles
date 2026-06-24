# [Install Telegram Desktop](https://github.com/telegramdesktop/tdesktop)

Downloads the latest Telegram Desktop tarball from GitHub Releases, extracts to `~/.local/share/Telegram`, and launches the app once so it can auto-generate its own desktop entry.

**Supported architectures:** `x86_64` only

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-telegram-desktop.sh)
```
