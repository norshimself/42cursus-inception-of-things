#!/bin/bash
set -e

# ==============================================================================
# Inception-of-Things (IoT) - Comprehensive Tools Installer
# Covers requirements for: Part 1, Part 2, Part 3, and Bonus
# ==============================================================================

echo "=== [1/5] Installing System Dependencies, Vagrant, VirtualBox & Docker ==="
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

$SUDO apt-get update -y
$SUDO apt-get install -y \
    curl \
    wget \
    git \
    jq \
    vagrant \
    virtualbox \
    virtualbox-ext-pack \
    virtualbox-guest-additions-iso \
    docker.io

# Configure Docker permissions for current user
$SUDO usermod -aG docker "$USER" || true
$SUDO systemctl enable --now docker || true

echo "=== [2/5] Installing kubectl ==="
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

if ! command -v kubectl &> /dev/null; then
    KUBECTL_VER=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    curl -sSL "https://dl.k8s.io/release/${KUBECTL_VER}/bin/linux/amd64/kubectl" -o "$BIN_DIR/kubectl"
    chmod +x "$BIN_DIR/kubectl"
fi

echo "=== [3/5] Installing k3d ==="
if ! command -v k3d &> /dev/null; then
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | USE_SUDO=false K3D_INSTALL_DIR="$BIN_DIR" bash
fi

echo "=== [4/5] Installing Helm ==="
if ! command -v helm &> /dev/null; then
    curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    USE_SUDO=false HELM_INSTALL_DIR="$BIN_DIR" bash /tmp/get_helm.sh --no-sudo
    rm -f /tmp/get_helm.sh
fi

echo "=== [5/5] Installing ArgoCD CLI ==="
if ! command -v argocd &> /dev/null; then
    ARGOCD_VER=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | jq -r .tag_name)
    curl -sSL -o "$BIN_DIR/argocd" "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VER}/argocd-linux-amd64"
    chmod +x "$BIN_DIR/argocd"
fi

# Ensure ~/.local/bin is in PATH for shell configurations
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] && ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$rc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
    fi
done

echo "=============================================================================="
echo "All tools installed successfully!"
echo "Installed tools summary:"
echo " - kubectl: $(kubectl version --client 2>/dev/null | head -n 1 || echo 'Installed in ~/.local/bin')"
echo " - k3d:     $(k3d version 2>/dev/null | head -n 1 || echo 'Installed in ~/.local/bin')"
echo " - helm:    $(helm version --short 2>/dev/null || echo 'Installed in ~/.local/bin')"
echo " - argocd:  $(argocd version --client --short 2>/dev/null || echo 'Installed in ~/.local/bin')"
echo " - vagrant: $(vagrant --version 2>/dev/null || echo 'Requires apt install')"
echo " - docker:  $(docker --version 2>/dev/null || echo 'Requires apt install')"
echo "=============================================================================="
