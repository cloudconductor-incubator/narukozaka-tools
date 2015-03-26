#!/bin/bash

chroot_path=$1

cat rc.local >> $chroot_path/etc/rc.d/rc.local

chroot $1 /bin/bash -ex <<'EOS'
  yum -y install bridge-utils
EOS
