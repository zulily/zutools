#!/bin/sh

K8S_LABEL=$1     #"label"
K8S_SERVER=$2    # "http://server"
K8S_CA_DATA=$3    # "cadata"
K8S_CLIENT_TOKEN=$4 #"clientdata"
K8S_NAMESPACE=$5   #"default"

ensure_deploy_variables() {
  if [[ -z "$K8S_LABEL" ]]; then
    echo "Missing K8S_LABEL."
    exit 1
  fi

  if [[ -z "$K8S_SERVER" ]]; then
    echo "Missing K8S_SERVER."
    exit 1
	fi

  if [[ -z "$K8S_CA_DATA" ]]; then
    echo "Missing K8S_CA_DATA."
    exit 1
	fi

  if [[ -z "$K8S_CLIENT_TOKEN" ]]; then
    echo "Missing K8S_CLIENT_TOKEN."
    exit 1
  fi

  if [[ -z "$K8S_NAMESPACE" ]]; then
    echo "No namespace specified -- using default."
    K8S_NAMESPACE="default"
  fi
}

ensure_deploy_variables

tee /app/kubeconfig <<-EOT
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${K8S_CA_DATA}
    server: ${K8S_SERVER}
  name: ${K8S_LABEL}
contexts:
- context:
    cluster: ${K8S_LABEL}
    namespace: ${K8S_NAMESPACE}
    user: ${K8S_LABEL}
  name: ${K8S_LABEL}
current-context: ${K8S_LABEL}
kind: Config
preferences: {}
users:
- name: ${K8S_LABEL}
  user:
    token: ${K8S_CLIENT_TOKEN}
EOT

