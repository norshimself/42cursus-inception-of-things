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

# 2. Create k3d cluster with app port (8888) and GitLab port (8081)
# Traefik is disabled: it would otherwise claim host port 80 and block GitLab's own LoadBalancer.
k3d cluster create bonus-cluster \
  -p "8888:8888@loadbalancer" \
  -p "8081:80@loadbalancer" \
  --k3s-arg "--disable=traefik@server:*"

# 3. Create required namespaces
until kubectl wait --for=condition=Ready node --all --timeout=10s 2>/dev/null; do sleep 2; done
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

# 6. Wait for GitLab to finish booting (first boot can take several minutes)
# Note: /-/readiness is IP-allowlisted to loopback by GitLab and returns 404 from outside,
# so we check the actual sign-in page instead.
echo "Waiting for GitLab to boot..."
until [ "$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8081/users/sign_in)" = "200" ]; do sleep 10; done

# 7. Create a Personal Access Token for root (GitLab disables password auth on the API by default)
GITLAB_POD="$(kubectl get pod -n gitlab -l app=gitlab -o jsonpath='{.items[0].metadata.name}')"
TOKEN="bootstraptoken1234567890abcdef"
kubectl exec -n gitlab "$GITLAB_POD" -- gitlab-rails runner "
token = User.find_by_username('root').personal_access_tokens.create(scopes: [:api, :read_repository, :write_repository], name: 'bootstrap', expires_at: 365.days.from_now)
token.set_token('${TOKEN}')
token.save!
"

# 8. Create the 'playground' project on GitLab (public, so Argo CD can pull without credentials)
curl -s -X POST http://localhost:8081/api/v4/projects \
  -H "PRIVATE-TOKEN: ${TOKEN}" \
  --form "name=playground" \
  --form "visibility=public" > /dev/null

# 9. Push deployment.yaml into the new repo
TMP_REPO="$(mktemp -d)"
cp "${SCRIPT_DIR}/../confs/deployment.yaml" "$TMP_REPO/"
git -C "$TMP_REPO" init -q -b main
git -C "$TMP_REPO" -c user.email="bot@local" -c user.name="bot" add deployment.yaml
git -C "$TMP_REPO" -c user.email="bot@local" -c user.name="bot" commit -q -m "add deployment"
git -C "$TMP_REPO" remote add origin "http://root:${TOKEN}@localhost:8081/root/playground.git"
git -C "$TMP_REPO" push -q -u origin main
rm -rf "$TMP_REPO"

# 10. Apply Argo CD Application pointing to local GitLab
kubectl apply -f "${SCRIPT_DIR}/../confs/application.yaml"

echo "=========================================================="
echo "Bonus Setup Complete!"
echo "=========================================================="
echo "GitLab URL: http://localhost:8081"
echo "GitLab User: root / Password: Zk9v!Qr7mLp2xT4c"
echo ""
echo "Argo CD Admin Password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo ""
