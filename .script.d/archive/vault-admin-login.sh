#!/usr/bin/env bash
set -e

pre_pro=(bw jq)
for prog in "${pre_pro[@]}"; do
    if ! hash "${prog}" &>/dev/null; then
        echo "${prog}" not Installed
        exit 1
    fi
done

echo "Check if bitwarden is unlocked"
current_status="$(bw status --raw | jq .status -r)"
if [ "${current_status}" != "unlocked" ]; then
    echo "Bitwarden is not unlocked"
    echo dobwlogin
    exit 1
fi

echo "Downloading INIT_OPENSSL_ROOT_CA_KEY to ${HOME}/.secrets.d/INIT_OPENSSL_ROOT_CA_KEY.pem"
bw get attachment INIT_OPENSSL_ROOT_CA_KEY --itemid 'Hashicorp Vault Server' --output "${HOME}/.secrets.d/INIT_OPENSSL_ROOT_CA_KEY.pem"

echo "Downloading INIT_OPENSSL_ROOT_CA_CRT to ${HOME}/.secrets.d/INIT_OPENSSL_ROOT_CA_CRT.pem"
bw get attachment INIT_OPENSSL_ROOT_CA_CRT --itemid 'Hashicorp Vault Server' --output "${HOME}/.secrets.d/INIT_OPENSSL_ROOT_CA_CRT.pem"

echo "Downloading Hashicorp Vault Server item from Bitwarden"
bw_vault_item=$(bw get item 'Hashicorp Vault Server' --raw)

VAULT_ADDR=$(echo "${bw_vault_item}" | jq '.login.uris[0].uri' -r)
echo "VAULT_ADDR: ${VAULT_ADDR}"

hostname_port=$(echo "${VAULT_ADDR}" | cut -d'/' -f3)

INIT_VAULT_DOMAIN=$(echo "${hostname_port}" | cut -d':' -f1)
echo "INIT_VAULT_DOMAIN: ${INIT_VAULT_DOMAIN}"

echo "Find INIT_OPENSSL_ROOT_CA_PASSWORD in Bitwarden fiends"
INIT_OPENSSL_ROOT_CA_PASSWORD=$(echo "${bw_vault_item}" | jq '.fields[] | select(.name=="INIT_OPENSSL_ROOT_CA_PASSWORD") | .value' -r)

echo "Create vault_client.key"
openssl genrsa -out "${HOME}/.secrets.d/vault_client.key" 2048

echo "Create vault csr config file"
cat <<EOT >"${HOME}/.secrets.d/vault_client.csr.cnf"
[ req ]
distinguished_name	=	req_distinguished_name
default_md			=	sha256
prompt				=	no
req_extensions		=	v3_req

[ req_distinguished_name ]
CN	=	${INIT_VAULT_DOMAIN}

[ v3_req ]
basicConstraints		=	critical,CA:FALSE
keyUsage				=	critical,digitalSignature,nonRepudiation,keyEncipherment
extendedKeyUsage		=	critical,clientAuth
subjectAltName          =   @alt_names
[alt_names]
DNS.1 = ${INIT_VAULT_DOMAIN}
EOT

echo "Create vault_client.csr"
openssl req -new -key "${HOME}/.secrets.d/vault_client.key" \
    -out "${HOME}/.secrets.d/vault_client.csr" \
    -config "${HOME}/.secrets.d/vault_client.csr.cnf"

echo "Create vault_client.ext.cnf"
cat <<EOT >"${HOME}/.secrets.d/vault_client.ext.cnf"
[ v3_ca ]
subjectKeyIdentifier	=	hash
authorityKeyIdentifier	=	keyid,issuer
basicConstraints		=	critical,CA:FALSE
keyUsage				=	critical,digitalSignature,nonRepudiation,keyEncipherment
extendedKeyUsage		=	critical,clientAuth
subjectAltName          =   @alt_names
[alt_names]
DNS.1 = ${INIT_VAULT_DOMAIN}
EOT

echo "Create vault_client.crt"
openssl x509 -req -days 7 -sha256 \
    -in "${HOME}/.secrets.d/vault_client.csr" -CA "${HOME}/.secrets.d/INIT_OPENSSL_ROOT_CA_CRT.pem" \
    -CAkey "${HOME}/.secrets.d/INIT_OPENSSL_ROOT_CA_KEY.pem" \
    -CAcreateserial -passin "pass:${INIT_OPENSSL_ROOT_CA_PASSWORD}" \
    -out "${HOME}/.secrets.d/vault_client.crt" \
    -extensions v3_ca -extfile "${HOME}/.secrets.d/vault_client.ext.cnf"

echo "Create vault_client.crt chain"
cat "${HOME}/.secrets.d/INIT_OPENSSL_ROOT_CA_CRT.pem" | sudo tee -a "${HOME}/.secrets.d/vault_client.crt" >/dev/null

echo "Creating ${HOME}/.secrets.d/030-vault_client.sh with vault environment variables"
tee "${HOME}/.secrets.d/030-vault_client.sh" <<EOF >/dev/null
VAULT_ADDR='${VAULT_ADDR}'
export VAULT_ADDR
VAULT_CACERT="${HOME}/.secrets.d/INIT_OPENSSL_ROOT_CA_CRT.pem"
export VAULT_CACERT
VAULT_CLIENT_CERT="${HOME}/.secrets.d/vault_client.crt"
export VAULT_CLIENT_CERT
VAULT_CLIENT_KEY="${HOME}/.secrets.d/vault_client.key"
export VAULT_CLIENT_KEY
VAULT_FORMAT=json
export VAULT_FORMAT
EOF

chmod +x "${HOME}/.secrets.d/030-vault_client.sh"
source "${HOME}/.secrets.d/030-vault_client.sh"

vault_username=$(echo "${bw_vault_item}" | jq '.login.username' -r)
vault_password=$(echo "${bw_vault_item}" | jq '.login.password' -r)

echo "unset VAULT_TOKEN"
unset VAULT_TOKEN

echo "Remove ${HOME}/.vault-token"
rm -f "${HOME}/.vault-token"

echo "Logging in to vault, Please Wait!!!!!!!!!!!!"
new_vault_token=$(vault login -method=userpass username="${vault_username}" password="${vault_password}" --format=json | jq .auth.client_token -r)

echo "adding vault token to ${HOME}/.secrets.d/030-vault_client.sh"
tee -a "${HOME}/.secrets.d/030-vault_client.sh" <<EOF >/dev/null
VAULT_TOKEN='${new_vault_token}'
export VAULT_TOKEN
EOF
