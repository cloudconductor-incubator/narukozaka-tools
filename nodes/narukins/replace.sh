#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

sudo ../common/stop.sh
../../bin/naruko image build
if [[ -f box-disk1-head.qcow2 ]]; then
  sudo rm ./box-disk1-head.qcow2
fi
sudo ./run.sh
