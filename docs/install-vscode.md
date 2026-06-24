# [Install Visual Studio Code](https://code.visualstudio.com/Download)

Downloads the latest stable VS Code tarball, extracts to `~/.local/share/vscode`, creates desktop entries (including a URL handler for `vscode://` scheme), symlinks the binary to `~/.local/bin/code`, configures `kwallet5` for secret storage, and installs a curated set of extensions (Python, Java, Go, Rust, Angular, Terraform, Ansible, Docker, GitHub, and more).

**Supported architectures:** `x86_64`, `aarch64`

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-vscode.sh)
```
