#!/bin/bash

set -x
set -e

_image=CentOS-7-x86_64-GenericCloud-1605.raw

if [ ! -e /tmp/${_image} ]; then
    curl -s -o /tmp/${_image}.tar.gz http://46.231.132.68:8080/v1/AUTH_b50e80d3969f441a8b7b1fe831003e0a/pub/${_image}.tar.gz
    curl -s -o /tmp/sha256sum.txt http://cloud.centos.org/centos/7/images/sha256sum.txt
    cd /tmp
    tar xzf ${_image}.tar.gz
    sha256sum -c <(grep ${_image} /tmp/sha256sum.txt)
    cd -
fi

sudo sync

virt-customize -a /tmp/${_image} \
               --root-password 'password:sf4ever' \
               --run-command 'yum remove -y cloud-init' \
               --run-command 'mkdir -p /root/.ssh' \
               --run-command 'chmod 700 /root/.ssh' \
               --upload ~/.ssh/id_rsa.pub:/root/.ssh/authorized_keys \
               --run-command 'chmod 600 /root/.ssh/*' \
               --run-command 'chown root:root /root/.ssh/*' \
               --run-command 'echo "MTU=1400" >> /etc/sysconfig/network-scripts/ifcfg-eth0' \
               --firstboot-command 'restorecon -R -v /root/.ssh'
