#!/bin/bash

set -e

echo "📦 Creating ConfigMap with Dockerfile and k8s resources..."
kubectl delete configmap spring-petclinic-extra-files -n default --ignore-not-found
kubectl create configmap spring-petclinic-extra-files -n default --from-file=files/

echo "📦 Applying the Tekton Tasks and Pipeline..."
kubectl apply -f task-git-clone-petclinic.yaml -n default
kubectl apply -f task-maven-test-petclinic.yaml -n default
kubectl apply -f task-buildah-spring-petclinic.yaml -n default
kubectl apply -f task-trivy-scan-petclinic.yaml -n default
kubectl apply -f pipeline.yaml -n default

echo "🚀 Triggering the Tekton PipelineRun..."
PIPELINERUN=$(kubectl create -f pipelinerun.yaml -n default -o name)
echo "Created $PIPELINERUN"

echo "⏳ Waiting for PipelineRun to start..."
sleep 10

echo "Following PipelineRun status..."
# Loop to check status more frequently and exit early on failure
while true; do
  STATUS=$(kubectl get $PIPELINERUN -n default -o jsonpath='{.status.conditions[0].status}')
  REASON=$(kubectl get $PIPELINERUN -n default -o jsonpath='{.status.conditions[0].reason}')
  
  if [ "$STATUS" == "True" ]; then
    echo "✅ PipelineRun Succeeded!"
    break
  elif [ "$STATUS" == "False" ]; then
    echo "❌ PipelineRun Failed! Reason: $REASON"
    break
  fi
  
  echo "⏳ Pipeline is still running ($REASON)..."
  sleep 10
done

echo "PipelineRun details:"
kubectl describe $PIPELINERUN -n default
