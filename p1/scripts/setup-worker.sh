#!/bin/bash

# 1. Install prerequisites
sudo apt-get update -y
sudo apt-get install -y curl net-tools

# 2. Install K3s in agent mode
export K3S_URL="https://192.168.56.110:6443"
export K3S_TOKEN="42cursusSecretTokenMatrix"
export INSTALL_K3S_EXEC="agent --node-ip=192.168.56.111"
curl -sfL https://get.k3s.io | sh -