#!/bin/bash
set -e

GITLAB_URL="http://localhost:8081"
GITLAB_API="${GITLAB_URL}/api/v4"
TOKEN="bootstraptoken1234567890abcdef"

k3d cluster create bonus-cluster -p "8888:8888@loadbalancer"

kubectl apply -f ../confs/namespace-argocd.yaml -f ../confs/namespace-dev.yaml -f ../confs/namespace-gitlab.yaml

kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f ../confs/gitlab.yaml
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=600s deployment/gitlab -n gitlab

kubectl port-forward svc/gitlab -n gitlab 8081:80 >/dev/null 2>&1 &

kubectl apply -f ../confs/application.yaml

kubectl port-forward svc/argocd-server -n argocd 8080:443 >/dev/null 2>&1 &

echo "App:      http://localhost:8888 (once Argo CD syncs)"
echo "GitLab:   ${GITLAB_URL} (root / Zk9v!Qr7mLp2xT4c)"
echo "Argo CD:  https://localhost:8080"
echo -n "Argo CD admin password: "
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo
