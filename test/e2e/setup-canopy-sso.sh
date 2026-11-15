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
NS="${1:?namespace required}"
kubectl -n "$NS" create configmap canopy-sso-idp --from-file=idp.cjs=test/e2e/canopy-sso-idp.cjs --dry-run=client -o yaml | kubectl -n "$NS" apply -f -
kubectl -n "$NS" apply -f test/e2e/canopy-sso-idp.yaml
# Reset the mock outage state when rerunning against an existing test cluster.
kubectl -n "$NS" rollout restart deployment/canopy-sso-idp
kubectl -n "$NS" rollout status deployment/canopy-sso-idp --timeout=180s
