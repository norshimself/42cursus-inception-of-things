#!/bin/bash
set -e

pkill -f "port-forward svc/argocd-server" || true
pkill -f "port-forward svc/gitlab" || true
k3d cluster delete bonus-cluster
