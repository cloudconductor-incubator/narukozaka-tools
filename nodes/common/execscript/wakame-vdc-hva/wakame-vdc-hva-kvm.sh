#!/bin/bash

set -e

chroot_dir=${1}

chroot $1 $SHELL -ex <<'EOS'
  pkg_names="
   wakame-vdc-hva-kvm-vmapp-config
  "
  for pkg_name in ${pkg_names}; do
    yum search     ${pkg_name} | egrep -q ${pkg_name} || continue
    yum install -y ${pkg_name}
  done
  if [ -f /etc/wakame-vdc/convert_specs/load_balancer.yml ]; then
    sed -i "s,hypervisor: .*,hypervisor: 'kvm'," /etc/wakame-vdc/convert_specs/load_balancer.yml
  fi
EOS
