#!/bin/bash
set -e
set -x

# size in M of swap to create on the slave node
_swap=10240
# number of lines to collect on nodes/masters/.. if one of the playbooks fails.
_loglines=10000
# number of time to retry ansible-playbook run before failing
_retry=3
# version (tag) of the openshift/openshift-ansible repository
_openshift_ansible_version=3.3.35-1

# trap function to collect log if needed
_on_exit() {
  local exit_status=${1:-$?}
  set +e

  if [ ${exit_status} != 0 ]; then
    ansible-playbook -i ci/hosts_centos_origin ci/log_collector.yml -e loglines=${_loglines}
  fi

  exit $exit_status
}

# there is an issue open to add ansible 1.9 support to ansible-profile:
# https://github.com/jlafon/ansible-profile/issues/14
# https://github.com/jlafon/ansible-profile/pull/16
# until it's merged:
mkdir -p callback_plugins
cp ci/profile_tasks.py callback_plugins/

trap "_on_exit" EXIT

echo "==== env ===="
env

echo "==== ps afx ===="
ps afx

echo "==== df -H ===="
df -H

echo "==== free -m ===="
free -m

echo "==== libvirt ===="
sudo yum install -y libvirt virt-install qemu-kvm libguestfs-tools libvirt-daemon-kvm net-tools libxml2
sudo modprobe kvm

sudo systemctl start libvirtd

egrep 'vmx|svm' /proc/cpuinfo

set +e
sudo lsmod|grep kvm
file /dev/kvm
sudo virsh  capabilities
sudo virsh  capabilities | virsh cpu-baseline /dev/stdin
sudo virsh pool-list --all
sudo virsh net-list --all
set -e

echo "==== ansible ===="
sudo yum install -y openssl openssl-devel gcc libffi libffi-devel python-lxml

which pip || sudo easy_install pip
sudo pip install --upgrade pip
# need ansible v2
# NOTE: 2.1.1 is used here, because there is an issue with 2.1.2
# can't run command in playbooks with relative paths.
# TODO: update when issue is fixed.
sudo pip install ansible==2.1.1 --upgrade "paramiko<2"

set -e
. ci/import_centos_image.sh

sudo sync

echo "==== requirements ===="
export PATH="$PATH:/usr/sbin:/sbin"
for i in arp virsh xmllint; do
    which $i
done

ansible-playbook -f 1 -i ci/hosts_centos_origin ci/create_vm.yml

# use ci/ansible.cfg tuned config file for the other playbooks
cp ci/ansible.cfg ansible.cfg

# RCIP pre
set +e
# openshift-ansible
for i in $(seq ${_retry}); do
  ansible-playbook -i ci/hosts_centos_origin pre.yml
  RET=$?
  [ $RET = 0 ] && break;
done

echo "pre.yml: ${i} tries"
[ $RET = 0 ] || exit $RET

set -e
ansible-playbook -i ci/hosts_centos_origin --check pre.yml

sudo yum install -y pyOpenSSL

# official openshift ansible playbook
git clone https://github.com/openshift/openshift-ansible.git
(cd openshift-ansible && git checkout openshift-ansible-${_openshift_ansible_version})

set +e

# openshift-ansible
for i in $(seq ${_retry}); do
  ansible-playbook -i ci/hosts_centos_origin openshift-ansible/playbooks/byo/config.yml
  RET=$?
  [ $RET = 0 ] && break;
done

echo "byo/config.yml: ${i} tries"
[ $RET = 0 ] || exit $RET

# RCIP post
for j in $(seq ${_retry}); do
  ansible-playbook -i ci/hosts_centos_origin post.yml
  RET=$?
  [ $RET = 0 ] && break;
done

echo "post.yml: ${j} tries"
[ $RET = 0 ] || exit $RET

set -e
ansible-playbook -i ci/hosts_centos_origin --check post.yml

ansible-playbook -i ci/hosts_centos_origin ci/tests.yml
