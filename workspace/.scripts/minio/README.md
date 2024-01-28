# MinIO

Install minio server on a single node.

## Requirements

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

## Post-installation

### MinIO Console

* Set the region to `ap-south-1`
