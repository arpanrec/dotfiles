# bw-login.sh

Manages the Bitwarden CLI authentication flow: checks the current status (`unauthenticated`, `locked`, or `unlocked`), supports API key or email login, unlocks the vault, and can save credentials and the session token to a file (default: `~/.env`).

## Environment Variables

| Variable              | Default        | Description                                            |
| --------------------- | -------------- | ------------------------------------------------------ |
| `BW_API_KEY_FILE`     | `${HOME}/.env` | File to read/write `BW_CLIENTID` and `BW_CLIENTSECRET` |
| `BW_API_SESSION_FILE` | `${HOME}/.env` | File to write the `BW_SESSION` token                   |
