# [Install Rustup](https://rust-lang.org/tools/install/)

Installs Rust via `rustup` with the `complete` profile, then installs `cargo-binstall` and uses it to add `fd-find`, `ripgrep`, and `uv`.

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-rustup.sh)
```
