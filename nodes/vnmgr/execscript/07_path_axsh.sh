#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

chroot $1 /bin/bash -ex <<'EOS'
  echo 'export PATH=$PATH:/opt/axsh/openvnet/ruby/bin:/opt/axsh/openvnet/vnctl/bin:/opt/axsh/vnetscript' >> ~root/.bash_profile
  echo 'export PATH=$PATH:/opt/axsh/openvnet/ruby/bin:/opt/axsh/openvnet/vnctl/bin:/opt/axsh/vnetscript' >> ~kemumaki/.bash_profile
EOS
