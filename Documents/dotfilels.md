# Scripts

## Debian

```bash
sudo -H -u root bash -c '/bin/bash <(curl -s https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/debian-cloudinit-ansible)'
```

## Server Workspace

Setup workspace for development using [server workspace playbook](https://github.com/arpanrec/nebula/blob/main/playbooks/server_workspace.md)

```bash
bash <(curl https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/server_workspace)
```

For custom/silent install tags, extra-vars are optional

```bash
bash <(curl https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/server_workspace) \
--tags all,code \
--extra-vars='pv_ua_nodejs_version=16 pv_ua_code_version=1.64.2'
```

## MinIO

Install minio server on a single node.

### Requirements

Secrets in [`./.env`](./.env) file:

First argument to `install.sh` is the path to the `.env` file.

```bash
sudo ./install.sh ./.env
```

```bash
INIT_STORAGE_MINIO_DOMAIN="Hostname for minio"
INIT_STORAGE_MINIO_PROTOCOL=https
INIT_STORAGE_MINIO_PORT=9000
INIT_STORAGE_MINIO_CONSOLE_PORT=9001
INIT_STORAGE_MINIO_ROOT_USER=svc_minio_admin
INIT_STORAGE_MINIO_ROOT_PASSWORD="Password for root user (Not access key/secret credentials)"
INIT_STORAGE_MINIO_EMAIL="MinIO Admin email address"

INIT_STORAGE_MINIO_CERT_PRIV_KEY_BASE64="Base64 encoded private key"

INIT_STORAGE_MINIO_CERT_BASE64="Base64 encoded certificate"

INIT_STORAGE_MINIO_CERT_CHAIN_BASE64="Base64 encoded certificate chain"

INIT_STORAGE_MINIO_CERT_FULL_CHAIN_BASE64="Base64 encoded full certificate chain"
```

### Post-installation

In MinIO Console Set the region to `ap-south-1`
