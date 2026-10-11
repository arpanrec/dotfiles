#!/usr/bin/env bash
set -euo pipefail

BW_ITEMS_JSON=""

# Usage: _bw_select_one <description> <jq array path> <value> <json> [key]
# Prints the single object whose <key> (default: name) equals <value>, within the
# array selected by <jq array path> of <json>. Exits if there is not exactly one match.
_bw_select_one() {
    local description="${1}"
    local array_path="${2}"
    local value="${3}"
    local json="${4}"
    local key="${5:-name}"
    local matches
    matches=$(jq -c --arg value "${value}" --arg key "${key}" \
        "[${array_path} | if type == \"array\" then .[] else . end | select(.[\$key] == \$value)]" <<<"${json}")
    local count
    count=$(jq 'length' <<<"${matches}")
    if [ "${count}" -ne 1 ]; then
        echo "Expected exactly one match for ${description}, found ${count}" >&2
        exit 1
    fi
    jq -c '.[0]' <<<"${matches}"
}

ssh-install() {

    local bw_item_name="${1}"
    local ssh_key_file="${2}"
    local bw_field_name_ssh_passphrase="${3}"
    local passphrase_removed=false

    if [ -f "${HOME}/.ssh/${ssh_key_file}" ]; then
        echo "File ${HOME}/.ssh/${ssh_key_file} already exists"
        read -r -n1 -p "Press Y to force overwrite :: " __force_overwrite
        echo ""
        if [ "${__force_overwrite}" != "Y" ] && [ "${__force_overwrite}" != "y" ]; then
            echo "Skipping ${ssh_key_file}"
            return
        fi
        echo "Overwriting ${HOME}/.ssh/${ssh_key_file}"
    fi

    echo "Searching Bitwarden for item: ${bw_item_name}"
    local bw_item_json
    bw_item_json=$(_bw_select_one "item '${bw_item_name}'" '.' "${bw_item_name}" "${BW_ITEMS_JSON}")
    local bw_item_id
    bw_item_id=$(jq -r '.id' <<<"${bw_item_json}")
    echo "Found item ID: ${bw_item_id}"

    local bw_attachment_json
    bw_attachment_json=$(_bw_select_one "attachment '${ssh_key_file}' in item '${bw_item_name}'" \
        '.attachments // []' "${ssh_key_file}" "${bw_item_json}" 'fileName')
    local bw_attachment_id
    bw_attachment_id=$(jq -r '.id' <<<"${bw_attachment_json}")

    local bw_field_json
    bw_field_json=$(_bw_select_one "field '${bw_field_name_ssh_passphrase}' in item '${bw_item_name}'" \
        '.fields // []' "${bw_field_name_ssh_passphrase}" "${bw_item_json}" 'name')
    local bw_field_ssh_passphrase
    bw_field_ssh_passphrase=$(jq -r '.value' <<<"${bw_field_json}")

    echo "Downloading attachment '${ssh_key_file}' to ${HOME}/.ssh/${ssh_key_file}"
    bw get attachment "${bw_attachment_id}" --itemid "${bw_item_id}" --output "${HOME}/.ssh/${ssh_key_file}"
    echo "Attachment downloaded"

    chmod 600 "${HOME}/.ssh/${ssh_key_file}"
    echo "Permissions set to 600 for ${HOME}/.ssh/${ssh_key_file}"

    read -r -n1 -p "Press Y to remove passphrase :: " __remove_passphrase
    echo ""

    if [ "${__remove_passphrase}" == "Y" ] || [ "${__remove_passphrase}" == "y" ]; then
        echo "Removing passphrase from ${HOME}/.ssh/${ssh_key_file}"
        ssh-keygen -p -P "${bw_field_ssh_passphrase}" -N "" -f "${HOME}/.ssh/${ssh_key_file}"
        echo "Passphrase removed"
        passphrase_removed=true
    else
        echo "Passphrase not removed"
    fi

    read -r -n1 -p "Press Y to create public key :: " __create_public_key
    echo ""

    if [ "${__create_public_key}" == "Y" ] || [ "${__create_public_key}" == "y" ]; then
        echo "Creating public key at ${HOME}/.ssh/${ssh_key_file}.pub"
        if [ "${passphrase_removed}" == true ]; then
            ssh-keygen -y -f "${HOME}/.ssh/${ssh_key_file}" >"${HOME}/.ssh/${ssh_key_file}.pub"
        else
            ssh-keygen -y -P "${bw_field_ssh_passphrase}" -f "${HOME}/.ssh/${ssh_key_file}" >"${HOME}/.ssh/${ssh_key_file}.pub"
        fi
        echo "Public key created at ${HOME}/.ssh/${ssh_key_file}.pub"
    else
        echo "Skipping public key creation"
    fi

    read -r -n1 -p "Press Y to create PPK file :: " __create_ppk
    echo ""

    if [ "${__create_ppk}" == "Y" ] || [ "${__create_ppk}" == "y" ]; then
        if ! hash puttygen &>/dev/null; then
            echo "puttygen not installed, skipping PPK creation"
        else
            echo "Creating PPK file at ${HOME}/.ssh/${ssh_key_file}.ppk"
            if [ "${passphrase_removed}" == true ]; then
                puttygen "${HOME}/.ssh/${ssh_key_file}" -o "${HOME}/.ssh/${ssh_key_file}.ppk" --new-passphrase /dev/null
            else
                puttygen "${HOME}/.ssh/${ssh_key_file}" -o "${HOME}/.ssh/${ssh_key_file}.ppk" --old-passphrase <(echo "${bw_field_ssh_passphrase}") --new-passphrase /dev/null
            fi
            chmod 600 "${HOME}/.ssh/${ssh_key_file}.ppk"
            echo "PPK file created at ${HOME}/.ssh/${ssh_key_file}.ppk"
        fi
    else
        echo "Skipping PPK file creation"
    fi
}

pre_pro=(bw jq)
for prog in "${pre_pro[@]}"; do
    if ! hash "${prog}" &>/dev/null; then
        echo "${prog} not installed"
        exit 1
    fi
done

echo "Checking if Bitwarden is unlocked"
current_status="$(bw status --raw | jq -r .status)"
if [ "${current_status}" != "unlocked" ]; then
    echo "Bitwarden is not unlocked, run: bw-login"
    exit 1
fi

echo "Fetching Bitwarden items"
BW_ITEMS_JSON="$(bw list items --raw)"

echo "Creating ${HOME}/.ssh if it does not exist"
mkdir -p "${HOME}/.ssh"

echo "Setting permissions for ${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

declare -a bw_items=(
    "GitHub - arpanrec" github.com OPENSSH_KEY_PASSPHRASE
    "OPENSSH ID_ECDSA" id_ecdsa OPENSSH_KEY_PASSPHRASE
    "GitLab - arpanrec" gitlab.com OPENSSH_KEY_PASSPHRASE
    "Linode - arpanrecme" linode_ssh_key OPENSSH_KEY_PASSPHRASE
    "Router - BLR Flat - r1-tpla9v6" r1-tpla9v6.key OPENSSH_KEY_PASSPHRASE
    "DevOPS Server - blr-home - gitea" id_devops_server_scm_blr_home OPENSSH_KEY_PASSPHRASE
)

for ((i = 0; i < ${#bw_items[@]}; i += 3)); do
    echo "---"
    echo "Item: ${bw_items[i]} | File: ${bw_items[i + 1]} | Field: ${bw_items[i + 2]}"
    echo ""
    read -r -n1 -p "Press Y to continue :: " __ssh_install
    echo ""
    if [ "${__ssh_install}" == "Y" ] || [ "${__ssh_install}" == "y" ]; then
        ssh-install "${bw_items[i]}" "${bw_items[i + 1]}" "${bw_items[i + 2]}"
    else
        echo "Skipping ${bw_items[i]}"
    fi
    echo ""
done
