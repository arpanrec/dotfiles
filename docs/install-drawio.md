# [Install draw.io Desktop](https://github.com/jgraph/drawio-desktop)

Downloads the latest draw.io Desktop AppImage from GitHub Releases, verifies its SHA-256 checksum against the digest
GitHub publishes for the release asset, extracts the bundled icon, and creates a desktop entry.

**Supported architectures:** `x86_64`, `aarch64` (`arm64`)

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-drawio)
```
