#!/bin/sh
# creates the metrics service account and the ansible local facts associated
set -x
set -e

[ "root" = "$(whoami)" ]

oc get serviceaccount metrics || oc create -f - <<EOF
{
  "apiVersion": "v1",
  "kind": "ServiceAccount",
  "metadata": {
    "name": "metrics"
  }
}
EOF

oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:default:metrics

token_name=$(oc get serviceaccount metrics -o json | /opt/bin/jq -r '.secrets[].name | select(  contains( "dockercfg" ) | not)'|tail -n1)
token=$(oc get secret ${token_name} -o json | /opt/bin/jq -r '.data.token')

# add ansible fact
mkdir -p /etc/ansible/facts.d/
fact=/etc/ansible/facts.d/openshift_data.fact
touch $fact
chmod 600 $fact
cat >>$fact <<EOF
[tokens]
metrics=${token}
EOF
