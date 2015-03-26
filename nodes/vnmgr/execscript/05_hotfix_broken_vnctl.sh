#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

chroot $1 /bin/bash -ex <<'EOS'
  cd /opt/axsh/openvnet/vnctl && /opt/axsh/openvnet/ruby/bin/bundle install
EOS
