#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

chroot $1 /bin/bash -ex <<'EOS'
  rpm -Uvh https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
  yum -y install mysql-server mysql zabbix22 zabbix22-server-mysql zabbix22-web zabbix22-web-mysql zabbix22-agent httpd
  chkconfig zabbix-server on
  chkconfig mysqld on
  chkconfig httpd on

  service mysqld start
  mysqladmin create zabbix --default-character-set=utf8
  mysql -uroot zabbix < /var/tmp/dump.sql
  rm -f /var/tmp/dump.sql
  service mysqld stop
EOS
