#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

[[ -f ./metadata/vmspec.conf ]]
.     ./metadata/vmspec.conf

#
monitor_addr=127.0.0.1
monitor_port=$((14000 + ${offset}))

nc ${monitor_addr} ${monitor_port} <<-EOS
	migrate_set_speed 1g
	stop
	migrate "exec: cat > $(pwd)/kvm.state"
	EOS

while ! nc ${monitor_addr} ${monitor_port} <<< "info migrate" | egrep "^Migration status: completed"; do
  sleep 1
done

nc ${monitor_addr} ${monitor_port} <<-EOS
	quit
	EOS
