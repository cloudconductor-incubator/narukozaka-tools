#!/bin/bash
#
# requires:
#  bash
#  yum
#
set -e

chroot_dir=${1}

chroot $1 $SHELL -ex <<'EOS'
  curl -o /etc/yum.repos.d/wakame-vdc.repo -R https://raw.githubusercontent.com/axsh/wakame-vdc/master/rpmbuild/wakame-vdc.repo
  yum install -y epel-release
EOS
