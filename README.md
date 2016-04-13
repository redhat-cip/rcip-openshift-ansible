# rcip-openshift-ansible
Ansible to change config or set up additional stuff

## What
This ansible playbook can setup several additionnal tools and configuration to a standard OSE3 installation on RHEL7 :

* monitoring
  * rabbitmq, redis, sensu-api, sensu-server, uchiwa on a monitoring host
  * sensu-client on all nodes
  * install checks on client nodes for services (etcd, openshift, ...)
  * collectd on all hosts with write-graphite plugin
  * carbon, graphite and grafana
  * monitoring httpd conf (proxy) vhosts :
    * kibana
    * sensu (uchiwa)
    * graphite-web (with mysql as backend)
    * grafana
* logstash on each nodes for logs
* install [rcip-openshift-scripts](https://github.com/redhat-cip/rcip-openshift-scripts) and setup crontabs:
  * backup scripts for etcd
  * cleanup scripts (prune.sh) for docker
* setup *Kubelet/max-pod* limit (max number of pods per node)
* setup HTTP\_PROXY, HTTPS\_PROXY and NO\_PROXY env variables if needed (.bashrc, /etc/sysconfig/*, ... )
* NTP server
* DNS server (dnsmasq) and client
* NTP client configuration
* NFS server (for docker-registry)
* timezone
* mail

Most components are optionnal, depending on the variables defined.

You can check the file <code>hosts.template</code>, to see an example of variables to be defined. Default values are in <code>defaults/main.yml</code> of each role, and in <code>group_vars</code>.

For convenience, we chosed to use the <code>hosts</code> file to set all the configuration, but it is possible to use <code>group_vars/</code> directory as well.

You can use the same <code>hosts</code> file for both [openshift-ansible](https://github.com/openshift/openshift-ansible) and this playbook.

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
