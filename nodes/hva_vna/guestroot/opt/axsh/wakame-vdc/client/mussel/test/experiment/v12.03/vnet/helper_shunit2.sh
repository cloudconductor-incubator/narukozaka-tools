# -*-Shell-script-*-
#
# requires:
#   bash
#

## system variables

## include files

. ${BASH_SOURCE[0]%/*}/../helper_shunit2.sh

## group variables

uuid_list="./instance_uuids"
instance_uuids_path=$(generate_cache_file_path instance_uuids)

## group functions
