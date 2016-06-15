#!/bin/bash

host=$1

for i in $(seq 80); do
    if [ ! -z "$(./ci/virt-addr.sh $1)" ]; then
        echo "${host} got address"
        exit 0
    fi
    sleep 10
done

echo FAILED
exit 2
