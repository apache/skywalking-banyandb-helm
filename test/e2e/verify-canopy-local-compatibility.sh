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

# Reuse the SSO-capable image to verify both legacy local credential paths.
set -euo pipefail
RELEASE="${1:?release required}"
NS="${2:?namespace required}"
helm -n "$NS" upgrade --wait --timeout 5m "$RELEASE" chart/ \
  -f test/e2e/values.canopy.yaml \
  --set canopy.image.tag=874367dc8c8e218d36c404ecbde91818e0922847-canopy
# Service port-forward can select a terminating pod from the previous auth mode.
wait_for_rollout() {
  kubectl -n "$NS" rollout status "deployment/${RELEASE}-canopy" --timeout=180s
  kubectl -n "$NS" get pods -l "app.kubernetes.io/instance=${RELEASE},app.kubernetes.io/component=canopy" -o json | \
    python3 -c 'import json,sys; print("\n".join(p["metadata"]["name"] for p in json.load(sys.stdin)["items"] if p["metadata"].get("deletionTimestamp")))' | \
    while read -r pod; do
      [ -z "$pod" ] || kubectl -n "$NS" wait --for=delete "pod/$pod" --timeout=90s
    done
}
wait_for_rollout
bash test/e2e/verify-canopy.sh "$RELEASE" "$NS"
# Keep generated credentials in a distinct externally managed Secret.
kubectl -n "$NS" get secret "${RELEASE}-canopy-auth" -o json | \
  python3 -c 'import json,sys; s=json.load(sys.stdin); print(json.dumps({"apiVersion":"v1","kind":"Secret","metadata":{"name":"canopy-existing-auth"},"data":s["data"]}))' | \
  kubectl -n "$NS" apply -f -
helm -n "$NS" upgrade --wait --timeout 5m "$RELEASE" chart/ \
  -f test/e2e/values.canopy.yaml \
  --set canopy.image.tag=874367dc8c8e218d36c404ecbde91818e0922847-canopy \
  --set canopy.auth.existingSecret=canopy-existing-auth
wait_for_rollout
kubectl -n "$NS" port-forward "svc/${RELEASE}-canopy" 14000:4000 >/dev/null 2>&1 &
PF=$!
trap 'kill "$PF" 2>/dev/null || true' EXIT
python3 - "$NS" <<'PYTHON'
import base64
import http.cookiejar
import json
import subprocess
import sys
import time
import urllib.request
password = base64.b64decode(subprocess.check_output([
    "kubectl", "-n", sys.argv[1], "get", "secret", "canopy-existing-auth",
    "-o", "jsonpath={.data.password}"])).decode()
client = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
for attempt in range(30):
    try:
        client.open("http://127.0.0.1:14000/healthz", timeout=2).close()
        break
    except OSError:
        if attempt == 29:
            raise
        time.sleep(1)
req = urllib.request.Request("http://127.0.0.1:14000/auth/login",
    data=json.dumps({"username": "admin", "password": password}).encode(),
    headers={"Content-Type": "application/json"})
with client.open(req, timeout=10) as response:
    assert json.load(response)["role"] == "admin"
with client.open("http://127.0.0.1:14000/api/meta", timeout=10) as response:
    meta = json.load(response)
    assert meta["auth"]["backend"] == "local", meta
with client.open("http://127.0.0.1:14000/api/v1/group/schema/lists", timeout=10) as response:
    assert response.status == 200
print("ok - local authentication with existingSecret and SSO-capable image")
PYTHON
