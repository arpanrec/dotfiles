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
    echo bw-login
    exit 1
fi

declare -a bw_items=(
    "Github - arpanrec" GH_PROD_API_TOKEN
    "GitLab - arpanrec" GL_PROD_API_KEY
    "Docker Hub - arpanrecme" DOCKER_PROD_API_KEY
    "HashiCorp Terraform cloud - arpanrec" TF_PROD_TOKEN
    "Linode - arpanrecme" LINODE_CLI_PROD_TOKEN
)

echo "#!/usr/bin/env bash" | tee "${HOME}/.secrets.d/040-api-keys.sh"

for ((i = 0; i < ${#bw_items[@]}; i += 2)); do
    echo bw item:: "${bw_items[i]}"
    echo bw field:: "${bw_items[i + 1]}"

    bw_item=$(bw get item "${bw_items[i]}" --raw)
    api_key=$(echo "${bw_item}" | jq '.fields[] | select(.name=="'"${bw_items[i + 1]}"'") | .value' -r)

    echo "${bw_items[i + 1]}='${api_key}'" | tee -a "${HOME}/.secrets.d/040-api-keys.sh" >/dev/null
    echo "export ${bw_items[i + 1]}" | tee -a "${HOME}/.secrets.d/040-api-keys.sh"

done
