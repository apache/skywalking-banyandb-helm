Apache SkyWalking BanyanDB Helm Chart
==========


![](https://github.com/apache/skywalking-banyandb-helm/workflows/Build/badge.svg?branch=master)

BanyanDB, as an observability database, aims to ingest, analyze, and store Metrics, Tracing, and Logging data.
It's designed to handle observability data generated by observability platforms and APM systems, like [Apache SkyWalking](https://github.com/apache/skywalking) etc.

BanyanDB Helm Chart repository provides ways to install and configure BanyanDB running in a cluster natively on Kubernetes. The scripts are written in Helm 3.

# Chart Detailed Configuration

## Introduction

This chart bootstraps an Apache Skywalking BanyanDB deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.
The released versions of the helm chart can be found on [Docker Hub](https://hub.docker.com/r/apache/skywalking-banyandb-helm).

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

> **Tip**: You can use the default [values.yaml](chart/values.yaml)

## Use external certificate authorities for TLS
If you'd like to use external certificate authorities, such as Vault, corresponding annotations can be injected into [banyandb](./chart/templates/statefulset.yaml).

## Setup certificate for etcd TLS
To establish secure communication for etcd, you can leverage cert-manager to generate the necessary TLS certificates. This tool simplifies the process of creating and managing certificates.

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: etcd-client
  namespace: banyandb
spec:
  secretName: etcd-client-tls
  duration: 17520h
  renewBefore: 4320h
  issuerRef:
    name: banyandb-issuer
    kind: Issuer
  usages:
    - server auth
    - client auth
  commonName: banyandb-etcd
  dnsNames:
    - "*.banyandb-etcd.default.svc.cluster.local"
    - "*.banyandb-etcd-headless.default.svc.cluster.local"
```

# Install the development version of BanyanDB using the master branch
This is needed **only** when you want to install [BanyanDB](https://github.com/apache/skywalking-banyandb/tree/main) from the master branch. 

You can install BanyanDB with the default configuration as follows.

```shell script
export REPO=chart
git clone https://github.com/apache/skywalking-banyandb-helm
cd skywalking-banyandb-helm
helm install banyandb ${REPO}
```

# Contact Us
* Submit an [issue](https://github.com/apache/skywalking/issues)
* Mail list: **dev@skywalking.apache.org**. Mail to `dev-subscribe@skywalking.apache.org`, follow the reply to subscribe the mail list.
* Send `Request to join SkyWalking slack` mail to the mail list(`dev@skywalking.apache.org`), we will invite you in.
* For Chinese speaker, send `[CN] Request to join SkyWalking slack` mail to the mail list(`dev@skywalking.apache.org`), we will invite you in.
* Twitter, [ASFSkyWalking](https://twitter.com/AsfSkyWalking)
* [bilibili B站 视频](https://space.bilibili.com/390683219)

# LICENSE
Apache 2.0
