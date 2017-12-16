#!/bin/sh

DEPLOYNAME=$1
CONTAINER_NAME=$2
IMAGE_URL=$3

ensure_deploy_variables() {
  if [[ -z "$DEPLOYNAME" ]]; then
    echo "Missing deployment name."
    exit 1
  fi

  if [[ -z "$CONTAINER_NAME" ]]; then
    echo "Missing container name."
    exit 1
  fi

  if [[ -z "$IMAGE_URL" ]]; then
    echo "Missing deployment name."
    exit 1
  fi

}


echo "/usr/local/bin/kubectl --kubeconfig=/app/kubeconfig set image deployment/${DEPLOYNAME} ${CONTAINER_NAME}=${IMAGE_URL}"
/usr/local/bin/kubectl --kubeconfig=/app/kubeconfig set image deployment/${DEPLOYNAME} ${CONTAINER_NAME}=${IMAGE_URL}


echo "Waiting for deployment..."
/usr/local/bin/kubectl --kubeconfig=/app/kubeconfig rollout status -w "deployment/${DEPLOYNAME}"



