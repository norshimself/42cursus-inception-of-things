#!/bin/bash
set -e

pkill -f "port-forward svc/argocd-server" || true
k3d cluster delete iot-cluster
