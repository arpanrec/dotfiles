# [Install Antigravity IDE](https://antigravity.google/download)

Downloads the latest stable Antigravity IDE standalone tarball, extracts it to `~/.local/share/antigravity-ide`, creates desktop entries (including a URL handler for the `antigravity-ide://` scheme), symlinks the binary to `~/.local/bin/antigravity-ide`, configures `kwallet5` for secret storage, and installs extensions for Python, Go, Rust, Angular, Terraform, Ansible, Docker, and others.

**Supported architectures:** `x86_64`, `aarch64`

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-antigravity-ide.sh)
```
