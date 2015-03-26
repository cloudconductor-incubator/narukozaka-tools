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

distro_name=centos
distro_ver=6.5

# hold releasever
mkdir -p /etc/yum/vars
echo ${distro_ver} > /etc/yum/vars/releasever

# Use vault.centos.org for old release.
cp ../common/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm || :

# %packages
addpkg=$(cat <<EOS | egrep -v '^%|^@|^#|^$'
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
yum-utils
# shared folder
nfs-utils
#
acpid
# additional packages: kemumaki
bridge-utils
iptables-services
## vm image build tools
qemu-kvm
qemu-img
parted
kpartx
zip
EOS
)

yum install --disablerepo=updates -y ${addpkg}
# anti-shellshock
yum update   --enablerepo=updates -y bash

# selinux
if [[ -f /etc/selinux/config ]]; then
  sed -i s,SELINUX=enforcing,SELINUX=disabled, /etc/selinux/config
fi
setenforce 0

chkconfig iptables on
chkconfig ntpd on
service ntpd start
chkconfig ntpdate on


# openvswitch
rpm -Uvh http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/6.5/kmod-openvswitch-2.3.0-1.el6.x86_64.rpm || :
rpm -Uvh http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/6.5/openvswitch-2.3.0-1.x86_64.rpm || :
chkconfig openvswitch on
service openvswitch start
