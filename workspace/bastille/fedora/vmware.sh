#!/usr/bin/env bash
mkdir /etc/init.d/ /tmp/nebula -p
if [ ! -f "/tmp/nebula/vmware.bundle" ]; then
  wget --no-clobber --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:21.0) Gecko/20100101 Firefox/21.0" --no-check-certificate -O /tmp/nebula/vmware.bundle https://www.vmware.com/go/getWorkstation-linux
  # rm -rf /tmp/nebula/vmware.bundle
fi
chmod +x /tmp/nebula/vmware.bundle
/bin/sh /tmp/nebula/vmware.bundle

modprobe -a vmw_vmci vmmon
vmware-modconfig --console --install-all

systemctl daemon-reload
