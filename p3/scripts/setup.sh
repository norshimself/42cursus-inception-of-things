#!/bin/bash
set -e

k3d cluster create iot-cluster -p "8888:8888@loadbalancer"

kubectl apply -f ../confs/namespace-argocd.yaml -f ../confs/namespace-dev.yaml

kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

kubectl apply -f ../confs/application.yaml

echo "Setup complete. App will be reachable at http://localhost:8888/ once Argo CD finishes syncing."

kubectl port-forward svc/argocd-server -n argocd 8080:443 >/dev/null 2>&1 &
echo "Argo CD UI: https://localhost:8080"
echo -n "Argo CD admin password: "
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo
