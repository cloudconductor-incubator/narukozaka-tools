#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

mkdir -p -m 700 ${chroot_dir}/root/.ssh
chmod       700 ${chroot_dir}/root/.ssh

cat <<'EOS' > ${chroot_dir}/root/.bash_profile
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin
PATH=/opt/axsh/openvnet/ruby/bin/:$PATH

export PATH
EOS

chmod 644 ${chroot_dir}/root/.bash_profile
