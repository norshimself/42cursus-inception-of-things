#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y curl net-tools

export INSTALL_K3S_EXEC="server --node-ip=192.168.56.110 --write-kubeconfig-mode=644"
curl -sfL https://get.k3s.io | sh -

kubectl apply -f /vagrant/confs/manifest.yaml
