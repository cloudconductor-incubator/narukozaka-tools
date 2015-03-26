#!/bin/bash
#
# requires:
#  bash
#
set -x
set -e
set -o pipefail

sudo stop vnet-vnmgr  || true
sudo stop vnet-webapi || true

sudo start vnet-vnmgr
sudo start vnet-webapi
sudo status vnet-vnmgr
sudo status vnet-webapi
