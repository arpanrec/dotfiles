# bw-import-ssh.sh

Interactive script to pull SSH private keys from a Bitwarden vault and install them to `~/.ssh/`. For each key it offers: overwrite protection, passphrase removal, public key generation, and PPK conversion (requires `puttygen`).

**Prerequisites:** `bw`, `jq`

## Configured Keys

| Bitwarden Item                   | Target File              |
| -------------------------------- | ------------------------ |
| `GitHub - arpanrec`              | `~/.ssh/github.com`      |
| `OPENSSH ID_ECDSA`               | `~/.ssh/id_ecdsa`        |
| `GitLab - arpanrec`              | `~/.ssh/gitlab.com`      |
| `Linode - arpanrecme`            | `~/.ssh/linode_ssh_key`  |
| `Router - BLR Flat - r1-tpla9v6` | `~/.ssh/r1-tpla9v6.key`  |
| `SCM - blr-home`                 | `~/.ssh/id_scm_blr_home` |
