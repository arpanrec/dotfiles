#!/usr/bin/env bash
set -e

enable_ufw() {
    if ! command -v ufw &>/dev/null; then
        echo "ufw could not be found"
        return
    fi

    sudo ufw allow "${INIT_STORAGE_MINIO_PORT}"/tcp
    sudo ufw allow "${INIT_STORAGE_MINIO_CONSOLE_PORT}"/tcp

    echo "Enable ufw in systemd"
    sudo systemctl enable --now ufw

    echo "Restart ufw in systemd"
    sudo sudo systemctl restart ufw

    echo "Enabling UFW"
    sudo ufw --force enable

    echo "Reload UFW"
    sudo ufw reload

}

download_kes() {

    echo "Check if KES binary exists in ${INIT_STORAGE_KES_BIN_TMP_FILE}"
    if [[ ! -f "${INIT_STORAGE_KES_BIN_TMP_FILE}" ]]; then

        echo "Creating directory for ${INIT_STORAGE_KES_BIN_TMP_FILE}"
        mkdir -p "$(dirname "${INIT_STORAGE_KES_BIN_TMP_FILE}")"

        wget -O "${INIT_STORAGE_KES_BIN_TMP_FILE}" \
            "https://github.com/minio/kes/releases/download/${INIT_STORAGE_KES_VERSION}/kes-linux-${INIT_STORAGE_KES_ARCH}"
    fi

    INIT_STORAGE_KES_BIN_CHECKSUM_FILE="$(
        curl -sL "https://github.com/minio/kes/releases/download/${INIT_STORAGE_KES_VERSION}/kes_${INIT_STORAGE_KES_VERSION}_checksums.txt" |
            grep "kes-linux-${INIT_STORAGE_KES_ARCH}" |
            awk '{print $1}'
    )"

    echo "Verifying KES binary for ${INIT_STORAGE_KES_BIN_CHECKSUM_FILE} against file ${INIT_STORAGE_KES_BIN_TMP_FILE}"

    if [[ "$(sha256sum "${INIT_STORAGE_KES_BIN_TMP_FILE}" | awk '{print $1}')" != "${INIT_STORAGE_KES_BIN_CHECKSUM_FILE}" ]]; then
        echo "ERROR:: KES binary for ${INIT_STORAGE_KES_VERSION} failed checksum"
        echo "Deleting ${INIT_STORAGE_KES_BIN_TMP_FILE}"
        rm -rf "${INIT_STORAGE_KES_BIN_TMP_FILE}"
        exit 1
    else
        echo "Kes binary for ${INIT_STORAGE_KES_VERSION} passed checksum"
    fi

    echo "Creating directory for ${INIT_STORAGE_KES_BIN_FILE}"
    mkdir -p "$(dirname "${INIT_STORAGE_KES_BIN_FILE}")"

    echo "Copy ${INIT_STORAGE_KES_BIN_TMP_FILE} to ${INIT_STORAGE_KES_BIN_FILE}"
    cp "${INIT_STORAGE_KES_BIN_TMP_FILE}" "${INIT_STORAGE_KES_BIN_FILE}"

    chmod +x "${INIT_STORAGE_KES_BIN_FILE}"

    echo "Setting capabilities on ${INIT_STORAGE_KES_BIN_FILE}"
    setcap cap_ipc_lock=+ep "${INIT_STORAGE_KES_BIN_FILE}"
}

remove_kes() {
    echo "Stop, disable and remove ${INIT_STORAGE_KES_SYSTEMD_SERVICE}"
    systemctl disable --now "${INIT_STORAGE_KES_SYSTEMD_SERVICE}" || true
    rm -f "/etc/systemd/system/${INIT_STORAGE_KES_SYSTEMD_SERVICE}"

    echo "Deleting existing Group: ${INIT_STORAGE_KES_GROUP} and USER: ${INIT_STORAGE_KES_USER}"
    userdel "${INIT_STORAGE_KES_USER}" || true
    groupdel "${INIT_STORAGE_KES_GROUP}" || true

    echo "Removing ${INIT_STORAGE_KES_BIN_FILE}"
    rm -rf "${INIT_STORAGE_KES_BIN_FILE}"
}

install_kes() {
    remove_kes
    echo "Creating ${INIT_STORAGE_KES_GROUP} and ${INIT_STORAGE_KES_USER}"
    groupadd --system "${INIT_STORAGE_KES_GROUP}"
    useradd --system --no-create-home --shell /bin/false --gid "${INIT_STORAGE_KES_GROUP}" "${INIT_STORAGE_KES_USER}"

    echo "Creating ${INIT_STORAGE_KES_WORKDIR} and ${INIT_STORAGE_KES_KEYSTORE_DIR}"
    mkdir -p "${INIT_STORAGE_KES_WORKDIR}" "${INIT_STORAGE_KES_KEYSTORE_DIR}"

    download_kes
    echo "Downloading kes binary"

    chmod +x "${INIT_STORAGE_KES_BIN_FILE}"

    echo "Setting capabilities on ${INIT_STORAGE_KES_BIN_FILE}"
    setcap cap_ipc_lock=+ep "${INIT_STORAGE_KES_BIN_FILE}"

    echo "Creating ${INIT_STORAGE_KES_CERT_KEY_FILE} and ${INIT_STORAGE_KES_CERT_CERT_FILE}"
    "${INIT_STORAGE_KES_BIN_FILE}" identity new --key "${INIT_STORAGE_KES_CERT_KEY_FILE}" --cert "${INIT_STORAGE_KES_CERT_CERT_FILE}" \
        "kesadmin" --force --dns "${INIT_STORAGE_KES_DOMAIN}" --ip "${INIT_STORAGE_KES_IP}" >/dev/null

    INIT_STORAGE_KES_ADMIN_IDENTITY="$("${INIT_STORAGE_KES_BIN_FILE}" identity of "${INIT_STORAGE_KES_CERT_CERT_FILE}" | cat)"

    echo "Creating ${INIT_STORAGE_KES_CONFIG_FILE}"
    tee "${INIT_STORAGE_KES_CONFIG_FILE}" <<EOF >/dev/null
---
address: 0.0.0.0:${INIT_STORAGE_KES_PORT}

admin:
  identity: ${INIT_STORAGE_KES_ADMIN_IDENTITY}

tls:
  key: ${INIT_STORAGE_KES_CERT_KEY_FILE}
  cert: ${INIT_STORAGE_KES_CERT_CERT_FILE}
  ca: ${INIT_STORAGE_KES_CERT_CERT_FILE}

policy:
  minio:
    allow:
      - /v1/key/create/*
      - /v1/key/generate/*
      - /v1/key/decrypt/*
      - /v1/key/bulk/decrypt
      - /v1/key/list/*
      - /v1/status
      - /v1/metrics
      - /v1/log/audit
      - /v1/log/error

keystore:
  fs:
    path: ${INIT_STORAGE_KES_KEYSTORE_DIR}

log:
  error: on
  audit: on
EOF

    echo "Changing ownership of ${INIT_STORAGE_KES_WORKDIR} to ${INIT_STORAGE_KES_USER}:${INIT_STORAGE_KES_GROUP}"

    chown -R "${INIT_STORAGE_KES_USER}:${INIT_STORAGE_KES_GROUP}" "${INIT_STORAGE_KES_WORKDIR}"
    chmod -R 755 "${INIT_STORAGE_KES_WORKDIR}"

    echo "Creating Kes systemd service unit file ${INIT_STORAGE_KES_SYSTEMD_SERVICE}"
    tee "/etc/systemd/system/${INIT_STORAGE_KES_SYSTEMD_SERVICE}" <<EOF >/dev/null
[Unit]
Description=KES
Documentation=https://github.com/minio/kes/wiki
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=${INIT_STORAGE_KES_BIN_FILE}

[Service]
WorkingDirectory=${INIT_STORAGE_KES_WORKDIR}

AmbientCapabilities=CAP_IPC_LOCK

User=${INIT_STORAGE_KES_USER}
Group=${INIT_STORAGE_KES_GROUP}
ProtectProc=invisible

ExecStart=${INIT_STORAGE_KES_BIN_FILE} server --config="${INIT_STORAGE_KES_CONFIG_FILE}" --auth=on

# Let systemd restart this service always
Restart=always

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536

# Specifies the maximum number of threads this process can create
TasksMax=infinity

# Disable timeout logic and wait until process is stopped
TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF

    echo "Changing ownership of /etc/systemd/system/${INIT_STORAGE_KES_SYSTEMD_SERVICE} to root:root"
    chown root:root "/etc/systemd/system/${INIT_STORAGE_KES_SYSTEMD_SERVICE}"
    chmod 644 "/etc/systemd/system/${INIT_STORAGE_KES_SYSTEMD_SERVICE}"

    echo "Reloading systemd daemon and enabling ${INIT_STORAGE_KES_SYSTEMD_SERVICE}"
    systemctl daemon-reload
    systemctl enable --now "${INIT_STORAGE_KES_SYSTEMD_SERVICE}"
    systemctl restart "${INIT_STORAGE_KES_SYSTEMD_SERVICE}"
    systemctl is-active "${INIT_STORAGE_KES_SYSTEMD_SERVICE}"

}

download_minio() {

    echo "Check if minio binary exists in ${INIT_STORAGE_MINIO_BIN_TMP_FILE}"
    if [[ ! -f "${INIT_STORAGE_MINIO_BIN_TMP_FILE}" ]]; then

        echo "Creating directory for ${INIT_STORAGE_MINIO_BIN_TMP_FILE}"
        mkdir -p "$(dirname "${INIT_STORAGE_MINIO_BIN_TMP_FILE}")"

        echo "Downloading minio binary"
        wget -O "${INIT_STORAGE_MINIO_BIN_TMP_FILE}" \
            "https://dl.min.io/server/minio/release/linux-${INIT_STORAGE_MINIO_ARCH}/archive/minio.${INIT_STORAGE_MINIO_VERSION}"
    fi

    INIT_STORAGE_MINIO_BIN_CHECKSUM_FILE="$(
        curl -s "https://dl.min.io/server/minio/release/linux-${INIT_STORAGE_MINIO_ARCH}/archive/minio.${INIT_STORAGE_MINIO_VERSION}.sha256sum" |
            grep "minio.${MINIO_VERSION}" |
            awk '{print $1}'
    )"

    echo "Verifying MinIO binary for ${INIT_STORAGE_MINIO_BIN_CHECKSUM_FILE} against file ${INIT_STORAGE_MINIO_BIN_TMP_FILE}"

    if [[ "$(sha256sum "${INIT_STORAGE_MINIO_BIN_TMP_FILE}" | awk '{print $1}')" != "${INIT_STORAGE_MINIO_BIN_CHECKSUM_FILE}" ]]; then
        echo "ERROR:: MinIO binary for ${INIT_STORAGE_MINIO_VERSION} failed checksum"
        echo "Deleting ${INIT_STORAGE_MINIO_BIN_TMP_FILE}"
        rm -rf "${INIT_STORAGE_MINIO_BIN_TMP_FILE}"
        exit 1
    else
        echo "MinIO binary for ${INIT_STORAGE_MINIO_VERSION} passed checksum"
    fi

    echo "Creating directory for ${INIT_STORAGE_MINIO_BIN_FILE}"
    mkdir -p "$(dirname "${INIT_STORAGE_MINIO_BIN_FILE}")"

    echo "Copy ${INIT_STORAGE_MINIO_BIN_TMP_FILE} to ${INIT_STORAGE_MINIO_BIN_FILE}"
    cp "${INIT_STORAGE_MINIO_BIN_TMP_FILE}" "${INIT_STORAGE_MINIO_BIN_FILE}"

    chmod +x "${INIT_STORAGE_MINIO_BIN_FILE}"

    echo "Setting capabilities on ${INIT_STORAGE_MINIO_BIN_FILE}"
    setcap cap_ipc_lock=+ep "${INIT_STORAGE_MINIO_BIN_FILE}"
}

remove_minio() {

    echo "Stop, disable and remove ${INIT_STORAGE_MINIO_SYSTEMD_SERVICE}"
    systemctl disable --now "${INIT_STORAGE_MINIO_SYSTEMD_SERVICE}" || true
    rm -f "/etc/systemd/system/${INIT_STORAGE_MINIO_SYSTEMD_SERVICE}"

    echo "Deleting existing Group: ${INIT_STORAGE_MINIO_GROUP} and USER: ${INIT_STORAGE_MINIO_USER}"
    userdel -r "${INIT_STORAGE_MINIO_USER}" || true
    groupdel "${INIT_STORAGE_MINIO_GROUP}" || true

    echo "Removing ${INIT_STORAGE_MINIO_BIN_FILE}"
    rm -rf "${INIT_STORAGE_MINIO_BIN_FILE}"
}

install_minio() {

    remove_minio

    echo "Creating Group: ${INIT_STORAGE_MINIO_GROUP} and USER: ${INIT_STORAGE_MINIO_USER}"
    groupadd --system "${INIT_STORAGE_MINIO_GROUP}"
    useradd --system --no-create-home --shell /bin/false --gid "${INIT_STORAGE_MINIO_GROUP}" "${INIT_STORAGE_MINIO_USER}"

    echo "Creating ${INIT_STORAGE_MINIO_WORKDIR} and ${INIT_STORAGE_MINIO_VOLUMES} and ${INIT_STORAGE_MINIO_CERTS_DIR}"
    mkdir -p "${INIT_STORAGE_MINIO_WORKDIR}" "${INIT_STORAGE_MINIO_VOLUMES}" "${INIT_STORAGE_MINIO_CERTS_DIR}"

    download_minio

    echo "Copying ${INIT_STORAGE_MINIO_KMS_KES_CERT_FILE} and ${INIT_STORAGE_MINIO_KMS_KES_KEY_FILE} and ${INIT_STORAGE_MINIO_KMS_KES_CAPATH}"
    cp "${INIT_STORAGE_KES_CERT_CERT_FILE}" "${INIT_STORAGE_MINIO_KMS_KES_CERT_FILE}"
    cp "${INIT_STORAGE_KES_CERT_KEY_FILE}" "${INIT_STORAGE_MINIO_KMS_KES_KEY_FILE}"
    cp "${INIT_STORAGE_KES_CERT_CERT_FILE}" "${INIT_STORAGE_MINIO_KMS_KES_CAPATH}"

    echo "Create letsencrypt certificate if the domain is not localhost and INIT_STORAGE_MINIO_PROTOCOL is https"

    if [[ "${INIT_STORAGE_MINIO_DOMAIN}" != "localhost" ]] && [[ "${INIT_STORAGE_MINIO_PROTOCOL}" == "https" ]]; then
        echo "Copy letsencrypt certificates to ${INIT_STORAGE_MINIO_CERTS_DIR}"

        echo "Check if INIT_STORAGE_MINIO_CERT_FULL_CHAIN_BASE64 and INIT_STORAGE_MINIO_CERT_PRIV_KEY_BASE64 exists"
        if [[ -z "${INIT_STORAGE_MINIO_CERT_FULL_CHAIN_BASE64}" ]] || [[ -z "${INIT_STORAGE_MINIO_CERT_PRIV_KEY_BASE64}" ]]; then
            echo "ERROR:: INIT_STORAGE_MINIO_CERT_FULL_CHAIN_BASE64 or INIT_STORAGE_MINIO_CERT_PRIV_KEY_BASE64 is not set"
            exit 1
        fi

        echo "${INIT_STORAGE_MINIO_CERT_FULL_CHAIN_BASE64}" | base64 --decode | tee "${INIT_STORAGE_MINIO_CERTS_DIR}/public.crt"
        echo "${INIT_STORAGE_MINIO_CERT_PRIV_KEY_BASE64}" | base64 --decode | tee "${INIT_STORAGE_MINIO_CERTS_DIR}/private.key" >/dev/null
    fi
    echo "Creating ${INIT_STORAGE_MINIO_ENV_FILE}"
    tee "${INIT_STORAGE_MINIO_ENV_FILE}" <<EOF >/dev/null
MINIO_KMS_KES_ENDPOINT="${INIT_STORAGE_MINIO_KMS_KES_ENDPOINT}"
MINIO_KMS_KES_KEY_FILE="${INIT_STORAGE_MINIO_KMS_KES_KEY_FILE}"
MINIO_KMS_KES_CERT_FILE="${INIT_STORAGE_MINIO_KMS_KES_CERT_FILE}"
MINIO_KMS_KES_CAPATH="${INIT_STORAGE_MINIO_KMS_KES_CAPATH}"
MINIO_KMS_KES_KEY_NAME="${INIT_STORAGE_MINIO_KMS_KES_KEY_NAME}"
MINIO_ROOT_USER="${INIT_STORAGE_MINIO_ROOT_USER}"
MINIO_ROOT_PASSWORD="${INIT_STORAGE_MINIO_ROOT_PASSWORD}"
MINIO_VOLUMES="${INIT_STORAGE_MINIO_VOLUMES}"
MINIO_REGION="${INIT_STORAGE_MINIO_REGION}"
MINIO_OPTS="--address ':${INIT_STORAGE_MINIO_PORT}' --console-address ':${INIT_STORAGE_MINIO_CONSOLE_PORT}' --certs-dir ${INIT_STORAGE_MINIO_CERTS_DIR}"
EOF

    # MINIO_OPTS="--address ':${INIT_STORAGE_MINIO_PORT}' --console-address ':${INIT_STORAGE_MINIO_CONSOLE_PORT}' --certs-dir ${INIT_STORAGE_MINIO_CERTS_DIR}"

    echo "Changing ownership of ${INIT_STORAGE_MINIO_WORKDIR} to ${INIT_STORAGE_MINIO_USER}:${INIT_STORAGE_MINIO_GROUP}"
    chown -R "${INIT_STORAGE_MINIO_USER}:${INIT_STORAGE_MINIO_GROUP}" "${INIT_STORAGE_MINIO_WORKDIR}"
    chmod -R 755 "${INIT_STORAGE_MINIO_WORKDIR}"

    echo "Creating Kes systemd service unit file ${INIT_STORAGE_MINIO_SYSTEMD_SERVICE}"
    tee "/etc/systemd/system/${INIT_STORAGE_MINIO_SYSTEMD_SERVICE}" <<EOF >/dev/null
[Unit]
Description=MinIO
Documentation=https://min.io/docs/minio/linux/index.html
Wants=network-online.target ${INIT_STORAGE_KES_SYSTEMD_SERVICE}
After=network-online.target ${INIT_STORAGE_KES_SYSTEMD_SERVICE}
Requires=network-online.target ${INIT_STORAGE_KES_SYSTEMD_SERVICE}
AssertFileIsExecutable=${INIT_STORAGE_MINIO_BIN_FILE}

[Service]
WorkingDirectory=${INIT_STORAGE_MINIO_WORKDIR}

User=${INIT_STORAGE_MINIO_USER}
Group=${INIT_STORAGE_MINIO_GROUP}
ProtectProc=invisible

EnvironmentFile=-${INIT_STORAGE_MINIO_ENV_FILE}
ExecStartPre=/bin/bash -c "if [ -z \"\${MINIO_VOLUMES}\" ]; then echo Variable MINIO_VOLUMES not set in ${INIT_STORAGE_MINIO_ENV_FILE}; exit 1; fi"
ExecStart=${INIT_STORAGE_MINIO_BIN_FILE} server \$MINIO_OPTS \$MINIO_VOLUMES

Restart=always
LimitNOFILE=65536
TasksMax=infinity
TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF

    echo "Changing ownership of /etc/systemd/system/${INIT_STORAGE_MINIO_SYSTEMD_SERVICE} to root:root"
    chown root:root "/etc/systemd/system/${INIT_STORAGE_MINIO_SYSTEMD_SERVICE}"
    chmod 644 "/etc/systemd/system/${INIT_STORAGE_MINIO_SYSTEMD_SERVICE}"

    echo "Reloading systemd daemon and enabling ${INIT_STORAGE_MINIO_SYSTEMD_SERVICE}"
    systemctl daemon-reload
    systemctl enable --now "${INIT_STORAGE_MINIO_SYSTEMD_SERVICE}"
    systemctl restart "${INIT_STORAGE_MINIO_SYSTEMD_SERVICE}"
    systemctl is-active "${INIT_STORAGE_MINIO_SYSTEMD_SERVICE}"

}
echo "First cli argument should be the path to the .env file"

env_file="${1}"

if [[ -z "${env_file}" ]]; then
    echo "ERROR:: First cli argument should be the path to the .env file"
    exit 1
fi

if [[ ! -f "${env_file}" ]]; then
    echo "ERROR:: ${env_file} file does not exist"
    exit 1
fi

echo "Sourcing ${env_file}"
# shellcheck disable=SC1090
source "${env_file}"

INIT_STORAGE_DIR="${INIT_STORAGE_DIR:-"/opt/init-storage"}"
export INIT_STORAGE_DIR

INIT_STORAGE_APP_DIR="${INIT_STORAGE_APP_DIR:-"${INIT_STORAGE_DIR}/app"}"
export INIT_STORAGE_APP_DIR

INIT_STORAGE_KES_WORKDIR="${INIT_STORAGE_KES_WORKDIR:-"${INIT_STORAGE_APP_DIR}/kes"}"
export INIT_STORAGE_KES_WORKDIR

INIT_STORAGE_KES_VERSION="${INIT_STORAGE_KES_VERSION:-"2023-11-10T10-44-28Z"}"
export INIT_STORAGE_KES_VERSION

INIT_STORAGE_KES_ARCH="${INIT_STORAGE_KES_ARCH:-"$(dpkg --print-architecture)"}"
export INIT_STORAGE_KES_ARCH

INIT_STORAGE_KES_CERT_KEY_FILE="${INIT_STORAGE_KES_CERT_KEY_FILE:-"${INIT_STORAGE_KES_WORKDIR}/key.pem"}"
export INIT_STORAGE_KES_CERT_KEY_FILE

INIT_STORAGE_KES_CERT_CERT_FILE="${INIT_STORAGE_KES_CERT_CERT_FILE:-"${INIT_STORAGE_KES_WORKDIR}/cert.pem"}"
export INIT_STORAGE_KES_CERT_CERT_FILE

INIT_STORAGE_KES_KEYSTORE_DIR="${INIT_STORAGE_KES_KEYSTORE_DIR:-"${INIT_STORAGE_KES_WORKDIR}/keystore"}"
export INIT_STORAGE_KES_KEYSTORE_DIR

INIT_STORAGE_KES_BIN_TMP_FILE="${INIT_STORAGE_KES_BIN_TMP_FILE:-"/tmp/kes/kes-linux-${INIT_STORAGE_KES_ARCH}-${INIT_STORAGE_KES_VERSION}"}"
export INIT_STORAGE_KES_BIN_TMP_FILE

INIT_STORAGE_KES_BIN_FILE="${INIT_STORAGE_KES_BIN_FILE:-"/usr/local/bin/kes"}"
export INIT_STORAGE_KES_BIN_FILE

INIT_STORAGE_KES_CONFIG_FILE="${INIT_STORAGE_KES_CONFIG_FILE:-"${INIT_STORAGE_KES_WORKDIR}/config.yml"}"
export INIT_STORAGE_KES_CONFIG_FILE

INIT_STORAGE_KES_GROUP="${INIT_STORAGE_KES_GROUP:-"kes"}"
export INIT_STORAGE_KES_GROUP

INIT_STORAGE_KES_USER="${INIT_STORAGE_KES_USER:-"kes"}"
export INIT_STORAGE_KES_USER

INIT_STORAGE_KES_SYSTEMD_SERVICE="${INIT_STORAGE_KES_SYSTEMD_SERVICE:-"kes.service"}"
export INIT_STORAGE_KES_SYSTEMD_SERVICE

INIT_STORAGE_KES_DOMAIN="${INIT_STORAGE_KES_DOMAIN:-"localhost"}"
export INIT_STORAGE_KES_DOMAIN

INIT_STORAGE_KES_IP="${INIT_STORAGE_KES_IP:-"127.0.0.1"}"
export INIT_STORAGE_KES_IP

INIT_STORAGE_KES_PORT="${INIT_STORAGE_KES_PORT:-"7373"}"
export INIT_STORAGE_KES_PORT

INIT_STORAGE_MINIO_DOMAIN="${INIT_STORAGE_MINIO_DOMAIN:-"localhost"}"
export INIT_STORAGE_MINIO_DOMAIN

INIT_STORAGE_MINIO_EMAIL="${INIT_STORAGE_MINIO_EMAIL:-"minio@localhost"}"
export INIT_STORAGE_MINIO_EMAIL

INIT_STORAGE_MINIO_WORKDIR="${INIT_STORAGE_MINIO_WORKDIR:-"${INIT_STORAGE_APP_DIR}/minio"}"
export INIT_STORAGE_MINIO_WORKDIR

INIT_STORAGE_MINIO_VERSION="${INIT_STORAGE_MINIO_VERSION:-"RELEASE.2023-12-23T07-19-11Z"}"
export INIT_STORAGE_MINIO_VERSION

INIT_STORAGE_MINIO_ARCH="${INIT_STORAGE_MINIO_ARCH:-"$(dpkg --print-architecture)"}"
export INIT_STORAGE_MINIO_ARCH

INIT_STORAGE_MINIO_BIN_TMP_FILE="${INIT_STORAGE_MINIO_BIN_TMP_FILE:-"/tmp/minio/minio-linux-${INIT_STORAGE_MINIO_ARCH}-${INIT_STORAGE_MINIO_VERSION}"}"
export INIT_STORAGE_MINIO_BIN_TMP_FILE

INIT_STORAGE_MINIO_BIN_FILE="${INIT_STORAGE_MINIO_BIN_FILE:-"/usr/local/bin/minio"}"
export INIT_STORAGE_MINIO_BIN_FILE

INIT_STORAGE_MINIO_SYSTEMD_SERVICE="${INIT_STORAGE_MINIO_SYSTEMD_SERVICE:-"minio.service"}"
export INIT_STORAGE_MINIO_SYSTEMD_SERVICE

INIT_STORAGE_MINIO_GROUP="${INIT_STORAGE_MINIO_GROUP:-"minio"}"
export INIT_STORAGE_MINIO_GROUP

INIT_STORAGE_MINIO_USER="${INIT_STORAGE_MINIO_USER:-"minio"}"
export INIT_STORAGE_MINIO_USER

INIT_STORAGE_MINIO_KMS_KES_CERT_FILE="${INIT_STORAGE_MINIO_KMS_KES_CERT_FILE:-"${INIT_STORAGE_MINIO_WORKDIR}/kesadmin.cert"}"
export INIT_STORAGE_MINIO_KMS_KES_CERT_FILE

INIT_STORAGE_MINIO_KMS_KES_KEY_FILE="${INIT_STORAGE_MINIO_KMS_KES_KEY_FILE:-"${INIT_STORAGE_MINIO_WORKDIR}/kesadmin.key"}"
export INIT_STORAGE_MINIO_KMS_KES_KEY_FILE

INIT_STORAGE_MINIO_KMS_KES_CAPATH="${INIT_STORAGE_MINIO_KMS_KES_CAPATH:-"${INIT_STORAGE_MINIO_WORKDIR}/kesadmin.ca"}"
export INIT_STORAGE_MINIO_KMS_KES_CAPATH

INIT_STORAGE_MINIO_KMS_KES_ENDPOINT="${INIT_STORAGE_MINIO_KMS_KES_ENDPOINT:-"https://${INIT_STORAGE_KES_DOMAIN}:${INIT_STORAGE_KES_PORT}"}"
export INIT_STORAGE_MINIO_KMS_KES_ENDPOINT

INIT_STORAGE_MINIO_VOLUMES="${INIT_STORAGE_MINIO_VOLUMES:-"${INIT_STORAGE_MINIO_WORKDIR}/data"}"
export INIT_STORAGE_MINIO_VOLUMES

INIT_STORAGE_MINIO_CERTS_DIR="${INIT_STORAGE_MINIO_CERTS_DIR:-"${INIT_STORAGE_MINIO_WORKDIR}/certs"}"
export INIT_STORAGE_MINIO_CERTS_DIR

INIT_STORAGE_MINIO_ENV_FILE="${INIT_STORAGE_MINIO_ENV_FILE:-"${INIT_STORAGE_MINIO_WORKDIR}/env"}"
export INIT_STORAGE_MINIO_ENV_FILE

INIT_STORAGE_MINIO_ROOT_USER="${INIT_STORAGE_MINIO_ROOT_USER:-"${INIT_STORAGE_MINIO_USER}"}"
export INIT_STORAGE_MINIO_ROOT_USER

INIT_STORAGE_MINIO_ROOT_PASSWORD="${INIT_STORAGE_MINIO_ROOT_PASSWORD:-"password"}"
export INIT_STORAGE_MINIO_ROOT_PASSWORD

INIT_STORAGE_MINIO_PORT="${INIT_STORAGE_MINIO_PORT:-"9000"}"
export INIT_STORAGE_MINIO_PORT

INIT_STORAGE_MINIO_CONSOLE_PORT="${INIT_STORAGE_MINIO_CONSOLE_PORT:-"9001"}"
export INIT_STORAGE_MINIO_CONSOLE_PORT

INIT_STORAGE_MINIO_KMS_KES_KEY_NAME="${INIT_STORAGE_MINIO_KMS_KES_KEY_NAME:-"default"}"
export INIT_STORAGE_MINIO_KMS_KES_KEY_NAME

INIT_STORAGE_MINIO_REGION="${INIT_STORAGE_MINIO_REGION:-"ap-south-1"}"
export INIT_STORAGE_MINIO_REGION

INIT_STORAGE_MINIO_PROTOCOL="${INIT_STORAGE_MINIO_PROTOCOL:-"http"}"
export INIT_STORAGE_MINIO_PROTOCOL

install_kes

install_minio

enable_ufw
