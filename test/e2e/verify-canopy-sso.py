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

"""Exercise real Canopy HTTP sessions against the isolated mock IdP."""
import http.cookiejar
import json
import time
import urllib.error
import urllib.parse
import urllib.request

BASE = "http://127.0.0.1:14000"
IDP = "http://127.0.0.1:18080"


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def browser():
    return urllib.request.build_opener(
        NoRedirect(), urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))


def request(client, path, payload=None):
    url = path if path.startswith("http") else BASE + path
    req = urllib.request.Request(url, data=None if payload is None else json.dumps(payload).encode(),
                                 headers={"Content-Type": "application/json"})
    try:
        response = client.open(req, timeout=10)
    except urllib.error.HTTPError as error:
        response = error
    with response:
        return response.code, response.headers, response.read()


def expect(status, result):
    assert result[0] == status, (status, result)
    return result


client = browser()
for attempt in range(60):
    try:
        expect(200, request(client, "/healthz"))
        expect(200, request(client, IDP + "/.well-known/openid-configuration"))
        break
    except (OSError, AssertionError):
        if attempt == 59:
            raise
        time.sleep(1)
meta = json.loads(expect(200, request(client, "/api/meta"))[2])["auth"]
assert meta["backend"] == "sso" and meta["ssoHealthy"] and meta["breakGlass"], meta
assert {p["id"]: p["type"] for p in meta["providers"]} == {"github": "oauth2", "google": "oidc"}, meta
password = {"username": "emergency", "password": "e2e-emergency-password"}
expect(401, request(client, "/auth/login", password))
print("ok - SSO metadata and password login disabled while providers are healthy")

for provider in ("github", "google"):
    for email, role in (("reader@example.test", "readonly"), ("admin@example.test", "admin")):
        client = browser()
        start = expect(302, request(client, f"/auth/sso/{provider}/start"))
        authorize = urllib.parse.urlsplit(start[1]["Location"])
        # The mock lives inside kind; rewrite only its origin for the test browser.
        query = authorize.query + "&" + urllib.parse.urlencode({"test_email": email})
        callback = expect(302, request(client, IDP + authorize.path + "?" + query))[1]["Location"]
        expect(302, request(client, callback))
        session = json.loads(expect(200, request(client, "/auth/session"))[2])
        assert session["role"] == role, session
        expect(200, request(client, "/api/v1/group/schema/lists"))
        # Readonly users cannot reach mutating upstream operations.
        if role == "readonly":
            expect(403, request(client, "/api/v1/group", {}))
        expect(200, request(client, "/auth/logout", {}))
        expect(401, request(client, "/auth/session"))
        print(f"ok - {provider} {role} login, authorization and logout")

expect(200, request(client, IDP + "/outage"))
for attempt in range(30):
    meta = json.loads(expect(200, request(client, "/api/meta"))[2])["auth"]
    if not meta["ssoHealthy"]:
        break
    time.sleep(1)
assert not meta["ssoHealthy"], meta
expect(401, request(client, "/auth/login", {**password, "password": "incorrect"}))
session = json.loads(expect(200, request(client, "/auth/login", password))[2])
assert session["role"] == "admin", session
expect(200, request(client, "/auth/session"))
print("ok - provider outage permits only valid break-glass credentials")
print("CANOPY SSO VERIFY PASS")
