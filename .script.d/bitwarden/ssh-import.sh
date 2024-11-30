#!/usr/bin/env bash
set -e

ssh-install() {

    bw_item_name="${1}"

    ssh_key_file="${2}"

    bw_field_name_ssh_passphrase="${3}"

    if [ -f "${HOME}/.ssh/${ssh_key_file}" ]; then
        echo "File ${HOME}/.ssh/${ssh_key_file} already exists"
        read -r -n1 -p "Press Y to force overwrite :: " __force_overwrite
        echo ""
        if [ "${__force_overwrite}" != "Y" ] && [ "${__force_overwrite}" != "y" ]; then
            return
        fi
    fi

    bw_item_id=$(bw list items --search "${bw_item_name}" --pretty | jq .[0].id -r)

    bw get attachment "${ssh_key_file}" --itemid "${bw_item_id}" --output "${HOME}/.ssh/${ssh_key_file}"

    chmod 600 "${HOME}/.ssh/${ssh_key_file}"

    read -r -n1 -p "Press Y to remove passphrase :: " __remove_passphrase

    if [ "${__remove_passphrase}" == "Y" ] || [ "${__remove_passphrase}" == "y" ]; then
        echo ""
        echo "Removing passphrase"
        bw_field_ssh_passphrase=$(bw get item "${bw_item_id}" --pretty | jq ".fields[] | select(.name == \"${bw_field_name_ssh_passphrase}\") | .value" -r)
        ssh-keygen -p -P "${bw_field_ssh_passphrase}" -N "" -f "${HOME}/.ssh/${ssh_key_file}"
    else
        echo ""
        echo "Passphrase not removed"
    fi

    read -r -n1 -p "Press Y to create public key :: " __create_public_key

    if [ "${__create_public_key}" == "Y" ] || [ "${__create_public_key}" == "y" ]; then
        # echo ""
        # echo "Creating public key"
        # ssh-keygen -y -f "${HOME}/.ssh/${ssh_key_file}" >"${HOME}/.ssh/${ssh_key_file}.pub"

        if [ "${__remove_passphrase}" == "Y" ] || [ "${__remove_passphrase}" == "y" ]; then
            echo ""
            echo "Creating public key"
            ssh-keygen -y -f "${HOME}/.ssh/${ssh_key_file}" >"${HOME}/.ssh/${ssh_key_file}.pub"
        else
            echo ""
            echo "Creating public key"
            bw_field_ssh_passphrase=$(bw get item "${bw_item_id}" --pretty | jq ".fields[] | select(.name == \"${bw_field_name_ssh_passphrase}\") | .value" -r)
            ssh-keygen -y -P "${bw_field_ssh_passphrase}" -f "${HOME}/.ssh/${ssh_key_file}" >"${HOME}/.ssh/${ssh_key_file}.pub"
        fi
    fi
}

pre_pro=(bw)
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
    echo bw-login
    exit 1
fi

echo "Creating ${HOME}/.ssh if it does not exist"
mkdir -p "${HOME}/.ssh"

echo "Setting permissions for ${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

declare -a bw_items=(
    "GitHub - arpanrec" github.com OPENSSH_KEY_PASSPHRASE
    "OPENSSH ID_ECDSA" id_ecdsa OPENSSH_KEY_PASSPHRASE
    "GitLab - arpanrec" gitlab.com OPENSSH_KEY_PASSPHRASE
    "Linode - arpanrecme" linode_ssh_key OPENSSH_KEY_PASSPHRASE
)

for ((i = 0; i < ${#bw_items[@]}; i += 3)); do
    echo bw item:: "${bw_items[i]}", bw attachment:: "${bw_items[i + 1]}", bw field:: "${bw_items[i + 2]}"
    echo ""
    read -r -n1 -p "Press Y to continue :: " __ssh_install
    echo ""
    if [ "${__ssh_install}" == "Y" ] || [ "${__ssh_install}" == "y" ]; then
        ssh-install "${bw_items[i]}" "${bw_items[i + 1]}" "${bw_items[i + 2]}"
    fi
done
