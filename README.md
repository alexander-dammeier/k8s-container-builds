# Kubernetes Container Builds

This repository shows how to build container images within a kubernetes pod using **Buildah** and **Tekton**.
This way, build pipelines can stay in the cluster:
- No extra build nodes outside kubernetes
- Isolated build environments for every build
- No security issues with the docker socket
- No privileged containers or host mounts

## Prerequisites
- A Kubernetes cluster (e.g., GKE, EKS, or local like k3d/minikube)
- `kubectl` and `helm` installed and configured to your cluster

## Structure
- `/go`: A sample Go web application with a multi-stage Dockerfile.
- `/tekton`: Tekton installation and Task definitions.
- `/cluster-setup`: Global cluster configuration (RBAC, Secrets).

## Quickstart

### 1. Install Tekton
Run the installation script to deploy the **Tekton Operator**, which automatically manages Pipelines, Triggers, and the Dashboard:
```bash
cd tekton
./install-tekton.sh
```
This script also configures an automatic **pruner** to keep your namespace clean of old TaskRuns.

### 2. Configure Credentials
Copy the `.env.template` to `.env` and fill in your private registry credentials:
```bash
cp .env.template .env
# Edit .env with your registry server, username, and password
```

### 3. Setup Cluster Permissions and Secrets
This step only needs to be run once per cluster to configure the registry secrets and RBAC for deployments:
```bash
cd cluster-setup
./setup-cluster.sh
```

### 4. Build and Deploy
Trigger the Tekton pipeline to build your Go app and deploy it to the cluster:
```bash
cd tekton
./build-app.sh
```
The script will follow the logs of the build and deployment process.

## Security Note
This repository uses **Rootless Buildah** with `vfs` storage and `chroot` isolation. To work correctly on restricted environments like GKE, the `TaskRun` uses `Unconfined` Seccomp and AppArmor profiles to allow the necessary filesystem operations without requiring a privileged container.
