#!/bin/bash

# script to generate a self-signed certificate
# formatted for kubernetes secrets (base64 encoded)

DIR="secrets"

mkdir -p ${DIR}

openssl dhparam -out ${DIR}/dhparam.pem 2048

openssl req -x509 -nodes -days 365 -newkey rsa:2048  \
  -config ./cert.cnf \
  -keyout ${DIR}/selfsigned.key \
  -out ${DIR}/selfsigned.crt \


cd $DIR

echo "Enter username for basic auth (blank to disable)"
read USER
if [ "${USER}" != "" ]; then
    echo -n "${USER}:" > htpasswd
    echo "Enter username for basic auth (blank to disable)"
    openssl passwd -apr1 >> htpasswd
fi

echo "use these values in the secret-template.yaml file"


if [ "${USER}" != "" ]; then
    x=$(cat htpasswd | base64 )
    echo "htpasswd: '${x}'"
fi
x=$(cat selfsigned.crt | base64 )
echo "proxycert: '${x}'"
x=$(cat selfsigned.key | base64 )
echo "proxykey: '${x}'"
x=$(cat dhparam.pem | base64 )
echo "dhparam: '${x}'"
