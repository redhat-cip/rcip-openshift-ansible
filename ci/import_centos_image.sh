#!/bin/bash

set -x
set -e

_image=CentOS-7-x86_64-GenericCloud-1603.qcow2

curl -s -o /tmp/${_image}.xz  http://cloud.centos.org/centos/7/images/${_image}.xz
curl -s -o /tmp/sha256sum.txt http://cloud.centos.org/centos/7/images/sha256sum.txt
cd /tmp
sha256sum -c <(grep ${_image}.xz /tmp/sha256sum.txt)
sudo yum install -y xz
xz -d /tmp/${_image}.xz
glance image-create --name "centos7" --disk-format qcow2 --container-format bare --file /tmp/${_image}
cd -
