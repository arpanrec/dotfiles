#!/usr/bin/env bash
set -e

if ! command -v sudo &>/dev/null; then
    DEBIAN_FRONTEND=noninteractive apt update
    DEBIAN_FRONTEND=noninteractive apt install sudo -y
fi

sudo apt update

export CLOUD_INIT_GROUPNAME=${CLOUD_INIT_GROUPNAME:-cloudinit}
export CLOUD_INIT_USERNAME=${CLOUD_INIT_USERNAME:-clouduser}
export CLOUD_INIT_USE_SSHPUBKEY=${CLOUD_INIT_USE_SSHPUBKEY:-'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJXzoi1QAbLmxnyudx+7Dm+FGTYU+TP02MTtxqq9w82Rm2kIDtGf4xVGxaidYEP/WcgpOHacjKDa7p2skBYljmk= arpan.rec@gmail.com'}

if [ "$(hostname)" = 'localhost' ]; then
    CLOUD_INIT_HOSTNAME=${CLOUD_INIT_HOSTNAME:-cloudvm}
else
    CLOUD_INIT_HOSTNAME=$(hostname)
fi

if [ "$(domainname)" = '(none)' ]; then
    CLOUD_INIT_DOMAINNAME=${CLOUD_INIT_DOMAINNAME:-clouddomain}
else
    CLOUD_INIT_DOMAINNAME=$(domainname)
fi

sudo sed -i '/^127.0.1.1/d' /etc/hosts
echo "127.0.1.1 ${CLOUD_INIT_HOSTNAME} ${CLOUD_INIT_HOSTNAME}.${CLOUD_INIT_DOMAINNAME}" | sudo tee -a /etc/hosts
echo "${CLOUD_INIT_HOSTNAME}" | sudo tee /etc/hostname
sudo hostnamectl set-hostname "${CLOUD_INIT_HOSTNAME}"

export CLOUD_INIT_IS_DEV_MACHINE=${CLOUD_INIT_IS_DEV_MACHINE:-false}
echo "CLOUD_INIT_IS_DEV_MACHINE=${CLOUD_INIT_IS_DEV_MACHINE}"

ALL_PAKGS=('zip' 'unzip' 'tar' 'wget' 'curl' 'ca-certificates' 'sudo' 'systemd' 'gnupg2' 'apt-transport-https' 'locales' 'systemd-timesyncd' 'network-manager' 'gnupg' 'pigz' 'cron' 'acl' 'ufw' 'bzip2' 'procps' 'xz-utils')

ALL_PAKGS+=('apt-utils' 'lsb-release' 'software-properties-common')

ALL_PAKGS+=('python3' 'python3-venv' 'python3-pip')

ALL_PAKGS+=('openssh-server' 'openssh-sftp-server' 'fail2ban' 'sendmail')

if [ "${CLOUD_INIT_IS_DEV_MACHINE}" = true ]; then

    ALL_PAKGS+=('net-tools' 'telnet' 'vim' 'git' 'jq' 'zsh' 'htop' 'tmux' 'tree' 'neovim' 'python3-neovim' 'luarocks')

    ALL_PAKGS+=('build-essential' 'ninja-build' 'gettext' 'cmake' 'make')

    ALL_PAKGS+=('openssh-client' 'rsync' 'ntfs-3g' 'exfat-fuse')

    # Assuming below packages are required for GUI applications and not server
    # ALL_PAKGS+=('fontconfig' 'gtk-update-icon-cache' 'libnss3' 'libatk1.0-0' 'libatk-bridge2.0-0' 'libgtk-3-0' 'libgbm-dev' 'libglib2.0-dev' 'libdrm-dev' 'libasound2' 'libcap2-bin')

fi

sudo DEBIAN_FRONTEND=noninteractive apt install -y "${ALL_PAKGS[@]}"

if [ "${CLOUD_INIT_IS_DEV_MACHINE}" = true ]; then
    if [[ $(apt-cache search "linux-headers-$(uname -r)") ]]; then
        echo "installing linux-headers-$(uname -r)"
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "linux-headers-$(uname -r)"
    else
        echo "installing linux-headers"
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "linux-headers"
    fi
fi

getent group "${CLOUD_INIT_GROUPNAME}" || sudo groupadd "${CLOUD_INIT_GROUPNAME}"

sudo DEBIAN_FRONTEND=noninteractive apt install -y zsh
id -u "${CLOUD_INIT_USERNAME}" &>/dev/null ||
    sudo /sbin/useradd -m -d /home/"${CLOUD_INIT_USERNAME}" -g "${CLOUD_INIT_GROUPNAME}" -s /bin/zsh "${CLOUD_INIT_USERNAME}"

sudo mkdir -p /home/"${CLOUD_INIT_USERNAME}"/.ssh
echo "${CLOUD_INIT_USE_SSHPUBKEY}" | sudo tee -a /home/"${CLOUD_INIT_USERNAME}"/.ssh/authorized_keys
sudo chown "${CLOUD_INIT_USERNAME}":"${CLOUD_INIT_GROUPNAME}" -R /home/"${CLOUD_INIT_USERNAME}"/.ssh
sudo chmod 700 /home/"${CLOUD_INIT_USERNAME}"/.ssh
sudo chmod 600 /home/"${CLOUD_INIT_USERNAME}"/.ssh/authorized_keys

sudo mkdir -p /etc/sudoers.d/
sudo su -c 'echo "%'"${CLOUD_INIT_GROUPNAME}"' ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/010-cloudinit'

sudo ufw allow OpenSSH
sudo ufw --force enable
sudo systemctl enable --now ufw
sudo systemctl restart ufw

sudo DEBIAN_FRONTEND=noninteractive apt install -y git
sudo CLOUD_INIT_IS_DEV_MACHINE="${CLOUD_INIT_IS_DEV_MACHINE}" \
  -H -u "${CLOUD_INIT_USERNAME}" bash -c 'set -e && \
  export DEBIAN_FRONTEND=noninteractive && \
  export PATH="${HOME}/.local/bin:${PATH}" && \
  deactivate || true && \
  mkdir -p "${HOME}/.tmp" && \
  rm -rf "${HOME}/.tmp/venv" && \
  python3 -m venv "${HOME}/.tmp/venv" && \
  source "${HOME}/.tmp/venv/bin/activate" && \
  pip install ansible --upgrade && \
  ansible-galaxy collection install git+https://github.com/arpanrec/arpanrec.nebula.git -f && \
  ansible-galaxy role install git+https://github.com/geerlingguy/ansible-role-docker.git,,geerlingguy.docker -f && \
  mkdir "${HOME}/.tmp/cloudinit" -p && \
  echo "[local]" > "${HOME}/.tmp/cloudinit/inv" && \
  echo "localhost ansible_connection=local" >> "${HOME}/.tmp/cloudinit/inv" && \
  ansible-playbook -i "${HOME}/.tmp/cloudinit/inv" \
  --extra-vars "pv_cloud_username=$(whoami) pv_cloud_is_dev_machine=${CLOUD_INIT_IS_DEV_MACHINE}" \
  arpanrec.nebula.cloudinit && \
  ansible-playbook -i "${HOME}/.tmp/cloudinit/inv" arpanrec.nebula.server_workspace \
  --tags all --skip-tags java,bw,go,terraform,vault,nodejs && \
  git --git-dir="$HOME/.dotfiles" --work-tree=$HOME reset --hard HEAD
  '
