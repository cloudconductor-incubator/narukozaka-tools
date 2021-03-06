#!/bin/bash

set -e

chroot_dir=${1}

chroot $1 $SHELL -ex <<'EOS'
  pkg_names="
   wakame-vdc-dcmgr-vmapp-config
   wakame-vdc-example-1box-dcmgr-vmapp-config
  "
  for pkg_name in ${pkg_names}; do
    yum search     ${pkg_name} | egrep -q ${pkg_name} || continue
    yum install -y ${pkg_name}
  done
EOS
