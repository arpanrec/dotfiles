# [Install Codex CLI](https://github.com/openai/codex)

Downloads the latest Codex CLI `codex-package` release for the detected architecture from GitHub Releases, verifies it against `codex-package_SHA256SUMS`, and copies the `codex` and `codex-code-mode-host` binaries directly into `~/.local/bin` (no symlinks).

Codex normally resolves its bundled ripgrep and Linux sandbox helper via the `codex-path/` and `codex-resources/` directories that ship next to `bin/` inside the release archive. Copying only the binaries flat into `~/.local/bin` drops that layout, so Codex falls back to `rg` and `bwrap` found on `PATH` instead. Install them system-wide (e.g. `pacman -S ripgrep bubblewrap`) for full search and sandbox functionality; the script warns if either is missing.

**Supported architectures:** `x86_64`, `aarch64` (Linux only, musl builds)

## Environment Variables

| Variable                   | Default       | Description                                         |
| -------------------------- | ------------- | --------------------------------------------------- |
| `CODEX_CLI_LATEST_VERSION` | auto-detected | Codex CLI version to install (e.g. `rust-v0.165.0`) |

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-codex-cli)
```
