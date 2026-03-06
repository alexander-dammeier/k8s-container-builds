#!/bin/bash

set -e

echo "📦 Setting up Registry Credentials..."
./setup-registry-secret.sh

echo "📦 Applying RBAC permissions for deployments..."
kubectl apply -f deployer-rbac.yaml -n default

echo "✅ Cluster setup complete!"
