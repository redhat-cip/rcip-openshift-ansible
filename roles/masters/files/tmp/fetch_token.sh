#!/bin/sh

OC=$(which oc)

token_name=$($OC get serviceaccount "$1" -o json | /opt/bin/jq -r '.secrets[].name | select(  contains( "dockercfg" ) | not)'|tail -n1)
token=$($OC get secret ${token_name} -o json | /opt/bin/jq -r '.data.token' | base64 --decode)

echo -n ${token}
