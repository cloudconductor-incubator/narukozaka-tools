#!/bin/bash
#
# requires:
#  bash
#
set -x
set -e
set -o pipefail

echo db:drop...
cd /opt/axsh/openvnet/vnet && bundle exec rake db:drop
echo db:create...
cd /opt/axsh/openvnet/vnet && bundle exec rake db:create
echo db:init...
cd /opt/axsh/openvnet/vnet && bundle exec rake db:init
