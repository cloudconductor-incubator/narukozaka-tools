#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

distro_ver=6.5
[[ -a distro_ver.conf ]] && . distro_ver.conf
box_path=../../boxes/kemumaki-${distro_ver}-x86_64.kvm.box

sudo /bin/bash -e <<EOS
  ../common/stop.sh

  time tar zxvf ${box_path}
  time sync

  ../common/kemumaki-init.sh
  ../common/qcow2-init.sh
  ./run.sh
EOS
