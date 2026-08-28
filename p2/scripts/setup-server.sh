#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y curl iptables

export INSTALL_K3S_BIN_DIR="/usr/bin"
export INSTALL_K3S_EXEC="server --node-ip=192.168.56.110 --write-kubeconfig-mode=644 --disable metrics-server --disable local-storage"
curl -sfL https://get.k3s.io | sh -

until kubectl wait --for=condition=Ready node --all --timeout=10s 2>/dev/null; do sleep 2; done

kubectl apply -f /home/vagrant/confs/manifest.yaml
