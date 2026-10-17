# [Install Claude Code](https://github.com/anthropics/claude-code)

Downloads the latest Claude Code release for the detected architecture from GitHub Releases, verifies it against `SHASUMS256.txt`, and links the `claude` binary into `~/.local/bin`. The musl build is used automatically on musl-based systems.

**Supported architectures:** `x86_64`, `aarch64`

## Environment Variables

| Variable                     | Default       | Description                                      |
| ---------------------------- | ------------- | ------------------------------------------------ |
| `CLAUDE_CODE_LATEST_VERSION` | auto-detected | Claude Code version to install (e.g. `v2.1.302`) |

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-claude-code)
```
