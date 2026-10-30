# [Install Trilium Notes](https://triliumnotes.org/en/get-started/)

Downloads the latest TriliumNext AppImage from GitHub Releases, verifies its SHA-256 checksum against the digest GitHub publishes for the release asset, extracts the bundled icon, and creates a desktop entry.

**Supported architectures:** `x86_64`, `aarch64`

## Environment Variables

| Variable                 | Default       | Description                                  |
| ------------------------ | ------------- | -------------------------------------------- |
| `TRILIUM_LATEST_VERSION` | auto-detected | Trilium version to install (e.g. `v0.106.0`) |

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-trilium)
```
