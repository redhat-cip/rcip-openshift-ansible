#!/bin/bash

echo "==== env ===="
env

echo "==== ps afx ===="
ps afx

echo "==== df -H ===="
df -H

echo "==== free -m ===="
free -m

echo "==== ansible ====="
sudo pip install ansible --upgrade
sudo pip install ansible-lint --upgrade

RET=0

for play in pre post ci/create_vm; do
	ansible-playbook --syntax-check -i hosts.template ${play}.yml
  [ $? != 0 ] && RET=2
	ansible-lint ${play}.yml
  [ $? != 0 ] && RET=2
done

exit $RET
