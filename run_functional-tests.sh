#!/bin/bash

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

# need ansible v2
sudo pip install ansible --upgrade
# required for some os_* ansible module
sudo pip install shade
sudo pip install --upgrade cryptography


set -e
. ci/import_centos_image.sh

sudo sync

# add some swap
if [ ! -e /swapfile ]; then
    sudo dd if=/dev/zero of=/swapfile bs=1M count=10240
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
fi

ansible-playbook -i ci/hosts_centos_origin ci/create_vm.yml

# RCIP pre
ansible-playbook -i ci/hosts_centos_origin pre.yml

# need ansible v1.9 for official playbook, see:
# https://github.com/openshift/openshift-ansible/issues/1339
sudo pip install "ansible<2"
sudo yum install -y pyOpenSSL


# official openshift ansible playbook
git clone https://github.com/openshift/openshift-ansible.git
(cd openshift-ansible && git checkout openshift-ansible-3.0.78-1)
ansible-playbook -i ci/hosts_centos_origin openshift-ansible/playbooks/byo/config.yml

# RCIP post
ansible-playbook -i ci/hosts_centos_origin post.yml
