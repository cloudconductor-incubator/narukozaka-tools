#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

boxes="
    kemumaki-6.5-x86_64.kvm.box
    kemumaki-6.6-x86_64.kvm.box
    minimal-6.5-x86_64.kvm.box
"
#boxes="
#    kemumaki-6.4-x86_64.kvm.box
#    kemumaki-6.5-x86_64.kvm.box
#    kemumaki-6.6-x86_64.kvm.box
# lxckemumaki-6.6-x86_64.kvm.box
#  vzkemumaki-6.6-x86_64.kvm.box
#     minimal-6.3-x86_64.kvm.box
#     minimal-6.4-x86_64.kvm.box
#     minimal-6.6-x86_64.kvm.box
#"

function download_file() {
  local filename=${1}
  [[ -f ${filename}.tmp ]] && return 0

  curl -fSkLR --retry 3 --retry-delay 3 http://dlc.wakame.axsh.jp/wakameci/kemumaki-box-rhel6/current/${filename} -o ${filename}.tmp
  mv ${filename}.tmp ${filename}
}

for box in ${boxes}; do
  echo ... ${box}

  download_file ${box}.md5
  remote_md5=$(< ${box}.md5)

  if [[ -f ${box} ]]; then
    local_md5=$(md5sum ${box} | awk '{print $1}')
    [[ "${remote_md5}" == "${local_md5}" ]] && continue
  fi

  download_file ${box}
done
