Changes by Version
==================
Release Notes.

0.4.0
------------------

#### Features

- Support Backup Sidecar and Restore Init Container
- Leave the image tag empty to force the users to specify the image tag
- Add a default volume for "property"

0.3.0
------------------

#### Features

- Support Anti-Affinity for banyandb cluster mode
- Align the modern Kubernetes label names
- Opt probe settings to http get /healthz instead of bydbctl health check
- Add standalone UI deployment

#### Chores

- Bump banyandb image version to 0.7.0


0.2.0
------------------

#### Features

- Support banyandb cluster mode
- Add e2e test to CI

#### Chores

- Update relevant documents

#### Chores

- Bump banyandb image version to 0.6.0
- Bump several dependencies in e2e test

0.1.0
------------------

#### Features
- Deploy banyandb with standalone mode by Chart
