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
  echo 'CHANGED'
fi
