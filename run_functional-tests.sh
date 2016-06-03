#!/bin/bash


# number of fork in ansible run, level of parallelism.
_fork=3
# size in M of swap to create on the slave node
_swap=10240
# number of lines to collect on nodes/masters/.. if one of the playbooks fails.
_loglines=10000
# number of time to retry ansible-playbook run before failing
_retry=3
# version (tag) of the openshift/openshift-ansible repository
_openshift_ansible_version=3.0.88-1

# trap function to collect log if needed
_on_exit() {
  local exit_status=${1:-$?}
  set +e

  if [ ${exit_status} != 0 ]; then
    ansible-playbook -i ci/hosts_centos_origin ci/log_collector.yml -e loglines=${_loglines}
  fi

  exit $exit_status
}

trap "_on_exit" EXIT


echo "==== env ===="
env

echo "==== ps afx ===="
ps afx


echo "==== df -H ===="
df -H

echo "==== free -m ===="
free -m

echo "==== cloud ===="
keystone token-get

glance image-list

heat stack-list

neutron net-list

nova list

sudo yum install -y openssl openssl-devel

# need ansible v2
sudo pip install --upgrade pip
sudo pip install ansible --upgrade "paramiko<2"
# required for some os_* ansible module
sudo pip install shade
sudo pip install --upgrade cryptography


set -e
. ci/import_centos_image.sh

sudo sync

# add some swap
if [ ! -e /swapfile ]; then
    sudo dd if=/dev/zero of=/swapfile bs=1M count=${_swap}
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
fi

ansible-playbook -f ${_fork} -i ci/hosts_centos_origin ci/create_vm.yml

# RCIP pre
ansible-playbook -f ${_fork} -i ci/hosts_centos_origin pre.yml

# need ansible v1.9 for official playbook, see:
# https://github.com/openshift/openshift-ansible/issues/1339
sudo pip install "ansible<2" "paramiko<2"
sudo yum install -y pyOpenSSL


# official openshift ansible playbook
git clone https://github.com/openshift/openshift-ansible.git
(cd openshift-ansible && git checkout openshift-ansible-${_openshift_ansible_version})

set +e

# openshift-ansible
for i in $(seq ${_retry}); do
  ansible-playbook -f ${_fork} -i ci/hosts_centos_origin openshift-ansible/playbooks/byo/config.yml
  RET=$?
  [ $RET = 0 ] && break;
done

echo "byo/config.yml: ${i} tries"
[ $RET = 0 ] || exit $RET

# RCIP post
for j in $(seq ${_retry}); do
  ansible-playbook -f ${_fork} -i ci/hosts_centos_origin post.yml
  RET=$?
  [ $RET = 0 ] && break;
done

echo "post.yml: ${j} tries"
[ $RET = 0 ] || exit $RET
