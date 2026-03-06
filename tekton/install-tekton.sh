#!/bin/bash

set -e

echo "📦 Installing Tekton Operator..."
kubectl apply --filename https://storage.googleapis.com/tekton-releases/operator/latest/release.yaml

echo "⏳ Waiting for Tekton Operator to be ready..."
sleep 5
kubectl wait --for=condition=ready pod --all -n tekton-operator --timeout=300s

echo "⚙️ Configuring Tekton components via TektonConfig..."
# This installs Pipelines, Triggers, and Dashboard (Read-Write)
# and configures automatic pruning of old builds.
kubectl apply -f tekton-config.yaml

echo "⏳ Waiting for Tekton components (Pipelines/Triggers/Dashboard) to be ready..."
# The Operator handles the lifecycle; we wait for the TektonConfig to report Ready
kubectl wait --for=condition=Ready tektonconfig config --timeout=600s

echo "✅ Tekton Operator installation and configuration complete!"
echo "♻️ Automatic pruning is enabled: keeping last 50 runs, scheduled daily at midnight."
echo ""
echo "To access the Dashboard, run:"
echo "kubectl port-forward service/tekton-dashboard 9097:9097 -n tekton-pipelines"
echo "Then open: http://localhost:9097"
