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

install_kes() {
    docker network create "${INIT_STORAGE_DOCKER_NETWORK}" || true
    echo "Stop, disable and remove ${INIT_STORAGE_KES_CONTAINER_NAME}"
    docker rm -f "${INIT_STORAGE_KES_CONTAINER_NAME}"
    echo "Deleting existing Group: ${INIT_STORAGE_KES_GROUP} and USER: ${INIT_STORAGE_KES_USER}"
    userdel "${INIT_STORAGE_KES_USER}" || true
    groupdel "${INIT_STORAGE_KES_GROUP}" || true
    echo "Creating ${INIT_STORAGE_KES_GROUP} and ${INIT_STORAGE_KES_USER}"
    groupadd --system "${INIT_STORAGE_KES_GROUP}"
    useradd --system --no-create-home --shell /bin/false --gid "${INIT_STORAGE_KES_GROUP}" "${INIT_STORAGE_KES_USER}"

    echo "Creating ${INIT_STORAGE_KES_WORKDIR} and ${INIT_STORAGE_KES_KEYSTORE_DIR}"
    mkdir -p "${INIT_STORAGE_KES_WORKDIR}" "${INIT_STORAGE_KES_KEYSTORE_DIR}"
    chown -R "${INIT_STORAGE_KES_USER}:${INIT_STORAGE_KES_GROUP}" \
        "${INIT_STORAGE_KES_WORKDIR}" "${INIT_STORAGE_KES_KEYSTORE_DIR}"

    echo "Creating ${INIT_STORAGE_KES_CERT_KEY_FILE} and ${INIT_STORAGE_KES_CERT_FILE}"
    touch "${INIT_STORAGE_KES_CERT_KEY_FILE}" "${INIT_STORAGE_KES_CERT_FILE}"
    chown "${INIT_STORAGE_KES_USER}:${INIT_STORAGE_KES_GROUP}" \
        "${INIT_STORAGE_KES_CERT_KEY_FILE}" "${INIT_STORAGE_KES_CERT_FILE}"

    docker run --rm --user "$(id "${INIT_STORAGE_KES_USER}" -u):$(id "${INIT_STORAGE_KES_GROUP}" -g)" \
        -v "${INIT_STORAGE_KES_CERT_KEY_FILE}":"${INIT_STORAGE_KES_CERT_KEY_FILE}" \
        -v "${INIT_STORAGE_KES_CERT_FILE}":"${INIT_STORAGE_KES_CERT_FILE}" \
        --name "${INIT_STORAGE_KES_CONTAINER_NAME}" \
        minio/kes:"${INIT_STORAGE_KES_VERSION}" identity new --key "${INIT_STORAGE_KES_CERT_KEY_FILE}" \
        --cert "${INIT_STORAGE_KES_CERT_FILE}" \
        "kesadmin" --force --dns "${INIT_STORAGE_KES_CONTAINER_NAME}"

    docker run --rm --user "$(id "${INIT_STORAGE_KES_USER}" -u):$(id "${INIT_STORAGE_KES_GROUP}" -g)" \
        -v "${INIT_STORAGE_KES_WORKDIR}":"${INIT_STORAGE_KES_WORKDIR}" \
        --name "${INIT_STORAGE_KES_CONTAINER_NAME}" \
        minio/kes:"${INIT_STORAGE_KES_VERSION}" identity of "${INIT_STORAGE_KES_CERT_FILE}" |
        tee "${INIT_STORAGE_KES_CERT_ID_FILE}"

    INIT_STORAGE_KES_ADMIN_IDENTITY="$(cat "${INIT_STORAGE_KES_CERT_ID_FILE}")"

    echo "Creating ${INIT_STORAGE_KES_CONFIG_FILE}"
    tee "${INIT_STORAGE_KES_CONFIG_FILE}" <<EOF >/dev/null
---
version: v1
address: 0.0.0.0:${INIT_STORAGE_KES_PORT}

admin:
    identity: ${INIT_STORAGE_KES_ADMIN_IDENTITY}

tls:
    key: ${INIT_STORAGE_KES_CERT_KEY_FILE}
    cert: ${INIT_STORAGE_KES_CERT_FILE}
    auth: on
    ca: ${INIT_STORAGE_KES_CERT_FILE}

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

    docker run -d --user "$(id "${INIT_STORAGE_KES_USER}" -u):$(id "${INIT_STORAGE_KES_GROUP}" -g)" \
        --hostname "${INIT_STORAGE_KES_CONTAINER_NAME}" \
        -v "${INIT_STORAGE_KES_WORKDIR}:${INIT_STORAGE_KES_WORKDIR}" \
        -v "${INIT_STORAGE_KES_KEYSTORE_DIR}:${INIT_STORAGE_KES_KEYSTORE_DIR}" \
        -v "${INIT_STORAGE_KES_CONFIG_FILE}":"${INIT_STORAGE_KES_CONFIG_FILE}" \
        -p "${INIT_STORAGE_KES_PORT}":"${INIT_STORAGE_KES_PORT}" \
        --restart unless-stopped \
        --network "${INIT_STORAGE_DOCKER_NETWORK}" \
        --name "${INIT_STORAGE_KES_CONTAINER_NAME}" \
        minio/kes:"${INIT_STORAGE_KES_VERSION}" server --config="${INIT_STORAGE_KES_CONFIG_FILE}"
}

install_minio() {

    echo "Stop, disable and remove ${INIT_STORAGE_MINIO_CONTAINER_NAME}"
    docker rm -f "${INIT_STORAGE_MINIO_CONTAINER_NAME}"

    echo "Deleting existing Group: ${INIT_STORAGE_MINIO_GROUP} and USER: ${INIT_STORAGE_MINIO_USER}"
    userdel -r "${INIT_STORAGE_MINIO_USER}" || true
    groupdel "${INIT_STORAGE_MINIO_GROUP}" || true

    echo "Creating Group: ${INIT_STORAGE_MINIO_GROUP} and USER: ${INIT_STORAGE_MINIO_USER}"
    groupadd --system "${INIT_STORAGE_MINIO_GROUP}"
    useradd --system --no-create-home --shell /bin/false \
        --gid "${INIT_STORAGE_MINIO_GROUP}" "${INIT_STORAGE_MINIO_USER}"

    echo "Creating ${INIT_STORAGE_MINIO_WORKDIR} and ${INIT_STORAGE_MINIO_VOLUMES} and ${INIT_STORAGE_MINIO_CERTS_DIR}"
    mkdir -p "${INIT_STORAGE_MINIO_WORKDIR}" "${INIT_STORAGE_MINIO_VOLUMES}" "${INIT_STORAGE_MINIO_CERTS_DIR}"

    echo "Copying ${INIT_STORAGE_MINIO_KMS_KES_CERT_FILE} \
        and ${INIT_STORAGE_MINIO_KMS_KES_KEY_FILE} and ${INIT_STORAGE_MINIO_KMS_KES_CAPATH}"
    cp "${INIT_STORAGE_KES_CERT_FILE}" "${INIT_STORAGE_MINIO_KMS_KES_CERT_FILE}"
    cp "${INIT_STORAGE_KES_CERT_KEY_FILE}" "${INIT_STORAGE_MINIO_KMS_KES_KEY_FILE}"
    cp "${INIT_STORAGE_KES_CERT_FILE}" "${INIT_STORAGE_MINIO_KMS_KES_CAPATH}"

    echo "Create letsencrypt certificate if the domain is not localhost and INIT_STORAGE_MINIO_PROTOCOL is https"

    if [[ "${INIT_STORAGE_MINIO_DOMAIN}" != "localhost" ]] && [[ "${INIT_STORAGE_MINIO_PROTOCOL}" == "https" ]]; then
        echo "Copy letsencrypt certificates to ${INIT_STORAGE_MINIO_CERTS_DIR}"

        echo "Check if INIT_STORAGE_MINIO_CERT_FULL_CHAIN_BASE64 and INIT_STORAGE_MINIO_CERT_PRIV_KEY_BASE64 exists"
        if [[ -z "${INIT_STORAGE_MINIO_CERT_FULL_CHAIN_BASE64}" ]] ||
            [[ -z "${INIT_STORAGE_MINIO_CERT_PRIV_KEY_BASE64}" ]]; then
            echo "ERROR:: INIT_STORAGE_MINIO_CERT_FULL_CHAIN_BASE64 \
                or INIT_STORAGE_MINIO_CERT_PRIV_KEY_BASE64 is not set"
            exit 1
        fi

        echo "${INIT_STORAGE_MINIO_CERT_FULL_CHAIN_BASE64}" |
            base64 --decode | tee "${INIT_STORAGE_MINIO_CERTS_DIR}/public.crt"
        echo "${INIT_STORAGE_MINIO_CERT_PRIV_KEY_BASE64}" |
            base64 --decode | tee "${INIT_STORAGE_MINIO_CERTS_DIR}/private.key" >/dev/null
    fi

    echo "Changing ownership of ${INIT_STORAGE_MINIO_WORKDIR} to ${INIT_STORAGE_MINIO_USER}:${INIT_STORAGE_MINIO_GROUP}"
    chown -R "${INIT_STORAGE_MINIO_USER}:${INIT_STORAGE_MINIO_GROUP}" "${INIT_STORAGE_MINIO_WORKDIR}"
    chmod -R 755 "${INIT_STORAGE_MINIO_WORKDIR}"

    docker run -d --user "$(id "${INIT_STORAGE_MINIO_USER}" -u):$(id "${INIT_STORAGE_MINIO_GROUP}" -g)" \
        --hostname "${INIT_STORAGE_MINIO_DOMAIN}" \
        -v "${INIT_STORAGE_MINIO_WORKDIR}:${INIT_STORAGE_MINIO_WORKDIR}" \
        -p "${INIT_STORAGE_MINIO_PORT}":"${INIT_STORAGE_MINIO_PORT}" \
        -p "${INIT_STORAGE_MINIO_CONSOLE_PORT}":"${INIT_STORAGE_MINIO_CONSOLE_PORT}" \
        --restart unless-stopped --network "${INIT_STORAGE_DOCKER_NETWORK}" \
        --env "MINIO_KMS_KES_ENDPOINT=${INIT_STORAGE_MINIO_KMS_KES_ENDPOINT}" \
        --env "MINIO_KMS_KES_KEY_FILE=${INIT_STORAGE_MINIO_KMS_KES_KEY_FILE}" \
        --env "MINIO_KMS_KES_CERT_FILE=${INIT_STORAGE_MINIO_KMS_KES_CERT_FILE}" \
        --env "MINIO_KMS_KES_CAPATH=${INIT_STORAGE_MINIO_KMS_KES_CAPATH}" \
        --env "MINIO_KMS_KES_KEY_NAME=${INIT_STORAGE_MINIO_KMS_KES_KEY_NAME}" \
        --env "MINIO_ROOT_USER=${INIT_STORAGE_MINIO_ROOT_USER}" \
        --env "MINIO_ROOT_PASSWORD=${INIT_STORAGE_MINIO_ROOT_PASSWORD}" \
        --env "MINIO_REGION=${INIT_STORAGE_MINIO_REGION}" \
        --name "${INIT_STORAGE_MINIO_CONTAINER_NAME}" \
        minio/minio:"${INIT_STORAGE_MINIO_VERSION}" server "${INIT_STORAGE_MINIO_VOLUMES}" \
        --address :"${INIT_STORAGE_MINIO_PORT}" --console-address :"${INIT_STORAGE_MINIO_CONSOLE_PORT}" \
        --certs-dir "${INIT_STORAGE_MINIO_CERTS_DIR}"
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

export INIT_STORAGE_DIR="${INIT_STORAGE_DIR:-"/opt"}"

export INIT_STORAGE_DOCKER_NETWORK="${INIT_STORAGE_DOCKER_NETWORK:-"init-storage"}"

export INIT_STORAGE_KES_WORKDIR="${INIT_STORAGE_KES_WORKDIR:-"${INIT_STORAGE_DIR}/kes"}"

export INIT_STORAGE_KES_VERSION="${INIT_STORAGE_KES_VERSION:-"2024-04-12T13-50-00Z"}"

export INIT_STORAGE_KES_CERT_KEY_FILE="${INIT_STORAGE_KES_CERT_KEY_FILE:-"${INIT_STORAGE_KES_WORKDIR}/key.pem"}"

export INIT_STORAGE_KES_CERT_FILE="${INIT_STORAGE_KES_CERT_FILE:-"${INIT_STORAGE_KES_WORKDIR}/cert.pem"}"

export INIT_STORAGE_KES_CERT_ID_FILE="${INIT_STORAGE_KES_CERT_ID_FILE:-"${INIT_STORAGE_KES_WORKDIR}/cert.pem.id.txt"}"

export INIT_STORAGE_KES_KEYSTORE_DIR="${INIT_STORAGE_KES_KEYSTORE_DIR:-"${INIT_STORAGE_KES_WORKDIR}/keystore"}"

export INIT_STORAGE_KES_CONFIG_FILE="${INIT_STORAGE_KES_CONFIG_FILE:-"${INIT_STORAGE_KES_WORKDIR}/config.yml"}"

export INIT_STORAGE_KES_GROUP="${INIT_STORAGE_KES_GROUP:-"kes"}"

export INIT_STORAGE_KES_USER="${INIT_STORAGE_KES_USER:-"kes"}"

export INIT_STORAGE_KES_CONTAINER_NAME="${INIT_STORAGE_KES_CONTAINER_NAME:-"kes"}"

export INIT_STORAGE_KES_PORT="${INIT_STORAGE_KES_PORT:-"7373"}"

export INIT_STORAGE_MINIO_DOMAIN="${INIT_STORAGE_MINIO_DOMAIN:-"localhost"}"

export INIT_STORAGE_MINIO_EMAIL="${INIT_STORAGE_MINIO_EMAIL:-"minio@localhost"}"

export INIT_STORAGE_MINIO_WORKDIR="${INIT_STORAGE_MINIO_WORKDIR:-"${INIT_STORAGE_DIR}/minio"}"

export INIT_STORAGE_MINIO_VERSION="${INIT_STORAGE_MINIO_VERSION:-"RELEASE.2024-05-01T01-11-10Z"}"

export INIT_STORAGE_MINIO_CONTAINER_NAME="${INIT_STORAGE_MINIO_CONTAINER_NAME:-"minio"}"

export INIT_STORAGE_MINIO_GROUP="${INIT_STORAGE_MINIO_GROUP:-"minio"}"

export INIT_STORAGE_MINIO_USER="${INIT_STORAGE_MINIO_USER:-"minio"}"

export INIT_STORAGE_MINIO_KMS_KES_CERT_FILE="${INIT_STORAGE_MINIO_KMS_KES_CERT_FILE:-"${INIT_STORAGE_MINIO_WORKDIR}/kesadmin.cert"}"

export INIT_STORAGE_MINIO_KMS_KES_KEY_FILE="${INIT_STORAGE_MINIO_KMS_KES_KEY_FILE:-"${INIT_STORAGE_MINIO_WORKDIR}/kesadmin.key"}"

export INIT_STORAGE_MINIO_KMS_KES_CAPATH="${INIT_STORAGE_MINIO_KMS_KES_CAPATH:-"${INIT_STORAGE_MINIO_WORKDIR}/kesadmin.ca"}"

export INIT_STORAGE_MINIO_KMS_KES_ENDPOINT="${INIT_STORAGE_MINIO_KMS_KES_ENDPOINT:-"https://${INIT_STORAGE_KES_CONTAINER_NAME}:${INIT_STORAGE_KES_PORT}"}"

export INIT_STORAGE_MINIO_VOLUMES="${INIT_STORAGE_MINIO_VOLUMES:-"${INIT_STORAGE_MINIO_WORKDIR}/data"}"

export INIT_STORAGE_MINIO_CERTS_DIR="${INIT_STORAGE_MINIO_CERTS_DIR:-"${INIT_STORAGE_MINIO_WORKDIR}/certs"}"

export INIT_STORAGE_MINIO_ROOT_USER="${INIT_STORAGE_MINIO_ROOT_USER:-"${INIT_STORAGE_MINIO_USER}"}"

export INIT_STORAGE_MINIO_ROOT_PASSWORD="${INIT_STORAGE_MINIO_ROOT_PASSWORD:-"password"}"

export INIT_STORAGE_MINIO_PORT="${INIT_STORAGE_MINIO_PORT:-"9000"}"

export INIT_STORAGE_MINIO_CONSOLE_PORT="${INIT_STORAGE_MINIO_CONSOLE_PORT:-"9001"}"

export INIT_STORAGE_MINIO_KMS_KES_KEY_NAME="${INIT_STORAGE_MINIO_KMS_KES_KEY_NAME:-"default"}"

export INIT_STORAGE_MINIO_REGION="${INIT_STORAGE_MINIO_REGION:-"ap-south-1"}"

export INIT_STORAGE_MINIO_PROTOCOL="${INIT_STORAGE_MINIO_PROTOCOL:-"http"}"

install_kes

install_minio

enable_ufw
