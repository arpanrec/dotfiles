# [Install JetBrains Toolbox App](https://www.jetbrains.com/toolbox-app/)

Fetches the latest Toolbox release metadata from the JetBrains API, downloads the archive with SHA-256 checksum verification, extracts to `~/.local/share/jetbrains-toolbox`, and launches the app.

**Supported architectures:** `x86_64`, `aarch64`

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-jetbrains-toolbox.sh)
```
