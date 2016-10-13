#!/bin/bash
# creates the monitoring service account if needed and displays token.
set -x
set -e

[ "root" = "$(whoami)" ]

if ! oc -n default get serviceaccount monitoring; then
  oc create -f - <<EOF
{
  "apiVersion": "v1",
  "kind": "ServiceAccount",
  "metadata": {
    "name": "monitoring",
    "namespace": "default"
  }
}
EOF

  oadm -n default policy add-cluster-role-to-user cluster-reader system:serviceaccount:default:monitoring

  echo 'CHANGED'
fi
