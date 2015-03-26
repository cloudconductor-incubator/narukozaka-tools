#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

[[ $UID == 0 ]]
[[ -f box-disk1.raw ]]

qemu-img create -b box-disk1.raw -f qcow2 box-disk1-head.qcow2
