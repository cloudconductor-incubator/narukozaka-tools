#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

chroot $1 /bin/bash -ex <<'EOS'
  curl -o /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
  rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
  yum -y install java-1.7.0-openjdk
  yum -y install jenkins
  chkconfig --list jenkins
  chkconfig jenkins on
  chkconfig --list jenkins
EOS
