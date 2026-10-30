# [Install Visual Studio Code](https://code.visualstudio.com/Download)

Downloads the latest stable VS Code tarball, verifies its SHA-256 checksum against the hash published by the VS Code update API, extracts it to `~/.local/share/vscode`, creates desktop entries (including a URL handler for the `vscode://` scheme), symlinks the binary to `~/.local/bin/code`, configures `kwallet5` for secret storage, and installs extensions for Python, Go, Rust, Angular, Terraform, Ansible, Docker, and others.

**Supported architectures:** `x86_64`, `aarch64`

## Environment Variables

| Variable                | Default       | Description                                 |
| ----------------------- | ------------- | ------------------------------------------- |
| `VSCODE_LATEST_VERSION` | auto-detected | VS Code version to install (e.g. `1.142.0`) |

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-vscode)
```
