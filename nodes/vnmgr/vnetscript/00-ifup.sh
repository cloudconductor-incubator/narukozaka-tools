#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

sudo ifup eth0
sudo ifup eth1
