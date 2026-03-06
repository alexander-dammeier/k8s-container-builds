#!/bin/bash

set -e

if [ ! -f ../.env ]; then
  echo "❌ Error: ../.env file not found!"
  echo "Please copy ../.env.template to ../.env and fill in your registry credentials."
  exit 1
fi

echo "📦 Loading environment variables from ../.env..."
source ../.env

if [ -z "$REGISTRY_SERVER" ] || [ -z "$REGISTRY_USERNAME" ] || [ -z "$REGISTRY_PASSWORD" ] || [ -z "$REGISTRY_IMAGE_URL" ]; then
  echo "❌ Error: One or more required environment variables are missing in ../.env"
  exit 1
fi

echo "📦 Creating Kubernetes Secret 'registry-credentials'..."
kubectl delete secret registry-credentials -n default --ignore-not-found
kubectl create secret generic registry-credentials \
  --from-literal=REGISTRY_SERVER="$REGISTRY_SERVER" \
  --from-literal=REGISTRY_USERNAME="$REGISTRY_USERNAME" \
  --from-literal=REGISTRY_PASSWORD="$REGISTRY_PASSWORD" \
  --from-literal=REGISTRY_IMAGE_URL="$REGISTRY_IMAGE_URL" \
  -n default

echo "📦 Creating Kubernetes ImagePullSecret 'registry-pull-secret'..."
kubectl delete secret registry-pull-secret -n default --ignore-not-found
kubectl create secret docker-registry registry-pull-secret \
  --docker-server="$REGISTRY_SERVER" \
  --docker-username="$REGISTRY_USERNAME" \
  --docker-password="$REGISTRY_PASSWORD" \
  -n default

echo "✅ Secrets created successfully."
