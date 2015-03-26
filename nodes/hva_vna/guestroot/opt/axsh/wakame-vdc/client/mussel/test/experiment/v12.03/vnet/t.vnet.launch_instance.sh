#!/bin/bash
#
# requires:
#   bash
#

## include files

. ${BASH_SOURCE[0]%/*}/helper_shunit2.sh

## variables

#
# Usage:
# * launch lb node
#  $ demo_instance_name="lb" ./t.vnet.launch_instance.sh
#
# * launch all the nodes
#  $ ./t.vnet.launch_instance.sh
#

mac_addr_vendor_id="525400"

network_mon_uuid="nw-mon"
network_lb_web_uuid="nw-lbweb"
network_web_db_uuid="nw-webdb"
network_management_uuid="nw-demo8"

demo_instance_list="
 lb
 web1
 web2
 db
 zabbix
"
demo_instance_name=${demo_instance_name:-${demo_instance_list}}

function needs_vif() { true; }

function select_instance_vif() {
  local instance_name=$1

  case ${instance_name} in
  lb)
    function render_vif_table() {
			cat <<-EOS
			{
			 "eth0":{"index":"0","network":"${network_mon_uuid}","ipv4_addr":"10.0.100.10","mac_addr":"${mac_addr_vendor_id}000101"},
			 "eth1":{"index":"1","network":"${network_lb_web_uuid}","ipv4_addr":"10.0.10.10","mac_addr":"${mac_addr_vendor_id}000201"},
			 "eth2":{"index":"2","network":"${network_management_uuid}","ipv4_addr":"10.1.0.10","mac_addr":"${mac_addr_vendor_id}000401"}
			}
			EOS
    }
    ;;
  web1)
    function render_vif_table() {
			cat <<-EOS
			{
			 "eth0":{"index":"0","network":"${network_mon_uuid}","ipv4_addr":"10.0.100.30","mac_addr":"${mac_addr_vendor_id}000102"},
			 "eth1":{"index":"1","network":"${network_lb_web_uuid}","ipv4_addr":"10.0.10.30","mac_addr":"${mac_addr_vendor_id}000202"},
			 "eth2":{"index":"2","network":"${network_web_db_uuid}","ipv4_addr":"10.0.20.30","mac_addr":"${mac_addr_vendor_id}000302"},
			 "eth3":{"index":"3","network":"${network_management_uuid}","ipv4_addr":"10.1.0.30","mac_addr":"${mac_addr_vendor_id}000402"}
			}
			EOS
    }
    ;;
  web2)
    function render_vif_table() {
			cat <<-EOS
			{
			 "eth0":{"index":"0","network":"${network_mon_uuid}","ipv4_addr":"10.0.100.40","mac_addr":"${mac_addr_vendor_id}000103"},
			 "eth1":{"index":"1","network":"${network_lb_web_uuid}","ipv4_addr":"10.0.10.40","mac_addr":"${mac_addr_vendor_id}000203"},
			 "eth2":{"index":"2","network":"${network_web_db_uuid}","ipv4_addr":"10.0.20.40","mac_addr":"${mac_addr_vendor_id}000303"},
			 "eth3":{"index":"3","network":"${network_management_uuid}","ipv4_addr":"10.1.0.40","mac_addr":"${mac_addr_vendor_id}000403"}
			}
			EOS
    }
    ;;
  db)
    function render_vif_table() {
			cat <<-EOS
			{
			 "eth0":{"index":"0","network":"${network_mon_uuid}","ipv4_addr":"10.0.100.50","mac_addr":"${mac_addr_vendor_id}000104"},
			 "eth1":{"index":"1","network":"${network_web_db_uuid}","ipv4_addr":"10.0.20.50","mac_addr":"${mac_addr_vendor_id}000304"},
			 "eth2":{"index":"2","network":"${network_management_uuid}","ipv4_addr":"10.1.0.50","mac_addr":"${mac_addr_vendor_id}000404"}
			}
			EOS
     }
    ;;
  zabbix)
    function render_vif_table() {
			cat <<-EOS
			{
			 "eth0":{"index":"0","network":"${network_mon_uuid}","ipv4_addr":"10.0.100.60","mac_addr":"${mac_addr_vendor_id}000105"},
			 "eth1":{"index":"1","network":"${network_management_uuid}","ipv4_addr":"10.1.0.60","mac_addr":"${mac_addr_vendor_id}000405"}
			}
			EOS
     }
    ;;
  *)
    echo "[ERROR]: invalid instance name"
    ;;
  esac
}

function demo_image_id() {
  case $1 in
  lb)     echo "wmi-demolb";;
  web*)   echo "wmi-demoweb";;
  db)     echo "wmi-demodb";;
  zabbix) echo "wmi-demozabbix";;
  esac
}


for instance in ${demo_instance_name}; do
  image_id=`demo_image_id ${instance}`
  select_instance_vif ${instance}
  create_instance
  echo "${instance} ${instance_uuid}" >> ${uuid_list}
done
