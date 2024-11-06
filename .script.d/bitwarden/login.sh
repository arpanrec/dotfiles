#!/usr/bin/env bash
set -e

pre_pro=(jq)
for prog in "${pre_pro[@]}"; do
    if ! hash "${prog}" &>/dev/null; then
        echo "${prog}" not Installed
        exit 1
    fi
done

__get_current_status() {
    __ss="$(bw status --raw | jq .status -r)"
    echo "${__ss}"
}

BW_API_KEY_FILE="${BW_API_KEY_FILE:-"${HOME}/.env"}"
BW_API_SESSION_FILE="${BW_API_SESSION_FILE:-"${HOME}/.env"}"

current_status=$(__get_current_status)

if [ "${current_status}" == "unauthenticated" ]; then
    echo "Bitwarden is not logged in"
    echo "Press Y if you wish to use API key for login :: (Default email id based login)"
    read -r -n1 -p "Press any other key to skip : " __is_api_login
    echo ""
    if [ "${__is_api_login}" == "Y" ] || [ "${__is_api_login}" == "y" ]; then

        if [ -z "${BW_CLIENTID}" ] || [ -z "${BW_CLIENTSECRET}" ]; then
            read -r -p "Enter Client ID : " -s __bw_client_id
            echo ""
            read -r -p "Enter Client Secret : " -s __bw_client_secret
            echo ""
            if [ -z "${__bw_client_id}" ] || [ -z "${__bw_client_secret}" ]; then
                echo "Error!!!!!!!!!!!!!!!! Enter Valid Keys"
                exit 1
            fi
            echo "Logging in to bitwarden cli, Please Wait!!!!!!!!!!!!"
            BW_CLIENTID="${__bw_client_id}" BW_CLIENTSECRET="${__bw_client_secret}" bw login --apikey
            read -r -n1 -p "Press Y/y to save client id and client secret in ${BW_API_KEY_FILE}: " __save_apikeys_in_secrets
            echo ""
            if [ "${__save_apikeys_in_secrets}" == "Y" ] || [ "${__save_apikeys_in_secrets}" == "y" ]; then

                echo "Saving Client ID and Client Secret in ${BW_API_KEY_FILE}"
                sed -i '/^BW_CLIENTID/d' "${BW_API_KEY_FILE}"
                sed -i '/^BW_CLIENTSECRET/d' "${BW_API_KEY_FILE}"
                echo "BW_CLIENTID=${__bw_client_id}" >>"${BW_API_KEY_FILE}"
                echo "BW_CLIENTSECRET=${__bw_client_secret}" >>"${BW_API_KEY_FILE}"
            fi
        else
            echo "Client ID and Client Secret found in environment, Possibly from ${BW_API_KEY_FILE}"
            echo "Please Wait!!!!!!!!!!!!"
            bw login --apikey
        fi

    else
        bw login
    fi
    current_status=$(__get_current_status)
fi

if [ "${current_status}" == "locked" ]; then
    echo "Bitwarden is locked"
    echo "Current user "" $(bw status --raw | jq .userEmail)"
    read -r -p "Unlocking Bitwarden, Enter you credential : " -s __bw_master_password
    echo ""
    if [ -z "${__bw_master_password}" ]; then
        echo "Error!!!!!!!!!!!!!!!! Enter Valid Credential"
        exit 1
    fi
    echo "Please Wait!!!!!!!!!!!!"
    __bw_session_id=$(bw unlock "${__bw_master_password}" --raw)
    if [ -z "${__bw_session_id}" ]; then
        echo "Error!!!!!!!!!!!!!!!! Unable to unlock"
        exit 1
    fi
    export BW_SESSION="${__bw_session_id}"
    read -n1 -r -p "Set session id in ${BW_API_SESSION_FILE} : " __set_session_id_in_secrets
    echo ""
    if [ "${__set_session_id_in_secrets}" == "Y" ] || [ "${__set_session_id_in_secrets}" == "y" ]; then
        sed -i '/^BW_SESSION/d' "${BW_API_SESSION_FILE}"
        echo "BW_SESSION=${__bw_session_id}" >>"${BW_API_SESSION_FILE}"
    fi
fi

current_status=$(__get_current_status)

if [ "${current_status}" != "unlocked" ]; then
    echo "bitwarden cli is not unlocked"
    exit 0
fi
