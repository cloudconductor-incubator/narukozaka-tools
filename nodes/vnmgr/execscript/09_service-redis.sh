#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

chroot $1 /bin/bash -ex <<'EOS'
  sed -i 's,bind,#bind,' /etc/redis.conf
  chkconfig redis on
EOS
