# [Install DBeaver Community](https://dbeaver.io/download/)

Downloads the latest DBeaver CE tarball from dbeaver.io, verifies the SHA-256 checksum, extracts to `~/.local/share/dbeaver-ce`, and creates a desktop entry.

**Supported architectures:** `x86_64`, `aarch64`

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-dbeaver-community.sh)
```
