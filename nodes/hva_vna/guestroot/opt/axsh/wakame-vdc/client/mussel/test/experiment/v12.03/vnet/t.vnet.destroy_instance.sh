#!/bin/bash
#
# requires:
#   bash
#

## include files

#
# Usage:
# * destroy lb node
#  $ demo_instance_name="lb" ./t.vnet.destroy_instance.sh
#
# * destroy all the nodes
#  $ ./t.vnet.destroy_instance.sh
#

. ${BASH_SOURCE[0]%/*}/helper_shunit2.sh

vnmgr_host=${vnmgr_host:-"10.255.196.111"}
demo_instance_name=${demo_instance_name:-"all"}

function destroy_instance_one_by_one() {
  local instance_uuids=$1

  for instance_uuid in ${instance_uuids}; do
    cached_file=$(find /tmp -name "*${instance_uuid}*")
    interface_uuids=$(cat ${cached_file} | grep "vif_id" | awk '{print $3}' | sed -e 's,^v,,')

    sed -i "/${instance_uuid}/d" ${uuid_list}

    echo "[info][${instance_uuid}]: destroy instance"
    destroy_instance


    echo "[info][${instance_uuid}]: destroy interfaces"

    for interface_uuid in ${interface_uuids}; do
      echo "[info][${instance_uuid}]: interface uuid => ${interface_uuid}"
      curl -s -X DELETE http://${vnmgr_host}:9090/api/interfaces/${interface_uuid} || :
      ovs-vsctl --if-exist del-port ${interface_uuid}
    done
  done
}

echo "[DEBUG]: instance list before destroy"
echo "===="
cat ${uuid_list}
echo "===="

case ${demo_instance_name} in
all)
  destroy_instance_one_by_one "$(cat ${uuid_list} | awk '{print $2}')"
  ;;
*)
  destroy_instance_one_by_one "$(grep ${demo_instance_name} ${uuid_list} | awk '{print $2}')"
  ;;
esac

echo "[DEBUG]: instance list after destroy"
echo "===="
cat ${uuid_list}
echo "===="
