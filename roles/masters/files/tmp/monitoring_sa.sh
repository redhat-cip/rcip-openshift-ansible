#!/bin/sh
# creates the monitoring service account if needed and displays token.
set -x
set -e

[ "root" = "$(whoami)" ]

if ! oc get serviceaccount monitoring; then
  oc create -f - <<EOF
{
  "apiVersion": "v1",
  "kind": "ServiceAccount",
  "metadata": {
    "name": "monitoring"
  }
}
EOF

  oadm policy add-cluster-role-to-user basic-user system:serviceaccount:default:monitoring
fi

token_name=$(oc get serviceaccount monitoring -o json | /opt/bin/jq -r '.secrets[].name | select(  contains( "dockercfg" ) | not)'|tail -n1)
token=$(oc get secret ${token_name} -o json | /opt/bin/jq -r '.data.token' | base64 --decode)

echo -n $token
