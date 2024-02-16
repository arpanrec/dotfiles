#!/usr/bin/env bash
set -e

read -r -n1 -p 'Enter "Y" to enable "nested virtualization" in qemu kvm, (Press any other key to Skip*) : ' kvm_nested
echo ""

proc_type=$(grep vendor /proc/cpuinfo | uniq | awk '{print $3}')
echo "proc_type: ${proc_type}"

# 'gnome-menus 'might require for virtmanager
# 'bridge-utils' is also required, it's installed before, don't cleanup
qemu_packs+=('qemu' 'dmidecode' 'libguestfs' 'dnsmasq' 'openbsd-netcat' 'edk2-ovmf'
  'qemu-arch-extra' 'qemu-block-gluster' 'qemu-block-iscsi'
  'samba' 'ebtables' 'virt-viewer'
  'virt-manager' 'dbus-broker' 'tk' 'swtpm')
## 'qemu-block-rbd'
pacman -S --needed --noconfirm "${qemu_packs[@]}"
echo "-----------------------------------------------------------------------"
echo "       Settings libvirt nested virtualization group and socket         "
echo "-----------------------------------------------------------------------"

## libvirt
sed -i '/^#.*unix_sock_group/s/^#//' /etc/libvirt/libvirtd.conf
sed -i '/^#.*unix_sock_rw_perms/s/^#//' /etc/libvirt/libvirtd.conf
grep -i "unix_sock_group" /etc/libvirt/libvirtd.conf
grep -i "unix_sock_rw_perms" /etc/libvirt/libvirtd.conf

if [[ $kvm_nested == "Y" || $kvm_nested == "y" ]]; then
  case "${proc_type}" in
  GenuineIntel)
    echo "Enable Intel nested virtualization"
    modprobe -r kvm_intel
    modprobe kvm_intel nested=1
    mkdir -p /etc/modprobe.d
    echo "options kvm-intel nested=1" | tee /etc/modprobe.d/kvm-intel.conf
    echo "systool -m kvm_intel -v | grep nested"
    systool -m kvm_intel -v | grep nested
    echo "cat /sys/module/kvm_intel/parameters/nested"
    cat /sys/module/kvm_intel/parameters/nested
    ;;
  AuthenticAMD)
    echo "Enable AMD nested virtualization"
    modprobe -r kvm_amd
    modprobe kvm_amd nested=1
    mkdir -p /etc/modprobe.d
    echo "options kvm_amd nested=1" | tee /etc/modprobe.d/kvm-amd.conf
    echo "systool -m kvm_amd -v | grep -i nested"
    systool -m kvm_amd -v | grep -i nested
    echo "cat /sys/module/kvm_amd/parameters/nested"
    cat /sys/module/kvm_amd/parameters/nested
    ;;
  esac
fi
