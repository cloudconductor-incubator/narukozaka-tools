#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

sudo /bin/bash -e <<EOS
  ../common/stop.sh

  ../common/qcow2-init.sh
  time sync

  ./run.sh
EOS
