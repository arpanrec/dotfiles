#!/usr/bin/env bash
set -e

__domain_off=

if [[ -z "${__domain_off}" ]]; then
    echo "variable __domain_off missign"
    exit 1
fi

__domain_on=433
__ica_default_ca_path="${HOME}/ICAClient/linuxx64/keystore/cacerts"
mkdir -p "${__ica_default_ca_path}"
cd "${__ica_default_ca_path}"

openssl s_client -showcerts -servername "${__domain_off}" -connect "${__domain_off}":443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >"${__domain_off}.pem"

awk 'BEGIN {c=0;} /BEGIN CERT/{c++} { print > "'"${__domain_off}"'." c ".pem"}' <"${__domain_off}.pem"

rm -rf ./"${__domain_off}.pem"

openssl rehash "${__ica_default_ca_path}"

chmod +x -R "${__ica_default_ca_path}/../../"
