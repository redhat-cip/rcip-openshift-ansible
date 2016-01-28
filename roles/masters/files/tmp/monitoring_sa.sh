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
	oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:default:monitoring

  echo 'CHANGED'
fi
