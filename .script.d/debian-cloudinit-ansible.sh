#!/usr/bin/env bash
set -e

sudo apt update

if ! command -v sudo &>/dev/null; then
    DEBIAN_FRONTEND=noninteractive apt install sudo -y
fi

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
sudo hostnamectl set-hostname "${CLOUD_INIT_HOSTNAME}"

sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

sudo DEBIAN_FRONTEND=noninteractive apt install -y \
    zip unzip tar wget curl ca-certificates sudo systemd systemd-timesyncd gnupg2 apt-transport-https locales network-manager gnupg pigz cron acl ufw \
    net-tools build-essential bzip2 \
    telnet lsb-release software-properties-common \
    python3 python3-venv python3-pip xz-utils \
    vim git fontconfig gtk-update-icon-cache libnss3 libatk1.0-0 libatk-bridge2.0-0 libgtk-3-0 \
    libgbm-dev libglib2.0-dev libdrm-dev libasound2 jq zsh libcap2-bin ntfs-3g exfat-fuse \
    openssh-client openssh-server openssh-sftp-server rsync ninja-build gettext cmake make

if [[ $(apt-cache search "linux-headers-$(uname -r)") ]]; then
    echo "installing linux-headers-$(uname -r)"
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "linux-headers-$(uname -r)"
else
    echo "installing linux-headers"
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "linux-headers"
fi

getent group "${CLOUD_INIT_GROUPNAME}" || sudo groupadd "${CLOUD_INIT_GROUPNAME}"

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

sudo -H -u "${CLOUD_INIT_USERNAME}" bash -c 'set -e && \
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
  ansible-playbook -i "${HOME}/.tmp/cloudinit/inv" --extra-vars "pv_cloud_username=$(whoami)" arpanrec.nebula.cloudinit && \
  ansible-playbook -i "${HOME}/.tmp/cloudinit/inv" arpanrec.nebula.server_workspace --tags all && \
  git --git-dir="$HOME/.dotfiles" --work-tree=$HOME reset --hard HEAD
  '
