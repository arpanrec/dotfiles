# [Install DBeaver Community](https://dbeaver.io/download/)

Downloads the latest DBeaver CE tarball from dbeaver.io, verifies its SHA-256 checksum against the GitHub release asset digest, extracts it to `~/.local/share/dbeaver-ce`, and creates a desktop entry.

**Supported architectures:** `x86_64`, `aarch64`

## Environment Variables

| Variable                           | Default       | Description                                   |
| ---------------------------------- | ------------- | --------------------------------------------- |
| `DBEAVER_COMMUNITY_LATEST_VERSION` | auto-detected | DBeaver CE version to install (e.g. `26.1.0`) |

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-dbeaver-community)
```
