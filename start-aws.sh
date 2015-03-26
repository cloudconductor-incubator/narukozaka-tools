#!/bin/bash

set -e
set -x

# TODO: load conf using CLI.
. ./config/packer.conf
. /data/naruko.conf.d/packer.conf

aws configure set region ${aws_region:?"Missing aws_region"}
aws configure set aws_access_key_id ${aws_access_key:?"Missing aws_access_key"}
aws configure set aws_secret_access_key ${aws_secret_key:?"Missing aws_secret_key"}

demo_instance_list="
 lb
 web1
 web2
 db
 zabbix
 bdb
"
demo_instance_name=${demo_instance_name:-"all"}

function run_instance() {
  local image_id=${1}
  local ipaddr=${2}
  local opts="--subnet-id subnet-bbcc1acc --count 1 --instance-type t1.micro --key-name axsh-tis"
  if [[ -n ${3} ]]; then
    opts="${opts} ${3}"
  fi

  local instance_id=$(aws ec2 run-instances \
    --query 'Instances[0].InstanceId' \
    --image-id ${image_id} \
    --private-ip-address ${ipaddr} \
    --block-device-mappings "[{\"DeviceName\": \"/dev/sda\", \"Ebs\": {\"DeleteOnTermination\": true}}]" \
    ${opts} | sed -e 's/^"//' -e 's/"$//')
  aws ec2 wait instance-running --instance-ids ${instance_id}
  echo $instance_id
  local node_name=$(aws ec2 describe-tags \
    --query 'Tags[0].Value' \
    --filters "Name=resource-id,Values=${image_id}" \
      "Name=key,Values=NODE_NAME" | \
      sed -e 's/^"//' -e 's/"$//')
  if [[ -n $node_name ]]; then
    aws ec2 create-tags \
      --resources ${instance_id} \
      --tags "Key=Name,Value=${node_name}"
  fi
  # Record Job ID when it runs from Jenkins.
  if [[ -n ${BUILD_TAG} ]]; then
    aws ec2 create-tags --resources ${instance_id} --tags "Key=JOB_ID,Value=${BUILD_TAG}"
  fi
}

function find_ami_id() {
  local mode=${1:?"Missing mode string. (tag,name)"}
  local filter_opts=

  local name=${2:?"Missing instance name"}
  local commit_id=$(git rev-parse tags/aws-deploy | cut -b -8)

  name=`echo ${name} | sed -e "s/web.*/web/"`

  local ami_name="demo-${name}.${commit_id}"

  case $mode in
    tag)
      # TODO: find filter options for tags.
      #filter_opts="--filters 'Key=tag-key,Values=NODE_NAME' 'Key=tag-value,Values=${2}'"
      ;;
    name)
      filter_opts="--filters Name=name,Values=${ami_name:?"Invalid AMI name"}"
      ;;
    *)
      echo "ERROR: Unknown find mode: $mode" >&2
      exit 1
      ;;
  esac
  local image_id=$(aws ec2 describe-images \
    --query 'Images[0].ImageId' \
    $filter_opts | \
    sed -e 's/^"//' -e 's/"$//')
  echo $image_id
}

function find_options() {
  case $1 in
    lb)     echo "10.0.0.10 --associate-public-ip-address" ;;
    web1)   echo "10.0.0.30 --no-associate-public-ip-address" ;;
    web2)   echo "10.0.0.40 --no-associate-public-ip-address" ;;
    db)     echo "10.0.0.50 --no-associate-public-ip-address" ;;
    zabbix) echo "10.0.0.60 --associate-public-ip-address" ;;
    bdb)    echo "10.0.0.70 --no-associate-public-ip-address" ;;
  esac
}

function contains_element() {
  for element in "${@:2}"; do
    [[ "${element}" == "$1" ]] && return 0;
  done
  return 1
}

if [ "${demo_instance_name}" -ne "all" ]; then
  contains_element ${{demo_instance_name} ${demo_instance_list}
  [[ $? -eq 1 ]] && {
    echo "[ERROR]: invalid argument"
    exit 1
  }
fi

ami_id=`find_ami_id name ${demo_instance_name}`
options=`find_options ${demo_instance_name}`
run_instance ${ami_id} ${options}
