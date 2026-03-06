#!/bin/bash

set -e

echo "📦 Re-creating the ConfigMap with the source code..."
kubectl delete configmap go-app-source -n default --ignore-not-found
kubectl create configmap go-app-source -n default --from-file=../../go-webapp/

echo "📦 Applying the Tekton Task..."
kubectl apply -f task-buildah.yaml -n default

echo "🚀 Triggering the Tekton TaskRun..."
# We use generateName, so we create it dynamically.
TASKRUN=$(kubectl create -f taskrun-buildah.yaml -n default -o name)

echo "⏳ Waiting for TaskRun ${TASKRUN} pod to be created..."
sleep 5

POD_NAME=$(kubectl get ${TASKRUN} -n default -o jsonpath='{.status.podName}')

if [ -z "$POD_NAME" ]; then
  echo "Pod name not yet available. Fetching again..."
  sleep 5
  POD_NAME=$(kubectl get ${TASKRUN} -n default -o jsonpath='{.status.podName}')
fi

echo "⏳ Waiting for pod $POD_NAME to start running..."
kubectl wait --for=condition=Ready pod/$POD_NAME -n default --timeout=60s || true

echo "📜 Following build logs for pod: $POD_NAME"
kubectl logs -f $POD_NAME --all-containers --max-log-requests=10 -n default || echo "Check the Tekton Dashboard for detailed logs."

echo "✅ Script finished."
