#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

chroot $1 /bin/bash -ex <<'EOS'
  chkconfig auditd off
  chkconfig postfix off
  chkconfig ntpdate off
EOS

rm -f ${chroot_dir}/etc/sysconfig/iptables
