#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

current=${1:-1}
index=$(printf "%04d" ${current})

sudo bash -ex <<EOS
  [[ -f kvm.state ]] && \
  mv -i kvm.state kvm_${index}.state
  ./suspend.sh
  mv -i box-disk1-head.qcow2 box-disk1_${index}.qcow2
  qemu-img create -b box-disk1_${index}.qcow2 -f qcow2 box-disk1-head.qcow2
  ./resume.sh
EOS
