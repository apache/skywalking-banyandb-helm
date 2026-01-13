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

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

usage() {
    cat << EOF
Usage: $0 [OPTIONS] <test-file>

Run e2e tests locally using kind cluster.

Options:
    -h, --help          Show this help message
    -c, --clean         Clean up existing resources before running
    -v, --verbose       Enable verbose output
    --test-only         Skip setup, only run tests

Test files:
    - e2e-banyandb-fodc-proxy-service.yaml
    - e2e-banyandb-standalone.yaml
    - e2e-banyandb-cluster.yaml
    - e2e-banyandb-lifecycle.yaml

Examples:
    $0 e2e-banyandb-fodc-proxy-service.yaml
    $0 --clean e2e-banyandb-fodc-proxy-service.yaml
    $0 --test-only e2e-banyandb-fodc-proxy-service.yaml

EOF
}

# Check if kind cluster exists
check_kind_cluster() {
    if ! kind get clusters | grep -q "^kind$"; then
        error "Kind cluster 'kind' does not exist"
        info "Please run ./setup-local-e2e.sh first"
        exit 1
    fi
    info "✓ Kind cluster exists"
}

# Clean up existing resources
cleanup_resources() {
    info "Cleaning up existing resources..."
    
    # Delete helm releases
    for ns in default banyandb istio-system; do
        if kubectl get namespace "$ns" &>/dev/null; then
            helm list -n "$ns" -q | while read release; do
                if [ -n "$release" ]; then
                    info "Uninstalling helm release: $release in namespace $ns"
                    helm uninstall "$release" -n "$ns" || true
                fi
            done
        fi
    done
    
    # Delete test namespaces (except default)
    for ns in banyandb istio-system; do
        if kubectl get namespace "$ns" &>/dev/null; then
            info "Deleting namespace: $ns"
            kubectl delete namespace "$ns" --wait=false || true
        fi
    done
    
    # Wait for namespaces to be deleted
    sleep 5
    
    info "✓ Cleanup completed"
}

# Run manual test steps (simplified version)
run_manual_test() {
    local test_file="$1"
    local test_path="${E2E_DIR}/${test_file}"
    
    if [ ! -f "$test_path" ]; then
        error "Test file not found: $test_path"
        exit 1
    fi
    
    info "Running manual test steps from: $test_file"
    
    # Extract and run setup steps
    # This is a simplified version - for full e2e, use skywalking-infra-e2e tool
    
    # Create namespace if needed
    if grep -q "namespace: banyandb" "$test_path"; then
        info "Creating banyandb namespace..."
        kubectl create namespace banyandb --dry-run=client -o yaml | kubectl apply -f - || true
    fi
    
    # Extract helm install command
    if grep -q "helm install" "$test_path"; then
        info "Extracting helm install command..."
        # This would need more sophisticated parsing for production use
        warn "For full e2e testing, please use the skywalking-infra-e2e tool"
        warn "See: https://github.com/apache/skywalking-infra-e2e"
    fi
}

# Main function
main() {
    local CLEAN=false
    local VERBOSE=false
    local TEST_ONLY=false
    local TEST_FILE=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -c|--clean)
                CLEAN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --test-only)
                TEST_ONLY=true
                shift
                ;;
            *)
                if [ -z "$TEST_FILE" ]; then
                    TEST_FILE="$1"
                else
                    error "Unknown argument: $1"
                    usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    if [ -z "$TEST_FILE" ]; then
        error "Test file is required"
        usage
        exit 1
    fi
    
    # Check prerequisites
    if [ "$TEST_ONLY" = false ]; then
        check_kind_cluster
    fi
    
    # Cleanup if requested
    if [ "$CLEAN" = true ]; then
        cleanup_resources
    fi
    
    # Run test
    run_manual_test "$TEST_FILE"
    
    info "Test execution completed"
    info "To check resources: kubectl get all -n banyandb"
}

main "$@"
