# rcip-openshift-ansible
Ansible to change config or set up additional stuff


## Step 1 : Prerequisite

Ensure you satisfy the NetworkManager configuration describe in :
  * https://github.com/openshift/training/blob/master/01-Requirements-and-Preparation.md#requirements

Setup ansible

```bash
yum -y install http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
yum --enablerepo=epel install ansible -y
```

Run pre.yml rcip-openshift-ansible 

```bash
ansible-playbook pre.yml
```


## Step 2 : Setup openshift

Run playbook openshift

```bash
git clone https://github.com/openshift/openshift-ansible.git
cd openshift-ansible
ansible-playbook playbooks/byo/config.yml
```

## Step 3 : Setup monitoring and custom configs

Run post.yaml rcip-openshift-ansible

```bash
ansible-playbook post.yml
```
