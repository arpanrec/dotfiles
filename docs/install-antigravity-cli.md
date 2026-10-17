# [Install Antigravity CLI](https://github.com/google-antigravity/antigravity-cli)

Downloads the latest Antigravity CLI release for the detected architecture from GitHub Releases and links the `antigravity` binary into `~/.local/bin` as `agy`.

**Supported architectures:** `x86_64`, `aarch64`

## Environment Variables

| Variable                         | Default       | Description                                       |
| -------------------------------- | ------------- | ------------------------------------------------- |
| `ANTIGRAVITY_CLI_LATEST_VERSION` | auto-detected | Antigravity CLI version to install (e.g. `1.4.0`) |

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-antigravity-cli)
```
