#!/bin/bash

host=$1
user=$2
echo
echo "Host ${host}"
echo "User ${user}"
echo "Hostname $(./ci/virt-addr.sh ${host})"
