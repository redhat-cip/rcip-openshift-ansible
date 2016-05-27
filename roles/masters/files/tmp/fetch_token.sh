#!/bin/sh

OC_TMP=$(whereis oc)
OC=${OC_TMP#* }


token_name=$($OC -n default get serviceaccount "$1" -o json | /opt/bin/jq -r '.secrets[].name | select(  contains( "dockercfg" ) | not)'|tail -n1)
token=$($OC -n default get secret ${token_name} -o json | /opt/bin/jq -r '.data.token' | base64 --decode)

echo -n ${token}
