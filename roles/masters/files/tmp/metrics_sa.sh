#!/bin/sh
# creates the metrics service account if needed and display token.
set -x
set -e

[ "root" = "$(whoami)" ]

if ! oc get serviceaccount metrics; then
  oc create -f - <<EOF
{
  "apiVersion": "v1",
  "kind": "ServiceAccount",
  "metadata": {
    "name": "metrics"
  }
}
EOF

  oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:default:metrics
fi

token_name=$(oc get serviceaccount metrics -o json | /opt/bin/jq -r '.secrets[].name | select(  contains( "dockercfg" ) | not)'|tail -n1)
token=$(oc get secret ${token_name} -o json | /opt/bin/jq -r '.data.token' | base64 --decode)

echo -n ${token}
