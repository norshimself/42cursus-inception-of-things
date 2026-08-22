#!/bin/bash

echo "Deleting bonus-cluster..."
k3d cluster delete bonus-cluster 2>/dev/null || true

echo "Clean up complete!"
