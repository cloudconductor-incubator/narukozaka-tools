#!/bin/bash
#
# requires:
#  bash
#

set -e
set -x


../common/setup-centos-6.sh || :

. ../common/setup-openvswitch.sh

# install wakame-vdc

curl -o /etc/yum.repos.d/wakame-vdc.repo -R https://raw.githubusercontent.com/axsh/wakame-vdc/master/rpmbuild/wakame-vdc.repo
yum install -y epel-release
pkg_names="
 wakame-vdc-hva-kvm-vmapp-config
"
for pkg_name in ${pkg_names}; do
  yum search     ${pkg_name} | egrep -q ${pkg_name} || continue
  yum install -y ${pkg_name}
done
if [ -f /etc/wakame-vdc/convert_specs/load_balancer.yml ]; then
  sed -i "s,hypervisor: .*,hypervisor: 'kvm'," /etc/wakame-vdc/convert_specs/load_balancer.yml
fi


# install openvnet

until curl -fsSkL -o /etc/yum.repos.d/openvnet.repo https://raw.githubusercontent.com/axsh/openvnet/master/openvnet.repo; do
  sleep 1
done
until curl -fsSkL -o /etc/yum.repos.d/openvnet-third-party.repo https://raw.githubusercontent.com/axsh/openvnet/master/openvnet-third-party.repo; do
  sleep 1
done

rpm -Uvh ftp://ftp.riken.go.jp/Linux/centos/6.6/os/x86_64/Packages/libyaml-0.1.3-1.4.el6.x86_64.rpm || :


initctl stop vnet-vna || :
yum install --disablerepo=updates -y openvnet-vna

make_bridge br0
make_bridge br1 # for management
make_bridge brtun

if [[ -d guestroot ]]; then
  rsync -avxSL guestroot/ /
fi

service openvswitch stop || :
service openvswitch start
service network restart
service sshd restart

ovs-vsctl --may-exist add-port br0 patch10 -- set interface patch10 type=patch options:peer=ptun
ovs-vsctl --may-exist add-port brtun ptun -- set interface ptun type=patch options:peer=patch10

ovs-vsctl --may-exist add-port brtun gre-aws -- set interface gre-aws type=gre options:remote_ip=

initctl start vnet-vna
