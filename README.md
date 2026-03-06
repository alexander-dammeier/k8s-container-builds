# Kubernetes Container Builds

This repository shows how to build container images within a kubernetes pod using **Buildah** and **Tekton**.
This way, build pipelines can stay in the cluster:
- No extra build nodes outside kubernetes
- Isolated build environments for every build
- No security issues with the docker socket
- No privileged containers or host mounts

## Overview

In this showcase we will build a simple go-webapp form this repository inside a pod. We push the app to a configured registry and deploy it to the cluster. To start the build, we install Tekton and deploy a simple Tekton task and a taskRun with a simple script. No Git-Commit-Webhook needed.

Feel free to fork this repository and modify the example for your best learning experience.

## Prerequisites
- A Kubernetes cluster (e.g., GKE, EKS, or local like k3d/minikube)
- `kubectl` and `helm` installed and configured to your cluster

## Structure
- `/go-webapp`: A sample Go web application with a multi-stage Dockerfile.
- `/tekton`: Tekton installation and subdirectories for app-specific tasks
- `/tekton/go-webapp`: build resources and scripts for the go-webapp
- `/cluster-setup`: Global cluster configuration (RBAC, Secrets).

## Quickstart

The scripts used in this showcase are simple. Have a look inside to see what is happening.
For fast results, just execute them.

### 1. Install Tekton
Run the installation script to deploy the **Tekton Operator**, which automatically manages Pipelines:
```bash
cd tekton
./install-tekton.sh
```

### 2. Configure Credentials
Copy the `.env.template` to `.env` and fill in your private registry credentials.
The Account you use should have:
- push permissions for built images
- pull permissions to install the app in the cluster
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
Trigger the Tekton pipeline to build the Go app and deploy it to the cluster:
```bash
cd tekton/go-webapp
./build-app.sh
```
The script will follow the logs of the build and deployment process for easy debugging.

## Security Note
This repository uses **Rootless Buildah** with `vfs` storage and `chroot` isolation. To work correctly on restricted environments like GKE, the `TaskRun` uses `Unconfined` Seccomp and AppArmor profiles to allow the necessary filesystem operations without requiring a privileged container.