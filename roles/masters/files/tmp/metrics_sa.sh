#!/bin/sh
# creates the metrics service account if needed and display token.
set -x
set -e
OC=$(whereis oc)
OADM=$(whereis oadm)


[ "root" = "$(whoami)" ]

if ! $OC get serviceaccount metrics; then
  $OC create -f - <<EOF
{
  "apiVersion": "v1",
  "kind": "ServiceAccount",
  "metadata": {
    "name": "metrics"
  }
}
EOF

  $OADM policy add-cluster-role-to-user cluster-reader system:serviceaccount:default:metrics
  echo 'CHANGED'
fi
