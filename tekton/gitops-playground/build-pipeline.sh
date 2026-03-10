#!/bin/bash

set -e

echo "📦 Applying the Tekton Tasks and Pipeline..."
kubectl apply -f task-git-clone.yaml -n default
kubectl apply -f task-maven-test.yaml -n default
kubectl apply -f task-buildah.yaml -n default
kubectl apply -f task-trivy-scan.yaml -n default
kubectl apply -f pipeline.yaml -n default

echo "🚀 Triggering the Tekton PipelineRun..."
PIPELINERUN=$(kubectl create -f pipelinerun.yaml -n default -o name)
echo "Created $PIPELINERUN"

echo "⏳ Waiting for PipelineRun to start..."
sleep 10

echo "Following PipelineRun status..."
kubectl wait --for=condition=Succeeded $PIPELINERUN -n default --timeout=15m || echo "PipelineRun failed or timed out."

echo "PipelineRun details:"
kubectl describe $PIPELINERUN -n default
