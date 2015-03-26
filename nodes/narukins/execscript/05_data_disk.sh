#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

#[[ -f guestroot/etc/fstab ]] || exit 1

chroot $1 /bin/bash -ex <<'EOS'
  mkdir /data
EOS
