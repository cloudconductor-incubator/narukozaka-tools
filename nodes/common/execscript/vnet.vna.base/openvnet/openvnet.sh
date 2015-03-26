#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

chroot $1 /bin/bash -ex <<'EOS'
  releasever=$(< /etc/yum/vars/releasever)

  # xxx HOTFIX: Open vSwitch doesn't support CentOS 6.6. xxx
  case ${releasever} in
    6.6)
      releasever=6.5
      ;;
  esac

  # xxx HOTFIX: Ignore that wakame-vdc-hva-common-vmapp-config depends on old kmod-openvswitch.
  until curl -fsSkL --create-dirs -o /yumdownloaded/kmod-openvswitch.rpm http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/${releasever}/kmod-openvswitch-2.3.0-1.el6.x86_64.rpm; do
    sleep 1
  done
  until curl -fsSkL --create-dirs -o /yumdownloaded/openvswitch.rpm http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/${releasever}/openvswitch-2.3.0-1.x86_64.rpm; do
    sleep 1
  done
  rpm -Uv --nodeps /yumdownloaded/*.rpm
  rm -rf /yumdownloaded

EOS

chroot $1 /bin/bash -ex <<'EOS'
  until curl -fsSkL -o /etc/yum.repos.d/openvnet.repo https://raw.githubusercontent.com/axsh/openvnet/master/openvnet.repo; do
    sleep 1
  done
  until curl -fsSkL -o /etc/yum.repos.d/openvnet-third-party.repo https://raw.githubusercontent.com/axsh/openvnet/master/openvnet-third-party.repo; do
    sleep 1
  done
EOS

chroot $1 /bin/bash -ex <<'EOS'
  yum install --disablerepo=updates -y openvnet
EOS
