#!/bin/bash
set -euo pipefail

CLUSTER_NAME="iot-cluster"

echo "🗑️ Deleting k3d cluster: ${CLUSTER_NAME}..."
k3d cluster delete "${CLUSTER_NAME}" 2>/dev/null || true

echo "✅ Clean up complete!"
