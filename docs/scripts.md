
# Scripts

The scripts in this repository automate various tasks, making it easier to set up and configure my environment. These scripts include:

## [Debian](/.script.d/debian-cloudinit-ansible.sh)

```bash
sudo -H -u root bash -c '/bin/bash <(curl -s https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/debian-cloudinit-ansible.sh)'
```

## [Server Workspace](/.script.d/server-workspace.sh)

Setup workspace for development using [server workspace playbook](https://github.com/arpanrec/arpanrec.nebula/blob/main/playbooks/server_workspace.md)

```bash
bash <(curl https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/server-workspace.sh)
```

For custom/silent install tags, extra-vars are optional

```bash
bash <(curl https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/server-workspace.sh) \
    --tags all,code \
    --extra-vars='pv_ua_nodejs_version=16 pv_ua_code_version=1.64.2'
```

## [MinIO](/.script.d/minio-install.sh)

Install the minio server on a single node.

### Requirements

Secrets in `.env` file:

```env
INIT_STORAGE_MINIO_DOMAIN='Hostname for minio'
INIT_STORAGE_MINIO_PROTOCOL=https
INIT_STORAGE_MINIO_PORT=9000
INIT_STORAGE_MINIO_CONSOLE_PORT=9001
INIT_STORAGE_MINIO_ROOT_USER=svc_minio_admin
INIT_STORAGE_MINIO_ROOT_PASSWORD='Password for root user (Not access key/secret credentials)'
INIT_STORAGE_MINIO_EMAIL='MinIO Admin email address'
INIT_STORAGE_MINIO_CERT_PRIV_KEY_BASE64='Base64 encoded private key'
INIT_STORAGE_MINIO_CERT_BASE64='Base64 encoded certificate'
INIT_STORAGE_MINIO_CERT_CHAIN_BASE64='Base64 encoded certificate chain'
INIT_STORAGE_MINIO_CERT_FULL_CHAIN_BASE64='Base64 encoded full certificate chain'
```

The first argument to [minio-install.sh](/.script.d/minio-install.sh) is the path to the `.env` file.

raw script: <https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/minio-install.sh>

```bash
sudo -H -u root bash -c "/bin/bash <(curl https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/minio-install.sh) $(realpath .env)"
```

### Post-installation

In the MinIO Console Set the region to `ap-south-1`
