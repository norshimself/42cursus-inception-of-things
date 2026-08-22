#!/bin/bash

echo "=========================================================="
echo "🚀 Installing K3s Controller Node: $(hostname)"
echo "=========================================================="

# 1. Update system libraries
sudo apt-get update -y
sudo apt-get install -y curl net-tools

# 2. Assign static IP boundaries and define a secure static handshake token
# --token allows us to bypass creating and moving hidden token text files
export K3S_TOKEN="42cursusSecretTokenMatrix"
export INSTALL_K3S_EXEC="server --node-ip=192.168.56.110 --write-kubeconfig-mode=644 --token=${K3S_TOKEN}"

# 3. Download and execute the official K3s binary engine
curl -sfL https://get.k3s.io | sh -

# 4. Configure local non-root user permissions for kubectl queries
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "✅ Server Node Setup Complete!"