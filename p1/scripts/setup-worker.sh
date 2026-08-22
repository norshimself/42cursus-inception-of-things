#!/bin/bash

echo "=========================================================="
echo "💪 Installing K3s Agent Node: $(hostname)"
echo "=========================================================="

# 1. Housekeeping updates
sudo apt-get update -y
sudo apt-get install -y curl net-tools

# 2. Tell the agent where the control plane is and give it the magic token
export K3S_URL="https://192.168.56.110:6443"
export K3S_TOKEN="42cursusSecretTokenMatrix"
export INSTALL_K3S_EXEC="agent --node-ip=192.168.56.111"

# 3. Download and trigger K3s installation in Agent Mode
curl -sfL https://get.k3s.io | sh -

echo "✅ Worker Node Registered Successfully!"