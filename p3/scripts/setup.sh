#!/bin/bash

# 1. Install prerequisites
if ! command -v docker &> /dev/null; then
  apt-get update -y
  apt-get install -y docker.io
  systemctl enable --now docker
fi

curl -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.30.0/bin/linux/amd64/kubectl
chmod +x /usr/local/bin/kubectl
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# 2. Create cluster with app port and Argo CD UI port exposed
k3d cluster create iot-cluster -p "8888:8888@loadbalancer" -p "8080:443@loadbalancer" --k3s-arg "--disable=traefik@server:*"

# 3. Create namespaces
until kubectl wait --for=condition=Ready node --all --timeout=10s 2>/dev/null; do sleep 2; done
kubectl create namespace argocd
kubectl create namespace dev

# 4. Install Argo CD & deploy application
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl apply -f "${SCRIPT_DIR}/../confs/application.yaml"

# 5. Argo CD initial password
echo "Argo CD UI: https://localhost:8080  (user: admin)"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo ""
