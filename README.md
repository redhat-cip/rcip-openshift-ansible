# rcip-openshift-ansible
Ansible to change config or set up additional stuff


## Step 1
Prerequisite

Setup ansible
```bash
yum -y install http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
yum --enablerepo=epel install ansible -y
```

Run rcip-openshift-ansible <pre>
```bash
ansible-playbook pre.yml
```


## Step 2
Setup openshift

Run playbook openshift
```bash
git clone https://github.com/openshift/openshift-ansible.git
cd openshift-ansible
ansible-playbook playbooks/byo/config.yml
```

## Step 3
Setup monitoring and custom configs

Run rcip-openshift-ansible <post>
```bash
ansible-playbook post.yml
```
