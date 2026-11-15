#!/usr/bin/env bash
# Licensed to Apache Software Foundation (ASF) under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Apache Software Foundation (ASF) licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail
RELEASE="${1:?release required}"
NS="${2:?namespace required}"
# Explicit forwards keep callback cookies on localhost in CI and local runs.
kubectl -n "$NS" port-forward "svc/${RELEASE}-canopy" 14000:4000 >/dev/null 2>&1 &
CANOPY_PF=$!
kubectl -n "$NS" port-forward svc/canopy-sso-idp 18080:8080 >/dev/null 2>&1 &
IDP_PF=$!
trap 'kill "$CANOPY_PF" "$IDP_PF" 2>/dev/null || true' EXIT
python3 test/e2e/verify-canopy-sso.py
