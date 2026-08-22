#!/bin/bash

# 1. Install prerequisites
curl -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.30.0/bin/linux/amd64/kubectl
chmod +x /usr/local/bin/kubectl
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# 2. Create cluster with app port exposed
k3d cluster create iot-cluster -p "8888:8888@loadbalancer"

# 3. Create namespaces
kubectl create namespace argocd
kubectl create namespace dev

# 4. Install Argo CD & deploy application
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl apply -f "${SCRIPT_DIR}/../confs/application.yaml"

# 5. Argo CD initial password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo ""
