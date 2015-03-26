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

cat <<EOS >> ${chroot_dir}/root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6f1rIZIr8yinc1FNsQGDZ4Dy76oyHNvIi/AM24CTQUFpR4CFNVHaixr2XMtRxuOGjdaVELKR33GF/nKtgbSm4nmVmEOhONtFlHswM9rfLFA0FeAWjr79X3shZyM41AQ3uyIjMGm9DPyBmSJCGA7rBkil4H5J7zJhKlRhycIYvtFRE6q4kwUurvjpQEau59+GnkugqCnHK4XvdpY9YxAvRPdOfTf2I90vTWWrzOUIr/n/Vxr+0BQ/cJAc0jrMbXNZZarw+FT0nzgQJoLCz8tecLGjttHeSDFdc+Z081gXB3AY3KiJBTbvs165DBHt91sEc2vxjdnAM2GfYsKGX4cfBw== itest-login
EOS
