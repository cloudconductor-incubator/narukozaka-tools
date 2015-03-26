#!/bin/bash

set -e
set -o pipefail
set -x

rpm -Uvh http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/6.5/kmod-openvswitch-2.3.0-1.el6.x86_64.rpm || :
rpm -Uvh http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/6.5/openvswitch-2.3.0-1.x86_64.rpm || :

rpm -Uvh http://dlc.wakame.axsh.jp.s3-website-us-east-1.amazonaws.com/epel-release || :
rpm -Uvh ftp://ftp.riken.go.jp/Linux/centos/6.6/os/x86_64/Packages/libyaml-0.1.3-1.4.el6.x86_64.rpm || :

cat > /etc/sysconfig/network-scripts/ifcfg-br0 <<EOF
DEVICE=br0
TYPE=OVSBridge
DEVICETYPE=ovs
ONBOOT=yes
BOOTPROTO=static
IPADDR=10.100.0.3
NETMASK=255.255.255.0
OVS_EXTRA="
 set bridge     \${DEVICE} protocols=OpenFlow10,OpenFlow12,OpenFlow13 --
 set bridge     \${DEVICE} other_config:disable-in-band=true --
 set bridge     \${DEVICE} other-config:datapath-id=0000999999999999 --
 set bridge     \${DEVICE} other-config:hwaddr=02:01:00:00:00:02 --
 set-fail-mode  \${DEVICE} standalone --
 set-controller \${DEVICE} tcp:127.0.0.1:6633
"
EOF

cat > /etc/sysconfig/network-scripts/ifcfg-brtun1 <<EOF
DEVICE=brtun1
TYPE=OVSBridge
DEVICETYPE=ovs
ONBOOT=yes
BOOTPROTO=none
EOF

cat > /etc/sysconfig/network-scripts/ifcfg-brtun2 <<EOF
DEVICE=brtun2
TYPE=OVSBridge
DEVICETYPE=ovs
ONBOOT=yes
BOOTPROTO=none
EOF

service network restart

patch_host="patch00"
patch_edge="patch01"

patch_host_peer="patch-tun1"
patch_edge_peer="patch-tun2"

ovs-vsctl --if-exist del-port brtun1 gre_tis1

ovs-vsctl --may-exist add-port brtun1 gre_tis1 -- set interface gre_tis1 type=gre options:remote_ip=

ovs-vsctl --if-exist del-port brtun1 ${patch_host_peer}
ovs-vsctl --if-exist del-port brtun2 ${patch_edge_peer}
ovs-vsctl --if-exist del-port br0 ${patch_host}
ovs-vsctl --if-exist del-port br0 ${patch_edge}

# # http://blog.scottlowe.org/2012/11/27/connecting-ovs-bridges-with-patch-ports/
ovs-vsctl --may-exist add-port brtun1 ${patch_host_peer} -- set interface ${patch_host_peer} type=patch options:peer=${patch_host}
ovs-vsctl --may-exist add-port brtun2 ${patch_edge_peer} -- set interface ${patch_edge_peer} type=patch options:peer=${patch_edge}

ovs-vsctl --may-exist add-port br0 ${patch_host} -- set interface ${patch_host} type=patch options:peer=${patch_host_peer}
ovs-vsctl --may-exist add-port br0 ${patch_edge} -- set interface ${patch_edge} type=patch options:peer=${patch_edge_peer}



rpm -Uvh http://dlc.wakame.axsh.jp.s3-website-us-east-1.amazonaws.com/epel-release || :
curl -o /etc/yum.repos.d/openvnet.repo -R https://raw.githubusercontent.com/axsh/openvnet/master/openvnet.repo
curl -o /etc/yum.repos.d/openvnet-third-party.repo -R https://raw.githubusercontent.com/axsh/openvnet/master/openvnet-third-party.repo
yum -y remove openvnet-vna openvnet-common
yum -y install openvnet-ruby openvnet-vna openvnet-common

cat > /etc/openvnet/vna.conf <<EOF
node {
  id "edge"
  addr {
    protocol "tcp"
    host ""
    public  ""
    port 9103
  }
}

network {
  uuid ""
  gateway {
    address ""
  }
}
EOF

cat > /etc/openvnet/common.conf <<EOF
registry {
  adapter "redis"
  host ""
  port 6379
}

db {
  adapter "mysql2"
  host "localhost"
  database "vnet"
  port 3306
  user "root"
  password ""
}
EOF

cp ./edge.patch /opt/axsh/openvnet/
cd /opt/axsh/openvnet
patch -p1 < edge.patch

initctl stop vnet-vna || :
initctl start vnet-vna
