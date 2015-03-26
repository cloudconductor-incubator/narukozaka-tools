#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

chroot $1 /bin/bash -ex <<'EOS'
  rpm -Uvh http://dlc.wakame.axsh.jp/packages/rhel/6/master/20150226145328gited54f8d/noarch/wakame-init-13.08-20150226145328gited54f8d.el6.noarch.rpm
EOS
