# Parameters for the Helm chart

The content of this document describes the parameters that can be configured in the Helm chart for SkyWalking BanyanDB. It's generated from the `values.yaml` file in the chart repository by [bitnami/readme-generator-for-helm](https://github.com/bitnami/readme-generator-for-helm)

## Parameters

### Common configuration

| Name               | Description                         | Value      |
| ------------------ | ----------------------------------- | ---------- |
| `fullnameOverride` | Override the full name of the chart | `""`       |
| `nameOverride`     | Override the name of the chart      | `banyandb` |

### Container image configuration

| Name               | Description                               | Value                                  |
| ------------------ | ----------------------------------------- | -------------------------------------- |
| `image.repository` | Docker repository for SkyWalking BanyanDB | `docker.io/apache/skywalking-banyandb` |
| `image.tag`        | Image tag/version (empty for latest)      | `""`                                   |
| `image.pullPolicy` | Image pull policy (e.g. IfNotPresent)     | `IfNotPresent`                         |

### Authentication configuration for BanyanDB

| Name                      | Description                                              | Value              |
| ------------------------- | -------------------------------------------------------- | ------------------ |
| `auth.enabled`            | Enable basic authentication (boolean)                    | `false`            |
| `auth.existingSecret`     | Use an existing Secret for credentials                   | `""`               |
| `auth.credentialsFileKey` | Key name in the Secret that stores the                   | `credentials.yaml` |
| `auth.users`              | List of users to configure when not using existingSecret | `[]`               |

### Configuration for standalone deployment

| Name                                            | Description                                             | Value          |
| ----------------------------------------------- | ------------------------------------------------------- | -------------- |
| `standalone.enabled`                            | Enable standalone mode (boolean)                        | `false`        |
| `standalone.podAnnotations`                     | Additional pod annotations                              | `{}`           |
| `standalone.securityContext`                    | Security context for the pod                            | `{}`           |
| `standalone.containerSecurityContext`           | Container-level security context                        | `{}`           |
| `standalone.tls`                                | TLS configuration for the standalone pod                | `{}`           |
| `standalone.volumePermissions.enabled`          | Enable volume permissions init container                | `false`        |
| `standalone.volumePermissions.chownUser`        | User ID to chown the mounted volumes                    | `1000`         |
| `standalone.volumePermissions.chownGroup`       | Group ID to chown the mounted volumes                   | `1000`         |
| `standalone.volumePermissions.image`            | Image for the volume permissions init container         | `busybox:1.36` |
| `standalone.env`                                | Environment variables for the pod                       | `[]`           |
| `standalone.priorityClassName`                  | Priority class name for the pod                         | `""`           |
| `standalone.podDisruptionBudget`                | Pod disruption budget configuration                     | `{}`           |
| `standalone.tolerations`                        | Tolerations for pod scheduling                          | `[]`           |
| `standalone.nodeSelector`                       | Node selector for pod scheduling                        | `[]`           |
| `standalone.affinity`                           | Affinity rules for pod scheduling                       | `{}`           |
| `standalone.resources`                          | Resource requests/limits for the pod                    | `{}`           |
| `standalone.grpcSvc.labels`                     | Labels for GRPC service                                 | `{}`           |
| `standalone.grpcSvc.annotations`                | Annotations for GRPC service                            | `{}`           |
| `standalone.grpcSvc.port`                       | Port number for GRPC service                            | `17912`        |
| `standalone.httpSvc.labels`                     | Labels for HTTP service                                 | `{}`           |
| `standalone.httpSvc.annotations`                | Annotations for HTTP service                            | `{}`           |
| `standalone.httpSvc.port`                       | Port number for HTTP service                            | `17913`        |
| `standalone.httpSvc.type`                       | Service type (e.g., LoadBalancer)                       | `LoadBalancer` |
| `standalone.httpSvc.externalIPs`                | External IP addresses for the service                   | `[]`           |
| `standalone.httpSvc.loadBalancerIP`             | Load balancer IP address                                | `nil`          |
| `standalone.httpSvc.loadBalancerSourceRanges`   | Allowed source ranges for the load balancer             | `[]`           |
| `standalone.ingress.enabled`                    | Enable ingress (boolean)                                | `false`        |
| `standalone.ingress.labels`                     | Labels for ingress                                      | `{}`           |
| `standalone.ingress.annotations`                | Annotations for ingress                                 | `{}`           |
| `standalone.ingress.rules`                      | Ingress routing rules                                   | `[]`           |
| `standalone.ingress.tls`                        | TLS configuration for ingress                           | `[]`           |
| `standalone.sidecar`                            | Sidecar container configurations                        | `[]`           |
| `standalone.livenessProbe.initialDelaySeconds`  | Initial delay for liveness probe                        | `20`           |
| `standalone.livenessProbe.periodSeconds`        | Probe period in seconds                                 | `30`           |
| `standalone.livenessProbe.timeoutSeconds`       | Probe timeout in seconds                                | `5`            |
| `standalone.livenessProbe.successThreshold`     | Number of successful probes                             | `1`            |
| `standalone.livenessProbe.failureThreshold`     | Number of failed probes                                 | `5`            |
| `standalone.readinessProbe.initialDelaySeconds` | Initial delay for readiness probe                       | `20`           |
| `standalone.readinessProbe.periodSeconds`       | Probe period for readiness probe                        | `30`           |
| `standalone.readinessProbe.timeoutSeconds`      | Timeout in seconds for readiness probe                  | `5`            |
| `standalone.readinessProbe.successThreshold`    | Number of successful readiness probes                   | `1`            |
| `standalone.readinessProbe.failureThreshold`    | Number of failed readiness probes before marked unready | `5`            |
| `standalone.startupProbe.initialDelaySeconds`   | Initial delay for startup probe                         | `0`            |
| `standalone.startupProbe.periodSeconds`         | Probe period for startup probe                          | `10`           |
| `standalone.startupProbe.timeoutSeconds`        | Timeout in seconds for startup probe                    | `5`            |
| `standalone.startupProbe.successThreshold`      | Number of successful startup probes                     | `1`            |
| `standalone.startupProbe.failureThreshold`      | Number of failed startup probes before timeout          | `60`           |

### Cluster mode configuration

| Name                    | Description                   | Value  |
| ----------------------- | ----------------------------- | ------ |
| `cluster.enabled`       | Enable cluster mode (boolean) | `true` |
| `cluster.etcdEndpoints` | List of etcd endpoints        | `[]`   |

### Configuration for liaison component

| Name                                                          | Description                                                 | Value           |
| ------------------------------------------------------------- | ----------------------------------------------------------- | --------------- |
| `cluster.liaison.replicas`                                    | Number of liaison replicas                                  | `2`             |
| `cluster.liaison.podAnnotations`                              | Pod annotations for liaison                                 | `{}`            |
| `cluster.liaison.securityContext`                             | Security context for liaison pods                           | `{}`            |
| `cluster.liaison.containerSecurityContext`                    | Container-level security context for liaison                | `{}`            |
| `cluster.liaison.volumePermissions.enabled`                   | Enable volume permissions init container for liaison        | `false`         |
| `cluster.liaison.volumePermissions.chownUser`                 | User ID to chown the mounted volumes for liaison            | `1000`          |
| `cluster.liaison.volumePermissions.chownGroup`                | Group ID to chown the mounted volumes for liaison           | `1000`          |
| `cluster.liaison.volumePermissions.image`                     | Image for the volume permissions init container for liaison | `busybox:1.36`  |
| `cluster.liaison.env`                                         | Environment variables for liaison pods                      | `[]`            |
| `cluster.liaison.priorityClassName`                           | Priority class name for liaison pods                        | `""`            |
| `cluster.liaison.updateStrategy.type`                         | Update strategy type for liaison pods                       | `RollingUpdate` |
| `cluster.liaison.updateStrategy.rollingUpdate.maxUnavailable` | Maximum unavailable pods during update                      | `1`             |
| `cluster.liaison.podManagementPolicy`                         | Pod management policy for liaison StatefulSet               | `Parallel`      |
| `cluster.liaison.podDisruptionBudget`                         | Pod disruption budget for liaison                           | `{}`            |
| `cluster.liaison.tolerations`                                 | Tolerations for liaison pods                                | `[]`            |
| `cluster.liaison.nodeSelector`                                | Node selector for liaison pods                              | `[]`            |
| `cluster.liaison.affinity`                                    | Affinity rules for liaison pods                             | `{}`            |
| `cluster.liaison.podAffinityPreset`                           | Pod affinity preset for liaison                             | `""`            |
| `cluster.liaison.podAntiAffinityPreset`                       | Pod anti-affinity preset for liaison                        | `soft`          |
| `cluster.liaison.resources.requests`                          | Resource requests for liaison pods                          | `[]`            |
| `cluster.liaison.resources.limits`                            | Resource limits for liaison pods                            | `[]`            |
| `cluster.liaison.grpcSvc.labels`                              | Labels for GRPC service for liaison                         | `{}`            |
| `cluster.liaison.grpcSvc.annotations`                         | Annotations for GRPC service for liaison                    | `{}`            |
| `cluster.liaison.grpcSvc.port`                                | Port number for GRPC service for liaison                    | `17912`         |
| `cluster.liaison.sidecar`                                     | Sidecar containers for liaison pods                         | `[]`            |
| `cluster.liaison.httpSvc.labels`                              | Labels for HTTP service for liaison                         | `{}`            |
| `cluster.liaison.httpSvc.annotations`                         | Annotations for HTTP service for liaison                    | `{}`            |
| `cluster.liaison.httpSvc.port`                                | Port number for HTTP service for liaison                    | `17913`         |
| `cluster.liaison.httpSvc.type`                                | Service type for HTTP service for liaison                   | `LoadBalancer`  |
| `cluster.liaison.httpSvc.externalIPs`                         | External IP addresses for liaison HTTP service              | `[]`            |
| `cluster.liaison.httpSvc.loadBalancerIP`                      | Load balancer IP for liaison HTTP service                   | `nil`           |
| `cluster.liaison.httpSvc.loadBalancerSourceRanges`            | Allowed source ranges for liaison HTTP service              | `[]`            |
| `cluster.liaison.ingress.enabled`                             | Enable ingress for liaison                                  | `false`         |
| `cluster.liaison.ingress.labels`                              | Labels for ingress of liaison                               | `{}`            |
| `cluster.liaison.ingress.annotations`                         | Annotations for ingress of liaison                          | `{}`            |
| `cluster.liaison.ingress.rules`                               | Ingress rules for liaison                                   | `[]`            |
| `cluster.liaison.ingress.tls`                                 | TLS configuration for liaison ingress                       | `[]`            |
| `cluster.liaison.livenessProbe.initialDelaySeconds`           | Initial delay for liaison liveness probe                    | `20`            |
| `cluster.liaison.livenessProbe.periodSeconds`                 | Probe period for liaison liveness probe                     | `30`            |
| `cluster.liaison.livenessProbe.timeoutSeconds`                | Timeout in seconds for liaison liveness probe               | `5`             |
| `cluster.liaison.livenessProbe.successThreshold`              | Success threshold for liaison liveness probe                | `1`             |
| `cluster.liaison.livenessProbe.failureThreshold`              | Failure threshold for liaison liveness probe                | `5`             |
| `cluster.liaison.readinessProbe.initialDelaySeconds`          | Initial delay for liaison readiness probe                   | `20`            |
| `cluster.liaison.readinessProbe.periodSeconds`                | Probe period for liaison readiness probe                    | `30`            |
| `cluster.liaison.readinessProbe.timeoutSeconds`               | Timeout in seconds for liaison readiness probe              | `5`             |
| `cluster.liaison.readinessProbe.successThreshold`             | Success threshold for liaison readiness probe               | `1`             |
| `cluster.liaison.readinessProbe.failureThreshold`             | Failure threshold for liaison readiness probe               | `5`             |
| `cluster.liaison.startupProbe.initialDelaySeconds`            | Initial delay for liaison startup probe                     | `0`             |
| `cluster.liaison.startupProbe.periodSeconds`                  | Probe period for liaison startup probe                      | `10`            |
| `cluster.liaison.startupProbe.timeoutSeconds`                 | Timeout in seconds for liaison startup probe                | `5`             |
| `cluster.liaison.startupProbe.successThreshold`               | Success threshold for liaison startup probe                 | `1`             |
| `cluster.liaison.startupProbe.failureThreshold`               | Failure threshold for liaison startup probe                 | `60`            |

### Configuration for data component

| Name                                                           | Description                                                                  | Value                                        |
| -------------------------------------------------------------- | ---------------------------------------------------------------------------- | -------------------------------------------- |
| `cluster.data.nodeTemplate.replicas`                           | Number of data replicas by default                                           | `2`                                          |
| `cluster.data.nodeTemplate.podAnnotations`                     | Pod annotations for data pods                                                | `{}`                                         |
| `cluster.data.nodeTemplate.securityContext`                    | Security context for data pods                                               | `{}`                                         |
| `cluster.data.nodeTemplate.containerSecurityContext`           | Container-level security context for data pods                               | `{}`                                         |
| `cluster.data.nodeTemplate.volumePermissions.enabled`          | Enable volume permissions init container for data pods                       | `false`                                      |
| `cluster.data.nodeTemplate.volumePermissions.chownUser`        | User ID to chown the mounted volumes for data pods                           | `1000`                                       |
| `cluster.data.nodeTemplate.volumePermissions.chownGroup`       | Group ID to chown the mounted volumes for data pods                          | `1000`                                       |
| `cluster.data.nodeTemplate.volumePermissions.image`            | Image for the volume permissions init container for data pods                | `busybox:1.36`                               |
| `cluster.data.nodeTemplate.env`                                | Environment variables for data pods                                          | `[]`                                         |
| `cluster.data.nodeTemplate.priorityClassName`                  | Priority class name for data pods                                            | `""`                                         |
| `cluster.data.nodeTemplate.podDisruptionBudget.maxUnavailable` | Maximum unavailable data pods                                                | `1`                                          |
| `cluster.data.nodeTemplate.tolerations`                        | Tolerations for data pods                                                    | `[]`                                         |
| `cluster.data.nodeTemplate.nodeSelector`                       | Node selector for data pods                                                  | `[]`                                         |
| `cluster.data.nodeTemplate.affinity`                           | Affinity rules for data pods                                                 | `{}`                                         |
| `cluster.data.nodeTemplate.podAffinityPreset`                  | Pod affinity preset for data pods                                            | `""`                                         |
| `cluster.data.nodeTemplate.podAntiAffinityPreset`              | Pod anti-affinity preset for data pods                                       | `soft`                                       |
| `cluster.data.nodeTemplate.resources.requests`                 | Resource requests for data pods                                              | `[]`                                         |
| `cluster.data.nodeTemplate.resources.limits`                   | Resource limits for data pods                                                | `[]`                                         |
| `cluster.data.nodeTemplate.grpcSvc.labels`                     | Labels for GRPC service for data pods                                        | `{}`                                         |
| `cluster.data.nodeTemplate.grpcSvc.annotations`                | Annotations for GRPC service for data pods                                   | `{}`                                         |
| `cluster.data.nodeTemplate.grpcSvc.port`                       | Port number for GRPC service for data pods                                   | `17912`                                      |
| `cluster.data.nodeTemplate.sidecar`                            | Sidecar containers for data pods                                             | `[]`                                         |
| `cluster.data.nodeTemplate.backupSidecar.enabled`              | Enable backup sidecar for data pods (boolean)                                | `false`                                      |
| `cluster.data.nodeTemplate.backupSidecar.dest`                 | Backup destination path for data pods                                        | `file:///tmp/backups/data-$(ORDINAL_NUMBER)` |
| `cluster.data.nodeTemplate.backupSidecar.timeStyle`            | Backup time style for data pods (e.g., daily)                                | `daily`                                      |
| `cluster.data.nodeTemplate.backupSidecar.schedule`             | Backup schedule for data pods (cron format)                                  | `@hourly`                                    |
| `cluster.data.nodeTemplate.backupSidecar.customFlags`          | Custom flags for backup sidecar (e.g., S3, Azure, GCS configuration)         | `[]`                                         |
| `cluster.data.nodeTemplate.backupSidecar.resources`            | Resources for backup sidecar for data pods                                   | `{}`                                         |
| `cluster.data.nodeTemplate.lifecycleSidecar.enabled`           | Enable lifecycle sidecar for data pods (boolean)                             | `false`                                      |
| `cluster.data.nodeTemplate.lifecycleSidecar.schedule`          | Schedule for lifecycle sidecar (cron format)                                 | `@hourly`                                    |
| `cluster.data.nodeTemplate.lifecycleSidecar.progressFile`      | Progress file path for lifecycle sidecar                                     | `""`                                         |
| `cluster.data.nodeTemplate.lifecycleSidecar.reportDir`         | Report directory path for lifecycle sidecar                                  | `""`                                         |
| `cluster.data.nodeTemplate.lifecycleSidecar.resources`         | Resources for lifecycle sidecar for data pods                                | `{}`                                         |
| `cluster.data.nodeTemplate.restoreInitContainer.enabled`       | Enable restore init container for data pods (boolean)                        | `false`                                      |
| `cluster.data.nodeTemplate.restoreInitContainer.customFlags`   | Custom flags for restore init container (e.g., S3, Azure, GCS configuration) | `[]`                                         |
| `cluster.data.nodeTemplate.restoreInitContainer.resources`     | Resources for restore init container for data pods                           | `{}`                                         |
| `cluster.data.nodeTemplate.livenessProbe.initialDelaySeconds`  | Initial delay for data liveness probe                                        | `20`                                         |
| `cluster.data.nodeTemplate.livenessProbe.periodSeconds`        | Probe period for data liveness probe                                         | `30`                                         |
| `cluster.data.nodeTemplate.livenessProbe.timeoutSeconds`       | Timeout in seconds for data liveness probe                                   | `5`                                          |
| `cluster.data.nodeTemplate.livenessProbe.successThreshold`     | Success threshold for data liveness probe                                    | `1`                                          |
| `cluster.data.nodeTemplate.livenessProbe.failureThreshold`     | Failure threshold for data liveness probe                                    | `5`                                          |
| `cluster.data.nodeTemplate.readinessProbe.initialDelaySeconds` | Initial delay for data readiness probe                                       | `20`                                         |
| `cluster.data.nodeTemplate.readinessProbe.periodSeconds`       | Probe period for data readiness probe                                        | `30`                                         |
| `cluster.data.nodeTemplate.readinessProbe.timeoutSeconds`      | Timeout in seconds for data readiness probe                                  | `5`                                          |
| `cluster.data.nodeTemplate.readinessProbe.successThreshold`    | Success threshold for data readiness probe                                   | `1`                                          |
| `cluster.data.nodeTemplate.readinessProbe.failureThreshold`    | Failure threshold for data readiness probe                                   | `5`                                          |
| `cluster.data.nodeTemplate.startupProbe.initialDelaySeconds`   | Initial delay for data startup probe                                         | `0`                                          |
| `cluster.data.nodeTemplate.startupProbe.periodSeconds`         | Probe period for data startup probe                                          | `10`                                         |
| `cluster.data.nodeTemplate.startupProbe.timeoutSeconds`        | Timeout in seconds for data startup probe                                    | `5`                                          |
| `cluster.data.nodeTemplate.startupProbe.successThreshold`      | Success threshold for data startup probe                                     | `1`                                          |
| `cluster.data.nodeTemplate.startupProbe.failureThreshold`      | Failure threshold for data startup probe                                     | `60`                                         |
| `cluster.data.roles`                                           | List of data roles (hot, warm, cold)                                         |                                              |
| `cluster.data.roles.hot`                                       | Hot data role                                                                | `{}`                                         |

### Configuration for UI component

| Name                                                                | Description                                     | Value           |
| ------------------------------------------------------------------- | ----------------------------------------------- | --------------- |
| `cluster.ui.type`                                                   | UI deployment type (None, Standalone, Embedded) | `Embedded`      |
| `cluster.ui.standalone.replicas`                                    | Number of UI replicas                           | `1`             |
| `cluster.ui.standalone.podAnnotations`                              | Pod annotations for UI                          | `{}`            |
| `cluster.ui.standalone.securityContext`                             | Security context for UI pods                    | `{}`            |
| `cluster.ui.standalone.env`                                         | Environment variables for UI pods               | `[]`            |
| `cluster.ui.standalone.priorityClassName`                           | Priority class name for UI pods                 | `""`            |
| `cluster.ui.standalone.updateStrategy.type`                         | Update strategy type for UI pods                | `RollingUpdate` |
| `cluster.ui.standalone.updateStrategy.rollingUpdate.maxUnavailable` | Maximum unavailable pods for UI update          | `1`             |
| `cluster.ui.standalone.updateStrategy.rollingUpdate.maxSurge`       | Maximum surge pods for UI update                | `1`             |
| `cluster.ui.standalone.podDisruptionBudget`                         | Pod disruption budget for UI                    | `{}`            |
| `cluster.ui.standalone.tolerations`                                 | Tolerations for UI pods                         | `[]`            |
| `cluster.ui.standalone.nodeSelector`                                | Node selector for UI pods                       | `[]`            |
| `cluster.ui.standalone.affinity`                                    | Affinity rules for UI pods                      | `{}`            |
| `cluster.ui.standalone.podAffinityPreset`                           | Pod affinity preset for UI                      | `""`            |
| `cluster.ui.standalone.podAntiAffinityPreset`                       | Pod anti-affinity preset for UI                 | `soft`          |
| `cluster.ui.standalone.resources.requests`                          | Resource requests for UI pods                   | `[]`            |
| `cluster.ui.standalone.resources.limits`                            | Resource limits for UI pods                     | `[]`            |
| `cluster.ui.standalone.httpSvc.labels`                              | Labels for UI HTTP service                      | `{}`            |
| `cluster.ui.standalone.httpSvc.annotations`                         | Annotations for UI HTTP service                 | `{}`            |
| `cluster.ui.standalone.httpSvc.port`                                | Port for UI HTTP service                        | `17913`         |
| `cluster.ui.standalone.httpSvc.type`                                | Service type for UI HTTP service                | `LoadBalancer`  |
| `cluster.ui.standalone.httpSvc.externalIPs`                         | External IPs for UI HTTP service                | `[]`            |
| `cluster.ui.standalone.httpSvc.loadBalancerIP`                      | Load balancer IP for UI HTTP service            | `nil`           |
| `cluster.ui.standalone.httpSvc.loadBalancerSourceRanges`            | Allowed source ranges for UI HTTP service       | `[]`            |
| `cluster.ui.standalone.ingress.enabled`                             | Enable ingress for UI                           | `false`         |
| `cluster.ui.standalone.ingress.labels`                              | Labels for UI ingress                           | `{}`            |
| `cluster.ui.standalone.ingress.annotations`                         | Annotations for UI ingress                      | `{}`            |
| `cluster.ui.standalone.ingress.rules`                               | Ingress rules for UI                            | `[]`            |
| `cluster.ui.standalone.ingress.tls`                                 | TLS configuration for UI ingress                | `[]`            |
| `cluster.ui.standalone.livenessProbe.initialDelaySeconds`           | Initial delay for UI liveness probe             | `20`            |
| `cluster.ui.standalone.livenessProbe.periodSeconds`                 | Probe period for UI liveness probe              | `30`            |
| `cluster.ui.standalone.livenessProbe.timeoutSeconds`                | Timeout in seconds for UI liveness probe        | `5`             |
| `cluster.ui.standalone.livenessProbe.successThreshold`              | Success threshold for UI liveness probe         | `1`             |
| `cluster.ui.standalone.livenessProbe.failureThreshold`              | Failure threshold for UI liveness probe         | `5`             |
| `cluster.ui.standalone.readinessProbe.initialDelaySeconds`          | Initial delay for UI readiness probe            | `20`            |
| `cluster.ui.standalone.readinessProbe.periodSeconds`                | Probe period for UI readiness probe             | `30`            |
| `cluster.ui.standalone.readinessProbe.timeoutSeconds`               | Timeout in seconds for UI readiness probe       | `5`             |
| `cluster.ui.standalone.readinessProbe.successThreshold`             | Success threshold for UI readiness probe        | `1`             |
| `cluster.ui.standalone.readinessProbe.failureThreshold`             | Failure threshold for UI readiness probe        | `5`             |
| `cluster.ui.standalone.startupProbe.initialDelaySeconds`            | Initial delay for UI startup probe              | `0`             |
| `cluster.ui.standalone.startupProbe.periodSeconds`                  | Probe period for UI startup probe               | `10`            |
| `cluster.ui.standalone.startupProbe.timeoutSeconds`                 | Timeout in seconds for UI startup probe         | `5`             |
| `cluster.ui.standalone.startupProbe.successThreshold`               | Success threshold for UI startup probe          | `1`             |
| `cluster.ui.standalone.startupProbe.failureThreshold`               | Failure threshold for UI startup probe          | `60`            |

### Configuration for FODC (First Occurrence Data Collection) Proxy component

| Name                                                            | Description                                                             | Value                                             |
| --------------------------------------------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------- |
| `cluster.fodcProxy.enabled`                                     | Enable FODC Proxy deployment (boolean)                                  | `true`                                            |
| `cluster.fodcProxy.replicas`                                    | Number of FODC Proxy replicas                                           | `1`                                               |
| `cluster.fodcProxy.podAnnotations`                              | Pod annotations for Proxy                                               | `{}`                                              |
| `cluster.fodcProxy.securityContext`                             | Security context for Proxy pods                                         | `{}`                                              |
| `cluster.fodcProxy.containerSecurityContext`                    | Container-level security context for Proxy                              | `{}`                                              |
| `cluster.fodcProxy.env`                                         | Environment variables for Proxy pods                                    | `[]`                                              |
| `cluster.fodcProxy.priorityClassName`                           | Priority class name for Proxy pods                                      | `""`                                              |
| `cluster.fodcProxy.updateStrategy.type`                         | Update strategy type for Proxy pods                                     | `RollingUpdate`                                   |
| `cluster.fodcProxy.updateStrategy.rollingUpdate.maxUnavailable` | Maximum unavailable pods during update                                  | `1`                                               |
| `cluster.fodcProxy.updateStrategy.rollingUpdate.maxSurge`       | Maximum surge pods during update                                        | `1`                                               |
| `cluster.fodcProxy.podDisruptionBudget`                         | Pod disruption budget for Proxy                                         | `{}`                                              |
| `cluster.fodcProxy.tolerations`                                 | Tolerations for Proxy pods                                              | `[]`                                              |
| `cluster.fodcProxy.nodeSelector`                                | Node selector for Proxy pods                                            | `[]`                                              |
| `cluster.fodcProxy.affinity`                                    | Affinity rules for Proxy pods                                           | `{}`                                              |
| `cluster.fodcProxy.podAffinityPreset`                           | Pod affinity preset for Proxy                                           | `""`                                              |
| `cluster.fodcProxy.podAntiAffinityPreset`                       | Pod anti-affinity preset for Proxy                                      | `soft`                                            |
| `cluster.fodcProxy.resources.requests`                          | Resource requests for Proxy pods                                        | `[]`                                              |
| `cluster.fodcProxy.resources.limits`                            | Resource limits for Proxy pods                                          | `[]`                                              |
| `cluster.fodcProxy.image.repository`                            | Docker repository for FODC Proxy                                        | `docker.io/apache/skywalking-banyandb-fodc-proxy` |
| `cluster.fodcProxy.image.tag`                                   | Image tag/version for FODC Proxy (empty for latest)                     | `""`                                              |
| `cluster.fodcProxy.image.pullPolicy`                            | Image pull policy for FODC Proxy                                        | `IfNotPresent`                                    |
| `cluster.fodcProxy.grpcSvc.labels`                              | Labels for Proxy gRPC service                                           | `{}`                                              |
| `cluster.fodcProxy.grpcSvc.annotations`                         | Annotations for Proxy gRPC service                                      | `{}`                                              |
| `cluster.fodcProxy.grpcSvc.port`                                | Port number for Proxy gRPC service (Agent connections)                  | `17904`                                           |
| `cluster.fodcProxy.httpSvc.labels`                              | Labels for Proxy HTTP service                                           | `{}`                                              |
| `cluster.fodcProxy.httpSvc.annotations`                         | Annotations for Proxy HTTP service                                      | `{}`                                              |
| `cluster.fodcProxy.httpSvc.port`                                | Port number for Proxy HTTP service                                      | `17905`                                           |
| `cluster.fodcProxy.httpSvc.type`                                | Service type for Proxy HTTP service (ClusterIP, LoadBalancer, NodePort) | `LoadBalancer`                                    |
| `cluster.fodcProxy.httpSvc.externalIPs`                         | External IP addresses for Proxy HTTP service                            | `[]`                                              |
| `cluster.fodcProxy.httpSvc.loadBalancerIP`                      | Load balancer IP for Proxy HTTP service                                 | `nil`                                             |
| `cluster.fodcProxy.httpSvc.loadBalancerSourceRanges`            | Allowed source ranges for Proxy HTTP service                            | `[]`                                              |
| `cluster.fodcProxy.ingress.enabled`                             | Enable ingress for Proxy                                                | `false`                                           |
| `cluster.fodcProxy.ingress.labels`                              | Labels for Proxy ingress                                                | `{}`                                              |
| `cluster.fodcProxy.ingress.annotations`                         | Annotations for Proxy ingress                                           | `{}`                                              |
| `cluster.fodcProxy.ingress.rules`                               | Ingress rules for Proxy                                                 | `[]`                                              |
| `cluster.fodcProxy.ingress.tls`                                 | TLS configuration for Proxy ingress                                     | `[]`                                              |
| `cluster.fodcProxy.config.agentHeartbeatTimeout`                | Timeout for considering agent offline                                   | `30s`                                             |
| `cluster.fodcProxy.config.agentCleanupTimeout`                  | Timeout for auto-unregistering offline agents                           | `5m`                                              |
| `cluster.fodcProxy.config.maxAgents`                            | Maximum number of agents allowed to register                            | `1000`                                            |
| `cluster.fodcProxy.config.grpcMaxMsgSize`                       | Maximum gRPC message size in bytes                                      | `4194304`                                         |
| `cluster.fodcProxy.config.httpReadTimeout`                      | HTTP read timeout                                                       | `10s`                                             |
| `cluster.fodcProxy.config.httpWriteTimeout`                     | HTTP write timeout                                                      | `10s`                                             |
| `cluster.fodcProxy.config.heartbeatInterval`                    | Default heartbeat interval for agents                                   | `10s`                                             |
| `cluster.fodcProxy.livenessProbe.initialDelaySeconds`           | Initial delay for Proxy liveness probe                                  | `10`                                              |
| `cluster.fodcProxy.livenessProbe.periodSeconds`                 | Probe period for Proxy liveness probe                                   | `30`                                              |
| `cluster.fodcProxy.livenessProbe.timeoutSeconds`                | Timeout in seconds for Proxy liveness probe                             | `5`                                               |
| `cluster.fodcProxy.livenessProbe.successThreshold`              | Success threshold for Proxy liveness probe                              | `1`                                               |
| `cluster.fodcProxy.livenessProbe.failureThreshold`              | Failure threshold for Proxy liveness probe                              | `5`                                               |
| `cluster.fodcProxy.readinessProbe.initialDelaySeconds`          | Initial delay for Proxy readiness probe                                 | `10`                                              |
| `cluster.fodcProxy.readinessProbe.periodSeconds`                | Probe period for Proxy readiness probe                                  | `30`                                              |
| `cluster.fodcProxy.readinessProbe.timeoutSeconds`               | Timeout in seconds for Proxy readiness probe                            | `5`                                               |
| `cluster.fodcProxy.readinessProbe.successThreshold`             | Success threshold for Proxy readiness probe                             | `1`                                               |
| `cluster.fodcProxy.readinessProbe.failureThreshold`             | Failure threshold for Proxy readiness probe                             | `5`                                               |
| `cluster.fodcProxy.startupProbe.initialDelaySeconds`            | Initial delay for Proxy startup probe                                   | `0`                                               |
| `cluster.fodcProxy.startupProbe.periodSeconds`                  | Probe period for Proxy startup probe                                    | `10`                                              |
| `cluster.fodcProxy.startupProbe.timeoutSeconds`                 | Timeout in seconds for Proxy startup probe                              | `5`                                               |
| `cluster.fodcProxy.startupProbe.successThreshold`               | Success threshold for Proxy startup probe                               | `1`                                               |
| `cluster.fodcProxy.startupProbe.failureThreshold`               | Failure threshold for Proxy startup probe                               | `60`                                              |

### Configuration for FODC (First Occurrence Data Collection) Agent sidecar

| Name                                                   | Description                                                                  | Value                                             |
| ------------------------------------------------------ | ---------------------------------------------------------------------------- | ------------------------------------------------- |
| `cluster.fodcAgent.enabled`                            | Enable FODC Agent sidecar (boolean)                                          | `true`                                            |
| `cluster.fodcAgent.image.repository`                   | Docker repository for FODC Agent                                             | `docker.io/apache/skywalking-banyandb-fodc-agent` |
| `cluster.fodcAgent.image.tag`                          | Image tag/version for FODC Agent (defaults to same as main image)            | `""`                                              |
| `cluster.fodcAgent.image.pullPolicy`                   | Image pull policy for FODC Agent                                             | `IfNotPresent`                                    |
| `cluster.fodcAgent.env`                                | Environment variables for Agent sidecar                                      | `[]`                                              |
| `cluster.fodcAgent.containerSecurityContext`           | Container-level security context for Agent                                   | `{}`                                              |
| `cluster.fodcAgent.resources.requests`                 | Resource requests for Agent                                                  | `[]`                                              |
| `cluster.fodcAgent.resources.limits`                   | Resource limits for Agent                                                    | `[]`                                              |
| `cluster.fodcAgent.grpcPort`                           | GRPC port for Agent sidecar (not used - agent connects outbound to proxy)    | `17914`                                           |
| `cluster.fodcAgent.httpPort`                           | HTTP port for Agent sidecar (prometheus-listen-addr flag)                    | `17915`                                           |
| `cluster.fodcAgent.config.scrapeInterval`              | Interval for scraping BanyanDB metrics (poll-metrics-interval flag)          | `15s`                                             |
| `cluster.fodcAgent.config.heartbeatInterval`           | Heartbeat interval to Proxy (heartbeat-interval flag)                        | `10s`                                             |
| `cluster.fodcAgent.config.ktmEnabled`                  | Enable Kernel Telemetry Module (affects max-metrics-memory-usage-percentage) | `true`                                            |
| `cluster.fodcAgent.livenessProbe.initialDelaySeconds`  | Initial delay for Agent liveness probe                                       | `90`                                              |
| `cluster.fodcAgent.livenessProbe.periodSeconds`        | Probe period for Agent liveness probe                                        | `30`                                              |
| `cluster.fodcAgent.livenessProbe.timeoutSeconds`       | Timeout in seconds for Agent liveness probe                                  | `5`                                               |
| `cluster.fodcAgent.livenessProbe.successThreshold`     | Success threshold for Agent liveness probe                                   | `1`                                               |
| `cluster.fodcAgent.livenessProbe.failureThreshold`     | Failure threshold for Agent liveness probe                                   | `5`                                               |
| `cluster.fodcAgent.readinessProbe.initialDelaySeconds` | Initial delay for Agent readiness probe                                      | `60`                                              |
| `cluster.fodcAgent.readinessProbe.periodSeconds`       | Probe period for Agent readiness probe                                       | `10`                                              |
| `cluster.fodcAgent.readinessProbe.timeoutSeconds`      | Timeout in seconds for Agent readiness probe                                 | `5`                                               |
| `cluster.fodcAgent.readinessProbe.successThreshold`    | Success threshold for Agent readiness probe                                  | `1`                                               |
| `cluster.fodcAgent.readinessProbe.failureThreshold`    | Failure threshold for Agent readiness probe                                  | `12`                                              |
| `cluster.fodcAgent.startupProbe.initialDelaySeconds`   | Initial delay for Agent startup probe                                        | `30`                                              |
| `cluster.fodcAgent.startupProbe.periodSeconds`         | Probe period for Agent startup probe                                         | `5`                                               |
| `cluster.fodcAgent.startupProbe.timeoutSeconds`        | Timeout in seconds for Agent startup probe                                   | `3`                                               |
| `cluster.fodcAgent.startupProbe.successThreshold`      | Success threshold for Agent startup probe                                    | `1`                                               |
| `cluster.fodcAgent.startupProbe.failureThreshold`      | Failure threshold for Agent startup probe                                    | `60`                                              |

### Storage configuration for persistent volumes

| Name                                                        | Description                                             | Value                                                |
| ----------------------------------------------------------- | ------------------------------------------------------- | ---------------------------------------------------- |
| `storage.data.enabled`                                      | Enable persistent storage for data nodes (boolean)      | `true`                                               |
| `storage.data.persistentVolumeClaims`                       | List of PVC configurations for data nodes               |                                                      |
| `storage.data.persistentVolumeClaims[0].mountTargets`       | Mount targets for the PVC                               | `["measure"]`                                        |
| `storage.data.persistentVolumeClaims[0].nodeRole`           | Node role this PVC is bound to (hot, warm, cold)        | `hot`                                                |
| `storage.data.persistentVolumeClaims[0].existingClaimName`  | Existing PVC name (if any)                              | `nil`                                                |
| `storage.data.persistentVolumeClaims[0].claimName`          | Name of the PVC                                         | `hot-measure-data`                                   |
| `storage.data.persistentVolumeClaims[0].size`               | Size of the PVC                                         | `50Gi`                                               |
| `storage.data.persistentVolumeClaims[0].accessModes`        | Access modes for the PVC                                | `["ReadWriteOnce"]`                                  |
| `storage.data.persistentVolumeClaims[0].storageClass`       | Storage class for the PVC                               | `nil`                                                |
| `storage.data.persistentVolumeClaims[0].volumeMode`         | Volume mode for the PVC                                 | `Filesystem`                                         |
| `storage.data.persistentVolumeClaims[1].mountTargets`       | Mount targets for the PVC                               | `["stream"]`                                         |
| `storage.data.persistentVolumeClaims[1].nodeRole`           | Node role this PVC is bound to                          | `hot`                                                |
| `storage.data.persistentVolumeClaims[1].existingClaimName`  | Existing PVC name (if any)                              | `nil`                                                |
| `storage.data.persistentVolumeClaims[1].claimName`          | Name of the PVC                                         | `hot-stream-data`                                    |
| `storage.data.persistentVolumeClaims[1].size`               | Size of the PVC                                         | `50Gi`                                               |
| `storage.data.persistentVolumeClaims[1].accessModes`        | Access modes for the PVC                                | `["ReadWriteOnce"]`                                  |
| `storage.data.persistentVolumeClaims[1].storageClass`       | Storage class for the PVC                               | `nil`                                                |
| `storage.data.persistentVolumeClaims[1].volumeMode`         | Volume mode for the PVC                                 | `Filesystem`                                         |
| `storage.data.persistentVolumeClaims[2].mountTargets`       | Mount targets for the PVC                               | `["property"]`                                       |
| `storage.data.persistentVolumeClaims[2].nodeRole`           | Node role this PVC is bound to                          | `hot`                                                |
| `storage.data.persistentVolumeClaims[2].existingClaimName`  | Existing PVC name (if any)                              | `nil`                                                |
| `storage.data.persistentVolumeClaims[2].claimName`          | Name of the PVC                                         | `hot-property-data`                                  |
| `storage.data.persistentVolumeClaims[2].size`               | Size of the PVC                                         | `5Gi`                                                |
| `storage.data.persistentVolumeClaims[2].accessModes`        | Access modes for the PVC                                | `["ReadWriteOnce"]`                                  |
| `storage.data.persistentVolumeClaims[2].storageClass`       | Storage class for the PVC                               | `nil`                                                |
| `storage.data.persistentVolumeClaims[2].volumeMode`         | Volume mode for the PVC                                 | `Filesystem`                                         |
| `storage.data.persistentVolumeClaims[3].mountTargets`       | Mount targets for the PVC                               | `["trace"]`                                          |
| `storage.data.persistentVolumeClaims[3].nodeRole`           | Node role this PVC is bound to                          | `hot`                                                |
| `storage.data.persistentVolumeClaims[3].existingClaimName`  | Existing PVC name (if any)                              | `nil`                                                |
| `storage.data.persistentVolumeClaims[3].claimName`          | Name of the PVC                                         | `hot-trace-data`                                     |
| `storage.data.persistentVolumeClaims[3].size`               | Size of the PVC                                         | `50Gi`                                               |
| `storage.data.persistentVolumeClaims[3].accessModes`        | Access modes for the PVC                                | `["ReadWriteOnce"]`                                  |
| `storage.data.persistentVolumeClaims[3].storageClass`       | Storage class for the PVC                               | `nil`                                                |
| `storage.data.persistentVolumeClaims[3].volumeMode`         | Volume mode for the PVC                                 | `Filesystem`                                         |
| `storage.liaison.enabled`                                   | Enable persistent storage for liaison nodes (boolean)   | `true`                                               |
| `storage.liaison.persistentVolumeClaims`                    | List of PVC configurations for liaison nodes            |                                                      |
| `storage.liaison.persistentVolumeClaims[0].mountTargets`    | Mount targets for the PVC                               | `["measure","stream","trace"]`                       |
| `storage.liaison.persistentVolumeClaims[0].claimName`       | Name of the PVC                                         | `liaison-data`                                       |
| `storage.liaison.persistentVolumeClaims[0].size`            | Size of the PVC                                         | `10Gi`                                               |
| `storage.liaison.persistentVolumeClaims[0].accessModes`     | Access modes for the PVC                                | `["ReadWriteOnce"]`                                  |
| `storage.liaison.persistentVolumeClaims[0].storageClass`    | Storage class for the PVC                               | `nil`                                                |
| `storage.liaison.persistentVolumeClaims[0].volumeMode`      | Volume mode for the PVC                                 | `Filesystem`                                         |
| `storage.standalone.enabled`                                | Enable persistent storage for standalone mode (boolean) | `false`                                              |
| `storage.standalone.persistentVolumeClaims`                 | List of PVC configurations for standalone               |                                                      |
| `storage.standalone.persistentVolumeClaims[0].mountTargets` | Mount targets for the PVC                               | `["measure","stream","metadata","property","trace"]` |
| `storage.standalone.persistentVolumeClaims[0].claimName`    | Name of the PVC                                         | `standalone-data`                                    |
| `storage.standalone.persistentVolumeClaims[0].size`         | Size of the PVC                                         | `200Gi`                                              |
| `storage.standalone.persistentVolumeClaims[0].accessModes`  | Access modes for the PVC                                | `["ReadWriteOnce"]`                                  |
| `storage.standalone.persistentVolumeClaims[0].storageClass` | Storage class for the PVC                               | `nil`                                                |
| `storage.standalone.persistentVolumeClaims[0].volumeMode`   | Volume mode for the PVC                                 | `Filesystem`                                         |

### Service account configuration

| Name                         | Description                         | Value  |
| ---------------------------- | ----------------------------------- | ------ |
| `serviceAccount.create`      | Create a service account (boolean)  | `true` |
| `serviceAccount.annotations` | Annotations for the service account | `{}`   |
| `serviceAccount.name`        | Name of the service account         | `""`   |

### Etcd configuration for cluster state management

| Name                    | Description                | Value                |
| ----------------------- | -------------------------- | -------------------- |
| `etcd.enabled`          | Enable etcd (boolean)      | `true`               |
| `etcd.replicaCount`     | Number of etcd replicas    | `1`                  |
| `etcd.image.repository` | Docker repository for etcd | `bitnamilegacy/etcd` |

### Authentication configuration for etcd


### RBAC configuration for etcd

| Name                                     | Description                            | Value      |
| ---------------------------------------- | -------------------------------------- | ---------- |
| `etcd.auth.rbac.create`                  | Create RBAC roles (boolean)            | `true`     |
| `etcd.auth.rbac.allowNoneAuthentication` | Allow unauthenticated access (boolean) | `false`    |
| `etcd.auth.rbac.rootPassword`            | Root user password                     | `banyandb` |

### Client TLS configuration

| Name                                    | Description                                                  | Value     |
| --------------------------------------- | ------------------------------------------------------------ | --------- |
| `etcd.auth.client.secureTransport`      | Enable TLS for client communication (boolean)                | `false`   |
| `etcd.auth.client.existingSecret`       | Existing secret containing TLS certs                         | `""`      |
| `etcd.auth.client.enableAuthentication` | Enable client authentication (boolean)                       | `false`   |
| `etcd.auth.client.certFilename`         | Client certificate filename                                  | `tls.crt` |
| `etcd.auth.client.certKeyFilename`      | Client certificate key filename                              | `tls.key` |
| `etcd.auth.client.caFilename`           | CA certificate filename for TLS                              | `""`      |
| `etcd.auth.token.enabled`               | Enables token authentication                                 | `true`    |
| `etcd.auth.token.type`                  | Authentication token type. Allowed values: 'simple' or 'jwt' | `simple`  |

### Liveness probe configuration for etcd

| Name                                     | Description                      | Value |
| ---------------------------------------- | -------------------------------- | ----- |
| `etcd.livenessProbe.initialDelaySeconds` | Initial delay for liveness probe | `10`  |

### Readiness probe configuration for etcd

| Name                                      | Description                                | Value       |
| ----------------------------------------- | ------------------------------------------ | ----------- |
| `etcd.readinessProbe.initialDelaySeconds` | Initial delay for readiness probe          | `10`        |
| `etcd.autoCompactionMode`                 | Auto-compaction mode (periodic, revision)  | `periodic`  |
| `etcd.autoCompactionRetention`            | Auto-compaction retention period           | `1`         |
| `etcd.defrag`                             | Configuration for defragmentation          |             |
| `etcd.defrag.enabled`                     | Enable defragmentation (boolean)           | `true`      |
| `etcd.defrag.cronjob`                     | Cron job configuration for defragmentation |             |
| `etcd.defrag.cronjob.schedule`            | Cron schedule for defragmentation          | `0 0 * * *` |
