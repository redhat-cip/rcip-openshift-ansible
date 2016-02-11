#!/bin/sh
# creates the metrics service account if needed and display token.
set -x
set -e
OC_TMP=$(whereis oc)
OC=${OC_TMP#* }
OADM_TMP=$(whereis oadm)
OADM=${OADM_TMP#* }


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
