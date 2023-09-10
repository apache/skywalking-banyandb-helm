Apache Skywalking BanyanDB Helm Chart

[Apache Skywalking BanyanDB](https://github.com/apache/skywalking-banyandb/tree/main) is an observability database aims to ingest, analyze and store Metrics, Tracing and Logging data.

## Introduction

This chart bootstraps an Apache Skywalking BanyanDB deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

 - Kubernetes 1.24.0+
 - Helm 3

## Installing the Chart

To install the chart with the release name `my-release`:

```shell
$ helm install my-release banyandb -n <namespace>
```

The command deploys BanyanDB on the Kubernetes cluster with the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```shell
$ helm uninstall my-release -n <namespace>
```

The command removes all the banyandb components associated with the chart and deletes the release.

## Configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fullnameOverride | string | `"banyandb"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| standalone.affinity | object | `{}` |  |
| standalone.env | list | `[]` |  |
| standalone.grpcSvc.annotations | object | `{}` |  |
| standalone.grpcSvc.labels | object | `{}` |  |
| standalone.grpcSvc.port | int | `17912` |  |
| standalone.httpSvc.annotations | object | `{}` |  |
| standalone.httpSvc.externalIPs | list | `[]` |  |
| standalone.httpSvc.labels | object | `{}` |  |
| standalone.httpSvc.loadBalancerIP | string | `nil` |  |
| standalone.httpSvc.loadBalancerSourceRanges | list | `[]` |  |
| standalone.httpSvc.port | int | `17913` |  |
| standalone.httpSvc.type | string | `"LoadBalancer"` |  |
| standalone.image.pullPolicy | string | `"IfNotPresent"` |  |
| standalone.image.repository | string | `"ghcr.io/apache/skywalking-banyandb"` |  |
| standalone.image.tag | string | `"eecd29e71bc07d07f22aea1496d80dc76a2b2f90"` |  |
| standalone.ingress.annotations | object | `{}` |  |
| standalone.ingress.enabled | bool | `false` |  |
| standalone.ingress.labels | object | `{}` |  |
| standalone.ingress.rules | list | `[]` |  |
| standalone.ingress.tls | list | `[]` |  |
| standalone.name | string | `"banyandb"` |  |
| standalone.nodeSelector | list | `[]` |  |
| standalone.podAnnotations.example | string | `"banyandb-foo"` |  |
| standalone.podDisruptionBudget | object | `{}` |  |
| standalone.priorityClassName | string | `""` |  |
| standalone.resources.limits | list | `[]` |  |
| standalone.resources.requests | list | `[]` |  |
| standalone.securityContext | object | `{}` |  |
| standalone.tls.grpcSecretName | string | `""` |  |
| standalone.tls.httpSecretName | string | `""` |  |
| standalone.tolerations | list | `[]` |  |
| storage.enabled | bool | `false` |  |
| storage.persistentVolumeClaims[0].accessModes[0] | string | `"ReadWriteOnce"` |  |
| storage.persistentVolumeClaims[0].claimName | string | `"data"` |  |
| storage.persistentVolumeClaims[0].existingClaimName | string | `nil` |  |
| storage.persistentVolumeClaims[0].mountTargets[0] | string | `"measure"` |  |
| storage.persistentVolumeClaims[0].mountTargets[1] | string | `"stream"` |  |
| storage.persistentVolumeClaims[0].size | string | `"200Gi"` |  |
| storage.persistentVolumeClaims[0].storageClass | string | `nil` |  |
| storage.persistentVolumeClaims[0].volumeMode | string | `"Filesystem"` |  |
| storage.persistentVolumeClaims[1].accessModes[0] | string | `"ReadWriteOnce"` |  |
| storage.persistentVolumeClaims[1].claimName | string | `"meta"` |  |
| storage.persistentVolumeClaims[1].existingClaimName | string | `nil` |  |
| storage.persistentVolumeClaims[1].mountTargets[0] | string | `"metadata"` |  |
| storage.persistentVolumeClaims[1].size | string | `"10Gi"` |  |
| storage.persistentVolumeClaims[1].storageClass | string | `nil` |  |
| storage.persistentVolumeClaims[1].volumeMode | string | `"Filesystem"` |  |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

**Note** You could refer to the [helm install](https://helm.sh/docs/helm/helm_install/) for more command information.

```console
$ helm install myrelease banyandb --set fullnameOverride=newBanyanDB
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install my-release banyandb -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)