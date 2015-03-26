#!/bin/bash
#
# setup-fedora-20.sh for narukozaka
# requires:
#  bash
#
set -e
set -x

LANG=C
LC_ALL=C

distro_name=fedora
distro_ver=20

# hold releasever
mkdir -p /etc/yum/vars
echo ${distro_ver} > /etc/yum/vars/releasever

# %packages
addpkg=$(cat <<EOS | egrep -v '^%|^@|^#|^$'
%packages --nobase --ignoremissing
@Core
# vmbuilder
openssh
openssh-clients
openssh-server
rpm
yum
curl
dhclient
passwd
vim-minimal
sudo
# build kernel module
kernel-devel
gcc
perl
bzip2
# bootstrap
ntp
ntpdate
man
sudo
rsync
git
make
vim-minimal
screen
nmap
lsof
strace
tcpdump
traceroute
telnet
ltrace
bind-utils
sysstat
nc
wireshark
zip
# shared folder
nfs-utils
#
acpid
# additional packages: kemumaki
bridge-utils
iptables-services
## ci tool
#java-1.6.0-openjdk
java-1.7.0-openjdk
dejavu-sans-fonts
## compilers & rpm/yum build tools
make
gcc
gcc-c++
rpm-build
automake
createrepo
openssl-devel
zlib-devel
kernel-devel
perl
## vm image build tools
qemu-kvm
qemu-img
parted
kpartx
zip
openvswitch
%end
EOS
)

yum install --disablerepo=updates -y ${addpkg}
# base's kpartx is broken.
yum update   --enablerepo=updates -y kpartx
# anti-shellshock
yum update   --enablerepo=updates -y bash

# selinux
if [[ -f /etc/selinux/config ]]; then
  sed -i s,SELINUX=enforcing,SELINUX=disabled, /etc/selinux/config
fi


systemctl disable firewalld.service
systemctl enable  iptables.service

systemctl disable NetworkManager.service
systemctl enable  network.service

### ntp
#systemctl enable ntpdate
#systemctl enable ntpd
#
#systemctl start  ntpdate
#systemctl start  ntpd
#
## NetworkManager.service -> network.service
for ifcfg in /etc/sysconfig/network-scripts/ifcfg-e*; do
  [[ -f ${ifcfg} ]] || continue
  sed -i "s,0=,=," ${ifcfg}
done
if systemctl status  NetowrkManager.service; then
   systemctl stop    NetworkManager.service
fi
systemctl start   network.service

## firewalld.service -> iptables.service
if systemctl status  firewalld.service; then
   systemctl stop    firewalld.service
fi
systemctl start   iptables.service

service network restart
