#!/bin/bash
#
# setup-openvswitch.sh for narukozaka
# requires:
#  bash
#
set -e
set -x

LANG=C
LC_ALL=C

function make_bridge() {
  local brname=$1
cat > /etc/sysconfig/network-scripts/ifcfg-${brname} <<EOF
DEVICE=${brname}
ONBOOT=yes
DEVICETYPE=ovs
TYPE=OVSBridge
BOOTPROTO=none
EOF

  ifdown ${brname}
  ifup ${brname}
}

