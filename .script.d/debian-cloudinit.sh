#!/usr/bin/env bash
set -euo pipefail

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Starting debian cloudinit"
echo "--------------------------------------------------------------------------------"

if [[ -z "${VIRTUAL_ENV+x}" ]]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Virtual environment is not activated"
    echo "--------------------------------------------------------------------------------"
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Already in python virtual environment ${VIRTUAL_ENV}, deactivate and run again, exiting"
    echo "--------------------------------------------------------------------------------"
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Please run as root, exiting"
    echo "--------------------------------------------------------------------------------"
    exit 1
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Running as root"
    echo "--------------------------------------------------------------------------------"
fi

if [ "${HOME}" != "/root" ]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: HOME is not set to /root, exiting"
    echo "--------------------------------------------------------------------------------"
    exit 1
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: debian-cloudinit: HOME is set to /root"
    echo "--------------------------------------------------------------------------------"
fi

export CLOUD_INIT_USER="${CLOUD_INIT_USER:-cloudinit}"
export CLOUD_INIT_USE_SSH_PUB="${CLOUD_INIT_USE_SSH_PUB:-"ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJXzoi1QAbLmxnyudx+7Dm+FGTYU+TP02MTtxqq9w82Rm2kIDtGf4xVGxaidYEP/WcgpOHacjKDa7p2skBYljmk= arpan.rec@gmail.com"}"

printf "\n\n================================================================================\n"
echo "debian-cloudinit: CLOUD_INIT_USER: ${CLOUD_INIT_USER}"
echo "debian-cloudinit: CLOUD_INIT_USE_SSH_PUB: ${CLOUD_INIT_USE_SSH_PUB}"
echo "--------------------------------------------------------------------------------"

if [ -f /etc/environment ]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Sourcing /etc/environment"
    # shellcheck source=/dev/null
    source /etc/environment
    echo "--------------------------------------------------------------------------------"
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: File /etc/environment does not exist"
    echo "--------------------------------------------------------------------------------"
fi

export DEBIAN_FRONTEND=noninteractive
export CLOUD_INIT_COPY_ROOT_SSH_KEYS="${CLOUD_INIT_COPY_ROOT_SSH_KEYS:-false}"
export CLOUD_INIT_GROUP="${CLOUD_INIT_GROUP:-cloudinit}"
export CLOUD_INIT_IS_DEV_MACHINE="${CLOUD_INIT_IS_DEV_MACHINE:-false}"
export CLOUD_INIT_HOSTNAME="${CLOUD_INIT_HOSTNAME:-cloudinit}"
export CLOUD_INIT_DOMAIN="${CLOUD_INIT_DOMAIN:-cloudinit}"
export CLOUD_INIT_INSTALL_DOTFILES="${CLOUD_INIT_INSTALL_DOTFILES:-true}"

printf "\n\n================================================================================\n"
echo "debian-cloudinit: CLOUD_INIT_COPY_ROOT_SSH_KEYS: ${CLOUD_INIT_COPY_ROOT_SSH_KEYS}"
echo "debian-cloudinit: CLOUD_INIT_GROUP: ${CLOUD_INIT_GROUP}"
echo "debian-cloudinit: CLOUD_INIT_IS_DEV_MACHINE: ${CLOUD_INIT_IS_DEV_MACHINE}"
echo "debian-cloudinit: CLOUD_INIT_HOSTNAME: ${CLOUD_INIT_HOSTNAME}"
echo "debian-cloudinit: CLOUD_INIT_DOMAIN: ${CLOUD_INIT_DOMAIN}"
echo "debian-cloudinit: CLOUD_INIT_INSTALL_DOTFILES: ${CLOUD_INIT_INSTALL_DOTFILES}"
echo "--------------------------------------------------------------------------------"

if [ -z "${CLOUD_INIT_USE_SSH_PUB}" ]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: CLOUD_INIT_USE_SSH_PUB is not set, exiting"
    echo "--------------------------------------------------------------------------------"
    exit 1
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: CLOUD_INIT_USE_SSH_PUB is set as ${CLOUD_INIT_USE_SSH_PUB}"
    echo "--------------------------------------------------------------------------------"
fi

if [[ ! "${CLOUD_INIT_COPY_ROOT_SSH_KEYS}" =~ ^true|false$ ]]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: CLOUD_INIT_COPY_ROOT_SSH_KEYS must be a boolean (true|false), exiting"
    echo "--------------------------------------------------------------------------------"
    exit 1
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: CLOUD_INIT_COPY_ROOT_SSH_KEYS is set as ${CLOUD_INIT_COPY_ROOT_SSH_KEYS}"
    echo "--------------------------------------------------------------------------------"
fi

if [[ ! "${CLOUD_INIT_IS_DEV_MACHINE}" =~ ^true|false$ ]]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: CLOUD_INIT_IS_DEV_MACHINE must be a boolean (true|false), exiting"
    echo "--------------------------------------------------------------------------------"
    exit 1
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: CLOUD_INIT_IS_DEV_MACHINE is set as ${CLOUD_INIT_IS_DEV_MACHINE}"
    echo "--------------------------------------------------------------------------------"
fi

if [[ ! "${CLOUD_INIT_INSTALL_DOTFILES}" =~ ^true|false$ ]]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: CLOUD_INIT_INSTALL_DOTFILES must be a boolean (true|false), exiting"
    echo "--------------------------------------------------------------------------------"
    exit 1
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: CLOUD_INIT_INSTALL_DOTFILES is set as ${CLOUD_INIT_INSTALL_DOTFILES}"
    echo "--------------------------------------------------------------------------------"
fi

export NEBULA_TMP_DIR="${NEBULA_TMP_DIR:-"/tmp/cloudinit"}"
export NEBULA_VERSION="${NEBULA_VERSION:-"1.9.3"}"
export NEBULA_VENV_DIR="${NEBULA_TMP_DIR}/venv"

printf "\n\n================================================================================\n"
echo "debian-cloudinit: NEBULA_TMP_DIR: ${NEBULA_TMP_DIR}"
echo "debian-cloudinit: NEBULA_VERSION: ${NEBULA_VERSION}"
echo "debian-cloudinit: NEBULA_VENV_DIR: ${NEBULA_VENV_DIR}"
echo "--------------------------------------------------------------------------------"

export DEFAULT_ROLES_PATH="${DEFAULT_ROLES_PATH:-${NEBULA_TMP_DIR}/roles}"
export ANSIBLE_ROLES_PATH="${ANSIBLE_ROLES_PATH:-${DEFAULT_ROLES_PATH}}"
export ANSIBLE_COLLECTIONS_PATH="${ANSIBLE_COLLECTIONS_PATH:-${NEBULA_TMP_DIR}/collections}"
export ANSIBLE_INVENTORY="${ANSIBLE_INVENTORY:-${NEBULA_TMP_DIR}/inventory.yml}"

printf "\n\n================================================================================\n"
echo "debian-cloudinit: DEFAULT_ROLES_PATH: ${DEFAULT_ROLES_PATH}"
echo "debian-cloudinit: ANSIBLE_ROLES_PATH: ${ANSIBLE_ROLES_PATH}"
echo "debian-cloudinit: ANSIBLE_COLLECTIONS_PATH: ${ANSIBLE_COLLECTIONS_PATH}"
echo "debian-cloudinit: ANSIBLE_INVENTORY: ${ANSIBLE_INVENTORY}"
echo "--------------------------------------------------------------------------------"

# rm -rf "${NEBULA_TMP_DIR}"
if [ -d "${NEBULA_TMP_DIR}" ]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Directory ${NEBULA_TMP_DIR} already exists, Changing ownership to root"
    echo "--------------------------------------------------------------------------------"
    chown -R root:root "${NEBULA_TMP_DIR}"
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Directory ${NEBULA_TMP_DIR} does not exist"
    echo "--------------------------------------------------------------------------------"
fi

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Creating directories"
echo "--------------------------------------------------------------------------------"
mkdir -p "${NEBULA_TMP_DIR}" "${DEFAULT_ROLES_PATH}" "${ANSIBLE_ROLES_PATH}" \
    "${ANSIBLE_COLLECTIONS_PATH}" "$(dirname "${ANSIBLE_INVENTORY}")"

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Creating authorized_keys file at ${NEBULA_TMP_DIR}/authorized_keys"
echo "--------------------------------------------------------------------------------"
tee "${NEBULA_TMP_DIR}/authorized_keys" <<EOF >/dev/null
${CLOUD_INIT_USE_SSH_PUB}
EOF

if [ "${CLOUD_INIT_COPY_ROOT_SSH_KEYS}" = true ] && [ -f "/root/.ssh/authorized_keys" ]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Copying root's authorized_keys to ${NEBULA_TMP_DIR}/authorized_keys"
    echo "--------------------------------------------------------------------------------"
    cat "/root/.ssh/authorized_keys" >>"${NEBULA_TMP_DIR}/authorized_keys"
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: CLOUD_INIT_COPY_ROOT_SSH_KEYS is set to false or /root/.ssh/authorized_keys does not exist, not adding any extra keys to ${CLOUD_INIT_USER}"
    echo "--------------------------------------------------------------------------------"
fi

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Installing dependencies, python3-venv python3-pip git curl ca-certificates gnupg tar unzip wget"
echo "--------------------------------------------------------------------------------"
apt update
apt install -y python3-venv python3-pip git curl ca-certificates gnupg tar unzip wget jq

if [ ! -d "${NEBULA_VENV_DIR}" ]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Creating virtual environment at ${NEBULA_VENV_DIR}"
    echo "--------------------------------------------------------------------------------"
    python3 -m venv "${NEBULA_VENV_DIR}"
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Virtual environment already exists at ${NEBULA_VENV_DIR}"
    echo "--------------------------------------------------------------------------------"
fi

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Activating virtual environment at ${NEBULA_VENV_DIR}"
echo "--------------------------------------------------------------------------------"
# shellcheck source=/dev/null
source "${NEBULA_VENV_DIR}/bin/activate"

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Installing ansible and hvac using pip3"
echo "--------------------------------------------------------------------------------"
pip3 install --upgrade pip
pip3 install setuptools-rust wheel setuptools --upgrade
pip3 install ansible hvac --upgrade

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Installing nebula version ${NEBULA_VERSION}"
echo "--------------------------------------------------------------------------------"

curl "https://raw.githubusercontent.com/arpanrec/arpanrec.nebula/refs/tags/${NEBULA_VERSION}/requirements.yml" \
    -o "/tmp/requirements-${NEBULA_VERSION}.yml"
ansible-galaxy install -r "/tmp/requirements-${NEBULA_VERSION}.yml"
ansible-galaxy collection install "git+https://github.com/arpanrec/arpanrec.nebula.git,${NEBULA_VERSION}"

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Creating inventory file at ${ANSIBLE_INVENTORY}"
echo "--------------------------------------------------------------------------------"
tee "${ANSIBLE_INVENTORY}" <<EOF >/dev/null
---
all:
    children:
        server_workspace:
            hosts:
                localhost:
            vars:
                ansible_user: ${CLOUD_INIT_USER}
                ansible_become: false
        cloudinit:
            hosts:
                localhost:
            vars:
                ansible_user: root
                ansible_become: false
                pv_cloud_init_user: ${CLOUD_INIT_USER}
                pv_cloud_init_group: ${CLOUD_INIT_GROUP}
                pv_cloud_init_authorized_keys: ${NEBULA_TMP_DIR}/authorized_keys
                pv_cloud_init_is_dev_machine: ${CLOUD_INIT_IS_DEV_MACHINE}
                pv_cloud_init_hostname: ${CLOUD_INIT_HOSTNAME}
                pv_cloud_init_domain: ${CLOUD_INIT_DOMAIN}
    hosts:
        localhost:
            ansible_connection: local
            ansible_python_interpreter: "/usr/bin/python3"
EOF

#             ansible_python_interpreter: "$(which python3)"

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Running ansible-playbook arpanrec.nebula.cloudinit"
echo "--------------------------------------------------------------------------------"

ansible-playbook arpanrec.nebula.cloudinit

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Deactivating virtual environment at ${NEBULA_VENV_DIR}"
echo "--------------------------------------------------------------------------------"

deactivate

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Changing ownership of ${NEBULA_TMP_DIR} to ${CLOUD_INIT_USER}:${CLOUD_INIT_GROUP}"
echo "debian-cloudinit: Running ansible-playbook arpanrec.nebula.server_workspace"
echo "--------------------------------------------------------------------------------"

chown -R "${CLOUD_INIT_USER}:${CLOUD_INIT_GROUP}" "${NEBULA_TMP_DIR}"

# We can test this script by creating a dummy shell(.sh) file and check with [shell check](https://www.shellcheck.net/).
# > man sudo
#      -E, --preserve-env
#              Indicates to the security policy that the user wishes to preserve their existing environment variables.  The security policy may return an error if the user does not have permission to preserve the environment.
#      -H, --set-home
#              Request that the security policy set the HOME environment variable to the home directory specified by the target user's password database entry.  Depending on the policy, this may be the default behavior.
#      -u user, --user=user
#              Run the command as a user other than the default target user (usually root).  The user may be either a user name or a numeric user-ID (UID) prefixed with the ‘#’ character (e.g., ‘#0’ for UID 0).  When running commands as a UID, many shells require
#              that the ‘#’ be escaped with a backslash (‘\’).  Some security policies may restrict UIDs to those listed in the password database.  The sudoers policy allows UIDs that are not in the password database as long as the targetpw option is not set.  Other
#              security policies may not support this.

sudo -E -H -u "${CLOUD_INIT_USER}" bash -c '
#!/usr/bin/env bash
set -euo pipefail

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Activating virtual environment at ${NEBULA_VENV_DIR}"
echo "--------------------------------------------------------------------------------"
# shellcheck source=/dev/null
source "${NEBULA_VENV_DIR}/bin/activate"

if [ "${CLOUD_INIT_IS_DEV_MACHINE}" = true ]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Running ansible-playbook arpanrec.nebula.server_workspace with all tags in dev mode"
    echo "--------------------------------------------------------------------------------"
    ansible-playbook arpanrec.nebula.server_workspace --tags all
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Running ansible-playbook arpanrec.nebula.server_workspace without java, go, terraform, vault, nodejs, bws, pulumi tags"
    echo "--------------------------------------------------------------------------------"
    ansible-playbook arpanrec.nebula.server_workspace --tags all \
        --skip-tags java,go,terraform,vault,nodejs,bws,pulumi
fi

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Deactivating virtual environment at ${NEBULA_VENV_DIR}"
echo "--------------------------------------------------------------------------------"
deactivate

if [ "${CLOUD_INIT_INSTALL_DOTFILES}" = true ]; then
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Installing/Reseting dotfiles"
    echo "--------------------------------------------------------------------------------"
    bash <(curl https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/dot-install.sh)
else
    printf "\n\n================================================================================\n"
    echo "debian-cloudinit: Skipping dotfiles installation as `CLOUD_INIT_INSTALL_DOTFILES` is set to not true"
    echo "--------------------------------------------------------------------------------"
fi

'

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Changing ownership of ${NEBULA_TMP_DIR} to root:root"
echo "--------------------------------------------------------------------------------"
chown -R root:root "${NEBULA_TMP_DIR}"

printf "\n\n================================================================================\n"
echo "debian-cloudinit: Completed"
echo "--------------------------------------------------------------------------------"
