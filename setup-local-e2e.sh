#!/usr/bin/env bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
E2E_DIR="${SCRIPT_DIR}/test/e2e"
SETUP_DIR="${E2E_DIR}/setup-e2e-shell"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if a command exists
check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."
    
    local missing=0
    
    if ! check_command docker; then
        error "Docker is not installed or not in PATH"
        missing=1
    else
        if ! docker info &> /dev/null; then
            error "Docker is installed but not running. Please start Docker."
            missing=1
        else
            info "✓ Docker is installed and running"
        fi
    fi
    
    if ! check_command kind; then
        error "kind is not installed. Install it with: brew install kind"
        missing=1
    else
        info "✓ kind is installed: $(kind version)"
    fi
    
    if [ $missing -eq 1 ]; then
        error "Please install missing prerequisites and try again"
        exit 1
    fi
}

# Setup tools
setup_tools() {
    info "Setting up required tools..."
    
    export PATH="/tmp/skywalking-infra-e2e/bin:$PATH"
    
    # Install kubectl
    if ! check_command kubectl; then
        info "Installing kubectl..."
        bash "${SETUP_DIR}/install.sh" kubectl
    else
        info "✓ kubectl is already installed: $(kubectl version --client --short 2>/dev/null || echo 'installed')"
    fi
    
    # Install helm
    if ! check_command helm; then
        info "Installing helm..."
        bash "${SETUP_DIR}/install.sh" helm
    else
        info "✓ helm is already installed: $(helm version --short 2>/dev/null || echo 'installed')"
    fi
    
    # Install yq
    if ! check_command yq; then
        info "Installing yq..."
        bash "${SETUP_DIR}/install.sh" yq
    else
        info "✓ yq is already installed: $(yq --version 2>/dev/null || echo 'installed')"
    fi
}

# Create or use existing kind cluster
setup_kind_cluster() {
    info "Setting up kind cluster..."
    
    local cluster_name="kind"
    
    if kind get clusters | grep -q "^${cluster_name}$"; then
        warn "Kind cluster '${cluster_name}' already exists"
        read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            info "Deleting existing cluster..."
            kind delete cluster --name "${cluster_name}"
        else
            info "Using existing cluster"
            return 0
        fi
    fi
    
    info "Creating kind cluster..."
    kind create cluster --name "${cluster_name}" --config "${E2E_DIR}/kind.yaml" --wait 5m
    
    info "✓ Kind cluster created successfully"
    
    # Wait for cluster to be ready
    info "Waiting for cluster to be ready..."
    kubectl wait --for=condition=Ready nodes --all --timeout=5m
    info "✓ Cluster is ready"
}

# Setup Helm repositories
setup_helm_repos() {
    info "Setting up Helm repositories..."
    
    if helm repo list | grep -q bitnami; then
        info "✓ Bitnami repo already added"
    else
        helm repo add bitnami https://charts.bitnami.com/bitnami
        info "✓ Added Bitnami Helm repository"
    fi
    
    helm repo update bitnami
    info "✓ Helm repositories updated"
}

# Update chart dependencies
update_chart_dependencies() {
    info "Updating chart dependencies..."
    
    # Check Docker Hub authentication (can help with rate limiting)
    if ! docker info &> /dev/null || ! docker login &> /dev/null; then
        warn "Not authenticated with Docker Hub. Authentication can help avoid rate limits."
        warn "You can login with: docker login"
    fi
    
    cd "${SCRIPT_DIR}/chart"
    
    # Check if Chart.lock exists and dependencies are already downloaded
    if [ -f "Chart.lock" ] && [ -d "charts" ] && [ "$(ls -A charts 2>/dev/null)" ]; then
        info "Chart dependencies appear to be already downloaded. Using existing dependencies..."
        if helm dependency build; then
            cd "${SCRIPT_DIR}"
            info "✓ Chart dependencies built from lock file"
            return 0
        else
            warn "Failed to build from lock file, will try updating..."
        fi
    fi
    
    # Retry logic for network issues with exponential backoff
    local max_retries=5
    local retry_count=0
    local success=false
    local delay=10
    
    while [ $retry_count -lt $max_retries ]; do
        info "Attempting to update chart dependencies (attempt $((retry_count + 1))/$max_retries)..."
        
        # Try to update dependencies (Helm has its own timeout handling)
        if helm dependency update 2>&1 | tee /tmp/helm-dep-update.log; then
            success=true
            break
        else
            local exit_code=${PIPESTATUS[0]}
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $max_retries ]; then
                warn "Helm dependency update failed (attempt $retry_count/$max_retries, exit code: $exit_code)"
                warn "This might be due to Docker Hub rate limiting or network issues."
                warn "Waiting ${delay} seconds before retry..."
                sleep $delay
                # Exponential backoff: 10s, 20s, 30s, 40s
                delay=$((delay + 10))
            else
                error "Failed to update chart dependencies after $max_retries attempts"
                error ""
                error "Common causes:"
                error "  1. Docker Hub rate limiting (free accounts have pull limits)"
                error "  2. Network connectivity issues"
                error "  3. Firewall/proxy blocking Docker Hub"
                error ""
                error "Solutions:"
                error "  1. Wait 10-15 minutes and try again (Docker Hub rate limit resets)"
                error "  2. Authenticate with Docker Hub: docker login"
                error "  3. Check your network connection"
                error "  4. Try manually: cd chart && helm dependency update"
                error "  5. Try pulling the chart directly: helm pull oci://registry-1.docker.io/bitnamicharts/etcd --version 12.0.18"
                error ""
                error "Last error output:"
                cat /tmp/helm-dep-update.log 2>/dev/null | tail -20 || echo "  (no error log available)"
                exit 1
            fi
        fi
    done
    
    cd "${SCRIPT_DIR}"
    
    if [ "$success" = true ]; then
        info "✓ Chart dependencies updated"
    fi
}

# Main setup function
main() {
    info "Starting local e2e test environment setup..."
    echo
    
    check_prerequisites
    echo
    
    setup_tools
    echo
    
    setup_kind_cluster
    echo
    
    setup_helm_repos
    echo
    
    update_chart_dependencies
    echo
    
    info "=========================================="
    info "Local e2e test environment is ready!"
    info "=========================================="
    echo
    info "Next steps:"
    echo "  1. Make sure Docker is running"
    echo "  2. Run your e2e tests using the skywalking-infra-e2e tool"
    echo "  3. Or manually test with:"
    echo "     cd chart"
    echo "     helm install -n banyandb banyandb-test . --set image.tag=latest"
    echo
    info "To clean up the cluster:"
    echo "  kind delete cluster --name kind"
    echo
}

# Run main function
main "$@"
