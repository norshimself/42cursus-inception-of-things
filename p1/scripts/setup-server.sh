#!/bin/bash

sudo apt-get update
sudo apt-get install -y curl net-tools

# Make ifconfig reachable for all users
sudo ln -sf /usr/sbin/ifconfig /usr/bin/ifconfig

# Install K3s in server mode
export K3S_TOKEN="42cursusSecretTokenMatrix"
export INSTALL_K3S_EXEC="server --node-ip=192.168.56.110 --write-kubeconfig-mode=644 --token=${K3S_TOKEN}"
curl -sfL https://get.k3s.io | sh -