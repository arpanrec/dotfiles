# [Install Postman](https://www.postman.com/downloads/)

Downloads the Postman tarball. The default version is pinned in the script (`12.11.3`); set `POSTMAN_LATEST_VERSION` to install a different one. Check the [Postman release notes](https://www.postman.com/release-notes/postman-app/) when updating.

**Supported architectures:** `x86_64`

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-postman)
```
