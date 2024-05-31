#!/usr/bin/env bash
set -e

pre_pro=(bw jq gpg)
for prog in "${pre_pro[@]}"; do
  if ! hash "${prog}" &>/dev/null; then
    echo "${prog}" not Installed
    exit 1
  fi
done

import_gpg_key() {

  bw_item_id="${1}"

  bw_item_attachment_name="${2}"

  INIT_GPG_KEY_CONTENT=$(bw get attachment "${bw_item_attachment_name}" --itemid "${bw_item_id}" --raw)

  INIT_GPG_KEY_FINGERPRINT=$(echo "${INIT_GPG_KEY_CONTENT}" |
    gpg --show-keys --fingerprint --with-colons |
    awk -F: '$1 == "fpr" {print $10;}' |
    head -n1)

  INIT_VAULT_GPG_HOMEDIR="${HOME}/.gnupg"

  mkdir -p "${INIT_VAULT_GPG_HOMEDIR}"

  echo "GPG Encryption: Setting permissions for ${INIT_VAULT_GPG_HOMEDIR}"
  chmod 700 "${INIT_VAULT_GPG_HOMEDIR}"

  echo "GPG Encryption: Importing GPG key"
  echo "${INIT_GPG_KEY_CONTENT}" | gpg --import --batch --yes --pinentry-mode loopback --no-tty

  echo "GPG Encryption: Trusting GPG key"
  echo -e "5\ny\n" | gpg --pinentry-mode loopback --no-tty --command-fd 0 --edit-key "${INIT_GPG_KEY_FINGERPRINT}" trust
}

echo "Check if bitwarden is unlocked"
current_status="$(bw status --raw | jq .status -r)"
if [ "${current_status}" != "unlocked" ]; then
  echo "Bitwarden is not unlocked"
  echo bw-login
  exit 1
fi

declare -a bw_items=(
  # "PGP KEY - AB - 8B5DA775C63F6D456B3525A334D06AC4966B56C8" SECRET.asc
  "PGP KEY 1B0D9C73D1221DB0DB64592912086B524AF4FD70" private.asc
)

for ((i = 0; i < ${#bw_items[@]}; i += 2)); do
  echo bw item:: "${bw_items[i]}"
  echo bw attachment:: "${bw_items[i + 1]}"
  read -r -n1 -p "Press Y to continue :: " __import_gpg_key
  echo ""
  if [ "${__import_gpg_key}" == "Y" ] || [ "${__import_gpg_key}" == "y" ]; then
    import_gpg_key "${bw_items[i]}" "${bw_items[i + 1]}"
  fi
done
