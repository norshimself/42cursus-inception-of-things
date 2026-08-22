#!/bin/bash

# 1. Install prerequisites
curl -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.30.0/bin/linux/amd64/kubectl
chmod +x /usr/local/bin/kubectl
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# 2. Create k3d cluster with app port (8888) and GitLab port (8081)
k3d cluster create bonus-cluster \
  -p "8888:8888@loadbalancer" \
  -p "8081:80@loadbalancer"

# 3. Create required namespaces
kubectl create namespace argocd
kubectl create namespace gitlab
kubectl create namespace dev

# 4. Install Argo CD & GitLab
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f "${SCRIPT_DIR}/../confs/gitlab.yaml"

# 5. Wait for Argo CD server to be ready
echo "Waiting for Argo CD..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# 6. Apply Argo CD Application pointing to local GitLab
kubectl apply -f "${SCRIPT_DIR}/../confs/application.yaml"

echo "=========================================================="
echo "Bonus Setup Complete!"
echo "=========================================================="
echo "GitLab URL: http://localhost:8081"
echo "GitLab User: root / Password: rootpassword123"
echo ""
echo "Argo CD Admin Password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo ""
