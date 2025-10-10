#!/bin/bash

read -p "Enter the GitLab PAT: " PAT
read -p "Is the current cluster MicroK8s? (y/n): " MICROK8S

if [ "$MICROK8S" == "y" ]; then
    microk8s kubectl create secret generic gitlab-eso-secret \
        --namespace external-secrets \
        --from-literal=token=${PAT}
else
    kubectl create secret generic gitlab-eso-secret \
        --namespace external-secrets \
        --from-literal=token=${PAT}
fi
