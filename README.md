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

`image.tag` is the required value for the chart.

You can set these required values via command line (e.g. `--set image.tag=0.8.0`), or edit them in a separate file(e.g. [`values.yaml`](chart/values.yaml))
and use `-f <filename>` or `--values=<filename>` to set it.

To install the chart with the release name `my-release`:

```shell
git clone https://github.com/apache/skywalking-banyandb-helm
cd ./skywalking-banyandb-helm
helm install my-release \
  chart \
  -n <namespace> \
  --set image.tag=<image-tag>
```

The command deploys BanyanDB on the Kubernetes cluster with the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```shell
$ helm uninstall my-release -n <namespace>
```

The command removes all the banyandb components associated with the chart and deletes the release.

## Compatibility

| Chart Version | Supported BanyanDB Version |
|---------------|----------------------------|
| 0.5.0         | 0.9.x                      |
| 0.4.0         | 0.8.x                      |
| 0.3.0         | 0.7.x                      |
| 0.4.0 or later| 0.8.0 or later             |

## Configuration

The `parameters` are described in [parameters.md](./doc/parameters.md).

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

**Note** You could refer to the [helm install](https://helm.sh/docs/helm/helm_install/) for more command information.

```console
$ helm install my-release \
  chart \
  -n <namespace> \
  --set image.tag=<image-tag> \
  --set fullnameOverride=newBanyanDB
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install my-release \
  chart \
  -n <namespace> \
  --set image.tag=<image-tag> \
  -f values.yaml
```

> **Tip**: You can use the default [values.yaml](chart/values.yaml)

## Use external certificate authorities for TLS
If you'd like to use external certificate authorities, such as Vault, corresponding annotations can be injected into [banyandb](./chart/templates/statefulset.yaml).

## Setup certificate for etcd TLS
To establish secure communication for etcd, you can leverage cert-manager to generate the necessary TLS certificates. This tool simplifies the process of creating and managing certificates. You can install cert-manager with the following command.
```console
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml
```

A Certificate can be created with the following configurations. In this setup, each dnsName includes a wildcard that enables resolution of all etcd pods' DNS names within the specified namespace, along with the service name of etcd and its corresponding namespace. Here, 'svc' represents a service, while 'cluster.local' serves as the domain suffix for the Kubernetes cluster.
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
  dnsNames:
    - "*.banyandb-etcd.banyandb.svc.cluster.local"
    - "*.banyandb-etcd-headless.banyandb.svc.cluster.local"
```

## Backup and Restore

The backup and restore functionalities are supported in the BanyanDB Helm Chart. The detailed configuration can be found in [backup.md](./doc/backup.md).

## Lifecycle Management

The lifecycle management functionalities are supported in the BanyanDB Helm Chart. The detailed configuration can be found in [lifecycle.md](./doc/lifecycle.md).

# Install the development version of BanyanDB using the master branch

This is needed **only** when you want to install [BanyanDB](https://github.com/apache/skywalking-banyandb/tree/main) from the master branch. 

You can install BanyanDB with the default configuration as follows.

```shell script
export REPO=chart
git clone https://github.com/apache/skywalking-banyandb-helm
cd skywalking-banyandb-helm
helm dependency build ${REPO}
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
