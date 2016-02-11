#!/bin/sh
# creates the monitoring service account if needed and displays token.
set -x
set -e

[ "root" = "$(whoami)" ]

OC_TMP=$(whereis oc)
OC=${OC_TMP#* }
OADM_TMP=$(whereis oadm)
OADM=${OADM_TMP#* }


if ! $OC get serviceaccount monitoring; then
  $OC create -f - <<EOF
{
  "apiVersion": "v1",
  "kind": "ServiceAccount",
  "metadata": {
    "name": "monitoring"
  }
}
EOF

  $OADM policy add-cluster-role-to-user cluster-reader system:serviceaccount:default:monitoring

  echo 'CHANGED'
fi
