#!/usr/bin/env bash
set -e

# These are requird, installed as part of install and kde-extras
#= fuse2 gtkmm libaio linux-headers ncurses libcanberra hicolor-icon-theme gtk3 gcr
pacman -S --needed --noconfirm dkms gtkmm3 pcsclite swtpm wget git 'openssl-1.1'

tmp_vmware_dir=/tmp/vmware_install_bastille

mkdir /etc/init.d/ $tmp_vmware_dir -p
if [ ! -f "$tmp_vmware_dir/vmware.bundle" ]; then
    wget --no-clobber --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:21.0) Gecko/20100101 Firefox/21.0" \
        --no-check-certificate -O $tmp_vmware_dir/vmware.bundle https://www.vmware.com/go/getWorkstation-linux
    # rm -rf $tmp_vmware_dir/vmware.bundle
fi

chmod +x $tmp_vmware_dir/vmware.bundle
/bin/sh $tmp_vmware_dir/vmware.bundle

vmware_version_installed=$(vmware --version | awk '{ print $3 }')

if [ ! -d "$tmp_vmware_dir/vmware-host-modules-workstation-$vmware_version_installed" ]; then
    git clone --depth 1 --single-branch --branch workstation-"$vmware_version_installed" https://github.com/mkubecek/vmware-host-modules.git \
        $tmp_vmware_dir/vmware-host-modules-workstation-"$vmware_version_installed"
else
    cd "$tmp_vmware_dir/vmware-host-modules-workstation-$vmware_version_installed"
    git pull
fi

cd "$tmp_vmware_dir/vmware-host-modules-workstation-$vmware_version_installed"
tar -cf vmmon.tar vmmon-only
tar -cf vmnet.tar vmnet-only

cp -v vmmon.tar vmnet.tar /usr/lib/vmware/modules/source/

vmware-modconfig --console --install-all
modprobe -a vmw_vmci vmmon

echo "VMWare workstation install complete"
