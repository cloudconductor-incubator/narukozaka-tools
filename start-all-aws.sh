#!/bin/bash

set -e

# TODO: load conf using CLI.
. ./config/packer.conf
. /data/naruko.conf.d/packer.conf

aws configure set region ${aws_region:?"Missing aws_region"}
aws configure set aws_access_key_id ${aws_access_key:?"Missing aws_access_key"}
aws configure set aws_secret_access_key ${aws_secret_key:?"Missing aws_secret_key"}

commit_id=$(git rev-parse tags/aws-deploy | cut -b -8)
demo_lb_ami="demo-lb.${commit_id}"
demo_web_ami="demo-web.${commit_id}"
demo_db_ami="demo-db.${commit_id}"
demo_zabbix_ami="demo-zabbix.${commit_id}"

which aws
# Check if all associated resources exist.
aws ec2 describe-subnets --subnet-ids subnet-bbcc1acc
aws ec2 describe-key-pairs --key-names axsh-tis

function find_ami_id() {
  local mode=${1:?"Missing mode string. (tag,name)"}
  local filter_opts=
  case $mode in
    tag)
      # TODO: find filter options for tags.
      #filter_opts="--filters 'Key=tag-key,Values=NODE_NAME' 'Key=tag-value,Values=${2}'"
      ;;
    name)
      filter_opts="--filters Name=name,Values=${2:?Missing AMI name}"
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

find_ami_id name ${demo_lb_ami}
find_ami_id name ${demo_web_ami}
find_ami_id name ${demo_db_ami}
find_ami_id name ${demo_zabbix_ami}

run_instance $(find_ami_id name ${demo_lb_ami})     10.0.0.10 "--associate-public-ip-address"
run_instance $(find_ami_id name ${demo_web_ami})    10.0.0.30 "--no-associate-public-ip-address"
run_instance $(find_ami_id name ${demo_db_ami})     10.0.0.50 "--no-associate-public-ip-address"
run_instance $(find_ami_id name ${demo_zabbix_ami}) 10.0.0.60 "--associate-public-ip-address"
