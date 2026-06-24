# bw-login.sh

Handles the full Bitwarden CLI authentication flow: detects current status (`unauthenticated` / `locked` / `unlocked`), offers API key login or email/password login, unlocks the vault, and optionally saves credentials and the session token to a file (default: `~/.env`).

## Environment Variables

| Variable              | Default        | Description                                            |
| --------------------- | -------------- | ------------------------------------------------------ |
| `BW_API_KEY_FILE`     | `${HOME}/.env` | File to read/write `BW_CLIENTID` and `BW_CLIENTSECRET` |
| `BW_API_SESSION_FILE` | `${HOME}/.env` | File to write the `BW_SESSION` token                   |
