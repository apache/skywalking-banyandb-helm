#!/usr/bin/env python3
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

"""Canopy auth chart contract checks; requires helm and Python PyYAML.

Run from any directory: python3 test/helm/test-canopy-auth.py
No cluster, provider credentials, or network access is needed.
"""

import copy
from pathlib import Path
import subprocess
import unittest

import yaml


CHART = Path(__file__).resolve().parents[2] / "chart"
CHECKSUM = "checksum/canopy-auth-config"
CONFIG = {
    "auth": {
        "backend": "sso",
        "sso": {
            "providers": [
                {
                    "id": "github",
                    "type": "oauth2",
                    "clientId": "public-client-id",
                    "clientSecretEnv": "CANOPY_GITHUB_CLIENT_SECRET",
                    "redirectUri": "https://canopy.example.com/auth/sso/github/callback",
                },
                {
                    "id": "google",
                    "type": "oidc",
                    "issuer": "https://accounts.google.com",
                    "clientId": "another-public-id",
                    "clientSecretEnv": "CANOPY_GOOGLE_CLIENT_SECRET",
                },
            ],
            "roles": {"defaultRoles": ["readonly"]},
        },
        "breakGlass": {"enabled": False, "users": []},
    }
}


def render(canopy, *, lifecycle=False, standalone=False, fullname="auth-test", error=None):
    values = {
        "image": {"tag": "render-test"},
        "fullnameOverride": fullname,
        "canopy": canopy,
    }
    if standalone:
        values.update({"standalone": {"enabled": True}, "cluster": {"enabled": False}})
    command = ["helm", "template", "auth-test", str(CHART)]
    if lifecycle:
        command += ["--values", str(CHART / "values-lifecycle.yaml")]
    command += ["--values", "-"]
    result = subprocess.run(
        command, input=yaml.safe_dump(values), text=True, capture_output=True, check=False
    )
    if error is not None:
        if result.returncode == 0 or error not in result.stderr:
            raise AssertionError(f"Expected rendering to fail with {error!r}: {result.stderr}")
        return None
    if result.returncode:
        raise AssertionError(result.stderr)
    return [resource for resource in yaml.safe_load_all(result.stdout) if resource]


def resource(resources, kind, name):
    return next(
        item for item in resources
        if item["kind"] == kind and item["metadata"]["name"] == name
    )


def pod(resources):
    return resource(resources, "Deployment", "auth-test-canopy")["spec"]["template"]


class CanopyAuthRenderTest(unittest.TestCase):
    def test_local_defaults_remain_unchanged(self):
        for lifecycle in (False, True):
            with self.subTest(lifecycle=lifecycle):
                resources = render({"enabled": True}, lifecycle=lifecycle)
                template = pod(resources)
                container = template["spec"]["containers"][0]
                names = [item["metadata"]["name"] for item in resources]
                self.assertNotIn("auth-test-canopy-auth-config", names)
                self.assertNotIn("envFrom", container)
                self.assertNotIn(CHECKSUM, template["metadata"].get("annotations", {}))
                env = {item["name"]: item for item in container["env"]}
                self.assertNotIn("CANOPY_AUTH_CONFIG", env)
                self.assertEqual(env["CANOPY_USERS"]["value"], "/etc/canopy/users.yaml")
                self.assertEqual(
                    env["SESSION_SECRET"]["valueFrom"]["secretKeyRef"]["name"],
                    "auth-test-canopy-auth",
                )
                secret = resource(resources, "Secret", "auth-test-canopy-auth")
                self.assertIn("users.yaml", secret["stringData"])

    def test_disabled_canopy_does_not_render_auth_resources(self):
        resources = render({"enabled": False, "auth": {"config": CONFIG}})
        self.assertFalse(any(
            item["metadata"].get("labels", {}).get("app.kubernetes.io/component") == "canopy"
            for item in resources
        ))

    def test_sso_uses_mounted_config_and_external_environment(self):
        for lifecycle in (False, True):
            for existing in ("", "existing-local-auth"):
                with self.subTest(lifecycle=lifecycle, existing=existing):
                    resources = render({
                        "enabled": True,
                        "auth": {"config": CONFIG, "existingSecret": existing},
                        "envFromSecret": "provider-credentials",
                    }, lifecycle=lifecycle)
                    secret = resource(resources, "Secret", "auth-test-canopy-auth-config")
                    self.assertEqual(yaml.safe_load(secret["stringData"]["auth.yaml"]), CONFIG)
                    # The complete document is preserved, including references to both
                    # providers; the external credential Secret is never generated.
                    self.assertFalse(any(
                        item["metadata"]["name"] == "provider-credentials" for item in resources
                    ))
                    spec = pod(resources)["spec"]
                    container = spec["containers"][0]
                    self.assertEqual(container["envFrom"], [{"secretRef": {"name": "provider-credentials"}}])
                    env = {item["name"]: item for item in container["env"]}
                    self.assertEqual(env["CANOPY_AUTH_CONFIG"]["value"], "/etc/canopy/config/auth.yaml")
                    self.assertEqual(
                        env["SESSION_SECRET"]["valueFrom"]["secretKeyRef"]["name"],
                        existing or "auth-test-canopy-auth",
                    )
                    mount = next(m for m in container["volumeMounts"] if m["mountPath"] == "/etc/canopy/config")
                    self.assertTrue(mount["readOnly"])
                    self.assertNotIn("subPath", mount)
                    volume = next(v for v in spec["volumes"] if v["name"] == mount["name"])
                    self.assertEqual(volume["secret"]["secretName"], "auth-test-canopy-auth-config")
                    if existing:
                        self.assertFalse(any(
                            item["metadata"]["name"] == "auth-test-canopy-auth" for item in resources
                        ))

    def test_checksum_tracks_config_and_preserves_annotations(self):
        values = {
            "enabled": True,
            "auth": {"config": copy.deepcopy(CONFIG)},
            "podAnnotations": {"example.com/owner": "canopy", CHECKSUM: "user-supplied"},
        }
        first = pod(render(values))["metadata"]["annotations"]
        second = pod(render(values))["metadata"]["annotations"]
        self.assertEqual(first["example.com/owner"], "canopy")
        self.assertRegex(first[CHECKSUM], r"^[0-9a-f]{64}$")
        self.assertEqual(first[CHECKSUM], second[CHECKSUM])
        values["auth"]["config"]["auth"]["breakGlass"]["enabled"] = True
        changed = pod(render(values))["metadata"]["annotations"]
        self.assertNotEqual(first[CHECKSUM], changed[CHECKSUM])

    def test_env_secret_can_be_used_without_auth_config(self):
        template = pod(render({"enabled": True, "envFromSecret": "upstream-credentials"}))
        self.assertEqual(template["spec"]["containers"][0]["envFrom"], [
            {"secretRef": {"name": "upstream-credentials"}}
        ])

    def test_config_is_not_evaluated_as_a_helm_template(self):
        config = copy.deepcopy(CONFIG)
        config["auth"]["sso"]["providers"][0]["clientId"] = "{{ .Release.Name }}"
        resources = render({"enabled": True, "auth": {"config": config}})
        secret = resource(resources, "Secret", "auth-test-canopy-auth-config")
        self.assertEqual(yaml.safe_load(secret["stringData"]["auth.yaml"]), config)

    def test_invalid_config_envelopes_are_rejected(self):
        for config in ("invalid", ["invalid"], {"backend": "sso"}, {"auth": "sso"}):
            with self.subTest(config=config):
                render({"enabled": True, "auth": {"config": config}}, error="top-level auth mapping")

    def test_inline_provider_credentials_are_rejected(self):
        config = copy.deepcopy(CONFIG)
        config["auth"]["sso"]["providers"][1]["clientSecret"] = "do-not-render"
        render({"enabled": True, "auth": {"config": config}}, error="use clientSecretEnv")

    def test_generated_config_secret_name_limit(self):
        # 45 + len('-canopy-auth-config') = 64, while existing workload names fit.
        render({"enabled": True, "auth": {"config": CONFIG}},
               standalone=True, fullname="a" * 45, error="Canopy auth config Secret name")
        resources = render({"enabled": True, "auth": {"config": CONFIG}},
                           standalone=True, fullname="a" * 44)
        self.assertIsNotNone(resource(resources, "Secret", "a" * 44 + "-canopy-auth-config"))


if __name__ == "__main__":
    unittest.main(verbosity=2)
