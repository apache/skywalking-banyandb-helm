# Local E2E Test Environment Setup

This guide helps you set up and run e2e tests locally using kind (Kubernetes in Docker).

## Prerequisites

1. **Docker Desktop** (or Docker Engine) - must be running
2. **kind** - Kubernetes in Docker
   ```bash
   brew install kind
   # or
   curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-darwin-amd64
   chmod +x ./kind
   sudo mv ./kind /usr/local/bin/kind
   ```

3. **kubectl** - Kubernetes CLI (will be installed automatically by setup script)
4. **helm** - Helm package manager (will be installed automatically by setup script)

## Quick Start

### 1. Run the Setup Script

```bash
./setup-local-e2e.sh
```

This script will:
- Check prerequisites (Docker, kind)
- Install required tools (kubectl, helm, yq)
- Create a kind cluster with 1 control plane + 3 worker nodes
- Add Helm repositories (Bitnami)
- Update chart dependencies

### 2. Verify Setup

```bash
# Check cluster is running
kind get clusters

# Check nodes
kubectl get nodes

# Check tools are installed
kubectl version --client
helm version
```

### 3. Run Tests

#### Option A: Using skywalking-infra-e2e (Recommended)

The CI uses the `apache/skywalking-infra-e2e` GitHub Action. To run locally:

```bash
# Install skywalking-infra-e2e tool (requires Go)
go install github.com/apache/skywalking-infra-e2e/cmd/e2e@latest

# IMPORTANT: The e2e tool manages its own kind cluster.
# If you have an existing cluster from setup-local-e2e.sh, delete it first:
kind delete cluster --name kind

# Run a specific test (the e2e tool will create its own cluster)
e2e run -c test/e2e/e2e-banyandb-fodc-proxy-service.yaml
```

#### Option B: Manual Testing

You can manually run the helm install commands from the test files:

```bash
# Create namespace
kubectl create namespace banyandb

# Install dependencies
cd chart
helm dependency update

# Install BanyanDB (example from fodc-proxy-service test)
helm install -n banyandb banyandb-test . \
  --set cluster.enabled=true \
  --set cluster.fodcProxy.enabled=true \
  --set cluster.fodcProxy.grpcSvc.port=17904 \
  --set cluster.fodcProxy.httpSvc.port=17905 \
  --set cluster.fodcProxy.httpSvc.type=LoadBalancer \
  --set cluster.fodcAgent.enabled=true \
  --set cluster.data.enabled=true \
  --set cluster.data.replicas=1 \
  --set cluster.liaison.enabled=true \
  --set cluster.liaison.replicas=1 \
  --set etcd.enabled=true \
  --set etcd.replicaCount=1 \
  --set image.tag=latest \
  --set cluster.fodcProxy.image.tag=ab3de19288c77701a38e46267ee98509e9d386c2 \
  --set cluster.fodcAgent.image.tag=ab3de19288c77701a38e46267ee98509e9d386c2

# Check status
kubectl get pods -n banyandb
kubectl get svc -n banyandb
```

## Available Test Files

- `test/e2e/e2e-banyandb-fodc-proxy-service.yaml` - FODC proxy service test
- `test/e2e/e2e-banyandb-standalone.yaml` - Standalone deployment test
- `test/e2e/e2e-banyandb-cluster.yaml` - Cluster deployment test
- `test/e2e/e2e-banyandb-lifecycle.yaml` - Lifecycle management test

## Troubleshooting

### Docker is not running
```bash
# Start Docker Desktop, or
open -a Docker
```

### Kind cluster creation fails
```bash
# Delete existing cluster and retry
kind delete cluster --name kind
./setup-local-e2e.sh
```

### Helm dependency update fails
```bash
# Check network connectivity
ping charts.bitnami.com

# Try updating repos manually
helm repo update
cd chart
helm dependency update
```

### Pods stuck in Pending
```bash
# Check node resources
kubectl describe nodes

# Check pod events
kubectl describe pod <pod-name> -n banyandb

# Check if images are being pulled
kubectl get events -n banyandb --sort-by='.lastTimestamp'
```

### Clean up everything
```bash
# Delete all helm releases
helm list -A -q | xargs -I {} helm uninstall {} -n $(helm list -A | grep {} | awk '{print $2}')

# Delete namespaces
kubectl delete namespace banyandb istio-system --ignore-not-found=true

# Delete kind cluster
kind delete cluster --name kind
```

## Manual Verification Steps

After installing, verify the setup:

```bash
# 1. Check etcd pods
kubectl get pods -n banyandb -l app.kubernetes.io/name=etcd

# 2. Check banyandb pods
kubectl get pods -n banyandb -l app.kubernetes.io/name=banyandb

# 3. Check services
kubectl get svc -n banyandb

# 4. Check FODC proxy (if enabled)
kubectl get pods -n banyandb -l app.kubernetes.io/component=fodc-proxy
kubectl get svc -n banyandb | grep fodc-proxy

# 5. Check logs
kubectl logs -n banyandb <pod-name> -c <container-name>
```

## Notes

- The setup script installs tools to `/tmp/skywalking-infra-e2e/bin` - make sure this is in your PATH
- The kind cluster uses Kubernetes v1.28.15
- Some tests require Istio to be installed (see test files for details)
- Image tags in test files may need to be updated to use available images

## Next Steps

1. Review the test files in `test/e2e/` to understand what each test does
2. Modify test parameters as needed for your environment
3. Run tests and verify results match expected outputs in `test/e2e/expected/`
