# rcip-openshift-ansible
Ansible to change config or set up additional stuff


## Step 1 : Prerequisite

Make sure you have the standard OpenShift prerequist fullfilled as documented here :

https://docs.openshift.com/enterprise/3.1/install_config/install/prerequisites.html

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
