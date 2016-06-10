#!/bin/bash

host=$1
export PATH="$PATH:/usr/sbin:/sbin"

mac=$(sudo virsh dumpxml $host | xmllint --xpath 'string(/domain/devices/interface/source[@network = "br_nat"]/../mac/@address)' -)

echo -n $(sudo arp | grep ${mac} | cut -f1 -d' ')
