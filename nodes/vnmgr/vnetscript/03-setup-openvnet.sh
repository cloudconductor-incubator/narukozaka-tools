#!/bin/bash
#
# requires:
#  bash
#
set -x
set -u
set -e
set -o pipefail

vendor_id_if_simulated="52:54:FE"
vendor_id_if_virtual="52:54:FF"
vendor_id_dpn_bcast="00:02:01"

vendor_id_nic_physical="02:01:00"

dp0_uuid="dp-0"
dp0_name=${dp0_uuid}
dp0_nodeid="edge"
dp0_dpid="0x0000999999999999"

dp1_uuid="dp-1"
dp1_name=${dp1_uuid}
dp1_nodeid="vna1"
dp1_dpid="0x0000aaaaaaaaaaaa"

if_edge_dp0_uuid="if-dp0edge"
if_edge_dp0_mac="${vendor_id_nic_physical}:00:00:00"
if_edge_dp0_addr="0.0.0.0"
if_edge_dp0_name="patch01"

if_host_dp1_uuid="if-dp1eth0"
if_host_dp1_mac="${vendor_id_nic_physical}:00:00:01"
if_host_dp1_addr="10.100.0.2"
if_host_dp1_name="patch10"

if_host_dp0_uuid="if-dp0patch"
if_host_dp0_mac="${vendor_id_nic_physical}:00:00:02"
if_host_dp0_addr="10.100.0.3"
if_host_dp0_name="patch00"

nw_pub_uuid="nw-public"
nw_pub_name=${nw_pub_uuid}
nw_pub_network="10.100.0.0"
nw_pub_prefix="24"
nw_pub_mode="physical"
nw_pub_dp0_bcast_mac_addr="${vendor_id_dpn_bcast}:00:00:00"
nw_pub_dp1_bcast_mac_addr="${vendor_id_dpn_bcast}:00:01:00"

nw_mon_uuid="nw-mon"
nw_mon_name=${nw_mon_uuid}
nw_mon_network="10.0.100.0"
nw_mon_prefix="24"
nw_mon_mode="virtual"
nw_mon_dp0_bcast_mac_addr="${vendor_id_dpn_bcast}:00:00:01"
nw_mon_dp1_bcast_mac_addr="${vendor_id_dpn_bcast}:00:01:01"

nw_webdb_uuid="nw-webdb"
nw_webdb_name=${nw_webdb_uuid}
nw_webdb_network="10.0.20.0"
nw_webdb_prefix="24"
nw_webdb_mode="virtual"
nw_webdb_dp0_bcast_mac_addr="${vendor_id_dpn_bcast}:00:00:02"
nw_webdb_dp1_bcast_mac_addr="${vendor_id_dpn_bcast}:00:01:02"

nw_lbweb_uuid="nw-lbweb"
nw_lbweb_name=${nw_lbweb_uuid}
nw_lbweb_network="10.0.10.0"
nw_lbweb_prefix="24"
nw_lbweb_mode="virtual"
nw_lbweb_dp0_bcast_mac_addr="${vendor_id_dpn_bcast}:00:00:03"
nw_lbweb_dp1_bcast_mac_addr="${vendor_id_dpn_bcast}:00:01:03"

# simulated interface for dhcp
if_dhcp_nw_mon_uuid="if-dmon"
if_dhcp_nw_mon_mac_addr="${vendor_id_if_simulated}:00:00:01"
if_dhcp_nw_mon_ip_addr="10.0.100.1"

if_dhcp_nw_webdb_uuid="if-dwebdb"
if_dhcp_nw_webdb_mac_addr="${vendor_id_if_simulated}:00:00:02"
if_dhcp_nw_webdb_ip_addr="10.0.20.1"

if_dhcp_nw_lbweb_uuid="if-dlbweb"
if_dhcp_nw_lbweb_mac_addr="${vendor_id_if_simulated}:00:00:03"
if_dhcp_nw_lbweb_ip_addr="10.0.10.1"

# network service for dhcp
ns_nw_mon_if_uuid=${if_dhcp_nw_mon_uuid}
ns_nw_webdb_if_uuid=${if_dhcp_nw_webdb_uuid}
ns_nw_lbweb_if_uuid=${if_dhcp_nw_lbweb_uuid}


tr_uuid="tr-1"
tr_if_uuid=${if_edge_dp0_uuid}
tr_mode="vnet_edge"

vt_uuid="vt-1"
vt_vlan_id="100"
vt_network_uuid=2 # nw-mon
vt_translation_uuid=${tr_uuid}

cd /opt/axsh/openvnet/vnctl/bin

# TODO implement retry_until
sleep 30

# datapaths
vnctl datapaths add --uuid ${dp0_uuid} --display-name ${dp0_name} --node-id ${dp0_nodeid} --dpid ${dp0_dpid}
vnctl datapaths add --uuid ${dp1_uuid} --display-name ${dp1_name} --node-id ${dp1_nodeid} --dpid ${dp1_dpid}


# public network
vnctl networks add --uuid ${nw_pub_uuid} --display-name ${nw_pub_name} --ipv4-network ${nw_pub_network} --ipv4-prefix ${nw_pub_prefix} --network-mode ${nw_pub_mode}


# interfaces (patch)
vnctl interfaces add --uuid ${if_host_dp0_uuid} --owner-datapath-uuid ${dp0_uuid} --mac-address ${if_host_dp0_mac} --network-uuid ${nw_pub_uuid} --ipv4-address ${if_host_dp0_addr} --port-name ${if_host_dp0_name} --mode patch
vnctl interfaces add --uuid ${if_host_dp1_uuid} --owner-datapath-uuid ${dp1_uuid} --mac-address ${if_host_dp1_mac} --network-uuid ${nw_pub_uuid} --ipv4-address ${if_host_dp1_addr} --port-name ${if_host_dp1_name} --mode patch


# edge interface
vnctl interfaces add --uuid ${if_edge_dp0_uuid} --owner-datapath-uuid ${dp0_uuid} --mac-address ${if_edge_dp0_mac} --ipv4-address ${if_edge_dp0_addr} --port-name ${if_edge_dp0_name} --mode edge


# virtual network
vnctl networks add --uuid ${nw_mon_uuid} --display-name ${nw_mon_name} --ipv4-network ${nw_mon_network} --ipv4-prefix ${nw_mon_prefix} --network-mode ${nw_mon_mode}
vnctl networks add --uuid ${nw_webdb_uuid} --display-name ${nw_webdb_name} --ipv4-network ${nw_webdb_network} --ipv4-prefix ${nw_webdb_prefix} --network-mode ${nw_webdb_mode}
vnctl networks add --uuid ${nw_lbweb_uuid} --display-name ${nw_lbweb_name} --ipv4-network ${nw_lbweb_network} --ipv4-prefix ${nw_lbweb_prefix} --network-mode ${nw_lbweb_mode}


# datapath networks
vnctl datapaths networks add ${dp0_uuid} ${nw_pub_uuid} --broadcast-mac-address ${nw_pub_dp0_bcast_mac_addr} --interface-uuid ${if_host_dp0_uuid}
vnctl datapaths networks add ${dp1_uuid} ${nw_pub_uuid} --broadcast-mac-address ${nw_pub_dp1_bcast_mac_addr} --interface-uuid ${if_host_dp1_uuid}
vnctl datapaths networks add ${dp0_uuid} ${nw_mon_uuid} --broadcast-mac-address ${nw_mon_dp0_bcast_mac_addr} --interface-uuid ${if_host_dp0_uuid}
vnctl datapaths networks add ${dp1_uuid} ${nw_mon_uuid} --broadcast-mac-address ${nw_mon_dp1_bcast_mac_addr} --interface-uuid ${if_host_dp1_uuid}
vnctl datapaths networks add ${dp0_uuid} ${nw_webdb_uuid} --broadcast-mac-address ${nw_webdb_dp0_bcast_mac_addr} --interface-uuid ${if_host_dp0_uuid}
vnctl datapaths networks add ${dp1_uuid} ${nw_webdb_uuid} --broadcast-mac-address ${nw_webdb_dp1_bcast_mac_addr} --interface-uuid ${if_host_dp1_uuid}
vnctl datapaths networks add ${dp0_uuid} ${nw_lbweb_uuid} --broadcast-mac-address ${nw_lbweb_dp0_bcast_mac_addr} --interface-uuid ${if_host_dp0_uuid}
vnctl datapaths networks add ${dp1_uuid} ${nw_lbweb_uuid} --broadcast-mac-address ${nw_lbweb_dp1_bcast_mac_addr} --interface-uuid ${if_host_dp1_uuid}


# interface for dhcp
vnctl interfaces add --uuid ${if_dhcp_nw_mon_uuid} --owner-datapath-uuid ${dp1_uuid} --mac-address ${if_dhcp_nw_mon_mac_addr} --ipv4-address ${if_dhcp_nw_mon_ip_addr} --mode simulated
vnctl interfaces add --uuid ${if_dhcp_nw_webdb_uuid} --owner-datapath-uuid ${dp1_uuid} --mac-address ${if_dhcp_nw_webdb_mac_addr} --ipv4-address ${if_dhcp_nw_webdb_ip_addr} --mode simulated
vnctl interfaces add --uuid ${if_dhcp_nw_lbweb_uuid} --owner-datapath-uuid ${dp1_uuid} --mac-address ${if_dhcp_nw_lbweb_mac_addr} --ipv4-address ${if_dhcp_nw_lbweb_ip_addr} --mode simulated


# network service for dhcp
vnctl network_services add --interface-uuid ${ns_nw_mon_if_uuid} --type "dhcp"
vnctl network_services add --interface-uuid ${ns_nw_webdb_if_uuid} --type "dhcp"
vnctl network_services add --interface-uuid ${ns_nw_lbweb_if_uuid} --type "dhcp"

# translation
vnctl translations add --uuid ${tr_uuid} --interface-uuid ${tr_if_uuid} --mode ${tr_mode}


# vlan translation
vnctl vlan_translations add --uuid ${vt_uuid} --vlan-id ${vt_vlan_id} --network-id ${vt_network_uuid} --translation-uuid ${vt_translation_uuid}
