{{/*
Licensed to the Apache Software Foundation (ASF) under one or more
contributor license agreements.  See the NOTICE file distributed with
this work for additional information regarding copyright ownership.
The ASF licenses this file to You under the Apache License, Version 2.0
(the "License"); you may not use this file except in compliance with
the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "banyandb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "banyandb.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := (include "banyandb.name" .) -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "banyandb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "banyandb.labels" -}}
helm.sh/chart: {{ include "banyandb.chart" . }}
{{ include "banyandb.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "banyandb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "banyandb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "banyandb.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "banyandb.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
EtcdEndpoints
*/}}
{{- define "banyandb.etcdEndpoints" -}}
{{- $endpoints := list }}
{{- $replicaCount := int .Values.etcd.replicaCount }}
{{- $releaseName := .Release.Name }}
{{- $namespace := .Release.Namespace }}
{{- range $i := until $replicaCount }}
    {{- $endpoint := printf "%s-etcd-%d.%s-etcd-headless.%s:2379" $releaseName $i $releaseName $namespace }}
    {{- $endpoints = append $endpoints $endpoint }}
{{- end }}
- name: BYDB_ETCD_ENDPOINTS
  value: "{{- $endpoints | join "," -}}"
{{- end }}

{{- define "banyandb.hasDataNodeListValue" -}}
{{- $dataNodeList := include "banyandb.dataNodeListValue" . }}
{{- if ne $dataNodeList "" }}true{{- end }}
{{- end }}

{{/*
Generate data node names list for "hot" role only
*/}}
{{- define "banyandb.dataNodeListValue" -}}
{{- $dataNodes := list }}
{{- $fullname := include "banyandb.fullname" . }}
{{- $namespace := .Release.Namespace }}
{{- range $roleName, $roleConfig := .Values.cluster.data.roles }}
  {{- if eq $roleName "hot" }}
    {{- $replicas := $roleConfig.replicas | default $.Values.cluster.data.nodeTemplate.replicas }}
    {{- range $i := until (int $replicas) }}
      {{- $podName := printf "%s-data-%s-%d" $fullname $roleName $i }}
      {{- $fqdn := printf "%s.%s-data-%s-headless.%s" $podName $fullname $roleName $namespace }}
      {{- $dataNodes = append $dataNodes (printf "%s:17912" $fqdn) }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $dataNodes | join "," -}}
{{- end }}

{{/*
Generate DNS SRV address for a component
Format: _<port-name>._<proto>.<service-name>.<namespace>.svc.cluster.local
*/}}
{{- define "banyandb.dnsSrvAddress" -}}
{{- $component := .component }}
{{- $role := .role }}
{{- $fullname := include "banyandb.fullname" .root }}
{{- $namespace := .root.Release.Namespace }}
{{- $serviceName := "" }}
{{- $portName := "grpc" }}
{{- if eq $component "liaison" }}
  {{- $serviceName = printf "%s-liaison-headless" $fullname }}
  {{- $portName = "internal-grpc" }}
{{- else if eq $component "data" }}
  {{- $serviceName = printf "%s-data-%s-headless" $fullname $role }}
{{- end }}
{{- printf "_%s._tcp.%s.%s.svc.cluster.local" $portName $serviceName $namespace }}
{{- end }}

{{/*
Generate all DNS SRV addresses for node discovery
Returns comma-separated list of SRV addresses
*/}}
{{- define "banyandb.allDnsSrvAddresses" -}}
{{- $addresses := list }}
{{- /* Add liaison SRV address */}}
{{- $liaisonSrv := include "banyandb.dnsSrvAddress" (dict "root" . "component" "liaison") }}
{{- $addresses = append $addresses $liaisonSrv }}
{{- /* Add data node SRV addresses for each role */}}
{{- range $roleName, $roleConfig := .Values.cluster.data.roles }}
  {{- $dataSrv := include "banyandb.dnsSrvAddress" (dict "root" $ "component" "data" "role" $roleName) }}
  {{- $addresses = append $addresses $dataSrv }}
{{- end }}
{{- $addresses | join "," }}
{{- end }}

{{/*
Generate node discovery environment variables for a component
*/}}
{{- define "banyandb.nodeDiscoveryEnv" -}}
{{- $config := .root.Values.cluster.nodeDiscovery | default dict }}
{{- $mode := $config.mode | default "etcd" }}

- name: BYDB_NODE_DISCOVERY_MODE
  value: {{ $mode | quote }}

{{- if eq $mode "etcd" }}
{{- /* Etcd mode configuration */}}
{{- $etcdClient := index .root.Values "etcd-client" | default dict }}
{{- if $etcdClient.namespace }}
- name: BYDB_NAMESPACE
  value: {{ $etcdClient.namespace | quote }}
{{- end }}
{{- if $etcdClient.nodeDiscoveryTimeout }}
- name: BYDB_NODE_DISCOVERY_TIMEOUT
  value: {{ $etcdClient.nodeDiscoveryTimeout | quote }}
{{- end }}
{{- if $etcdClient.fullSyncInterval }}
- name: BYDB_ETCD_FULL_SYNC_INTERVAL
  value: {{ $etcdClient.fullSyncInterval | quote }}
{{- end }}

{{- else if eq $mode "dns" }}
{{- /* DNS mode configuration */}}
{{- /* Always auto-generate SRV addresses for all data nodes */}}
{{- $srvAddresses := include "banyandb.allDnsSrvAddresses" .root }}
{{- if $srvAddresses }}
- name: BYDB_NODE_DISCOVERY_DNS_SRV_ADDRESSES
  value: {{ $srvAddresses | quote }}
{{- end }}

{{- if $config.dns.fetchInitInterval }}
- name: BYDB_NODE_DISCOVERY_DNS_FETCH_INIT_INTERVAL
  value: {{ $config.dns.fetchInitInterval | quote }}
{{- end }}
{{- if $config.dns.fetchInitDuration }}
- name: BYDB_NODE_DISCOVERY_DNS_FETCH_INIT_DURATION
  value: {{ $config.dns.fetchInitDuration | quote }}
{{- end }}
{{- if $config.dns.fetchInterval }}
- name: BYDB_NODE_DISCOVERY_DNS_FETCH_INTERVAL
  value: {{ $config.dns.fetchInterval | quote }}
{{- end }}
{{- if $config.dns.grpcTimeout }}
- name: BYDB_NODE_DISCOVERY_GRPC_TIMEOUT
  value: {{ $config.dns.grpcTimeout | quote }}
{{- end }}

{{- /* Auto-generate TLS configuration based on existing gRPC TLS settings */}}
{{- $tlsEnabled := false }}
{{- $caCerts := list }}
{{- /* Check liaison TLS */}}
{{- if and .root.Values.cluster.liaison .root.Values.cluster.liaison.tls .root.Values.cluster.liaison.tls.grpcSecretName }}
  {{- $tlsEnabled = true }}
  {{- $caCerts = append $caCerts (printf "/etc/tls/%s/ca.crt" .root.Values.cluster.liaison.tls.grpcSecretName) }}
{{- end }}
{{- /* Check data nodes TLS for each role */}}
{{- range $roleName, $roleConfig := .root.Values.cluster.data.roles }}
  {{- if and $roleConfig.tls $roleConfig.tls.grpcSecretName }}
    {{- $tlsEnabled = true }}
    {{- $caCerts = append $caCerts (printf "/etc/tls/%s/ca.crt" $roleConfig.tls.grpcSecretName) }}
  {{- else if and $.root.Values.cluster.data.nodeTemplate.tls $.root.Values.cluster.data.nodeTemplate.tls.grpcSecretName }}
    {{- $tlsEnabled = true }}
    {{- $caCerts = append $caCerts (printf "/etc/tls/%s/ca.crt" $.root.Values.cluster.data.nodeTemplate.tls.grpcSecretName) }}
  {{- end }}
{{- end }}

{{- if $tlsEnabled }}
- name: BYDB_NODE_DISCOVERY_DNS_TLS
  value: "true"
{{- if $caCerts }}
- name: BYDB_NODE_DISCOVERY_DNS_CA_CERTS
  value: {{ $caCerts | join "," | quote }}
{{- end }}
{{- end }}
{{- else if eq $mode "file" }}
{{- $fileConfig := $config.file | default dict }}
- name: BYDB_NODE_DISCOVERY_FILE_PATH
  value: "/etc/banyandb/node-discovery/nodes.yaml"
{{- if $fileConfig.fetchInterval }}
- name: BYDB_NODE_DISCOVERY_FILE_FETCH_INTERVAL
  value: {{ $fileConfig.fetchInterval | quote }}
{{- end }}
{{- if $fileConfig.retryInitialInterval }}
- name: BYDB_NODE_DISCOVERY_FILE_RETRY_INITIAL_INTERVAL
  value: {{ $fileConfig.retryInitialInterval | quote }}
{{- end }}
{{- if $fileConfig.retryMaxInterval }}
- name: BYDB_NODE_DISCOVERY_FILE_RETRY_MAX_INTERVAL
  value: {{ $fileConfig.retryMaxInterval | quote }}
{{- end }}
{{- if $fileConfig.retryMultiplier }}
- name: BYDB_NODE_DISCOVERY_FILE_RETRY_MULTIPLIER
  value: {{ $fileConfig.retryMultiplier | quote }}
{{- end }}
{{- if $fileConfig.grpcTimeout }}
- name: BYDB_NODE_DISCOVERY_GRPC_TIMEOUT
  value: {{ $fileConfig.grpcTimeout | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Resolve ConfigMap name for file-based node discovery
*/}}
{{- define "banyandb.nodeDiscoveryFileConfigMapName" -}}
{{- $root := .root | default . }}
{{- $config := $root.Values.cluster.nodeDiscovery | default dict }}
{{- $mode := $config.mode | default "etcd" }}
{{- $file := $config.file | default dict }}
{{- $cm := $file.configMap | default dict }}
{{- if $cm.existingName }}
{{- $cm.existingName }}
{{- else if $cm.content }}
  {{- printf "%s-node-discovery" (include "banyandb.fullname" $root) }}
{{- else if eq $mode "file" }}
  {{- fail "cluster.nodeDiscovery.file.configMap.existingName or content must be set when cluster.nodeDiscovery.mode=file" }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Resolve discovery file data key
*/}}
{{- define "banyandb.nodeDiscoveryFileKey" -}}
{{- $root := .root | default . }}
{{- $nodeDiscovery := $root.Values.cluster.nodeDiscovery | default dict }}
{{- $file := $nodeDiscovery.file | default dict }}
{{- $cm := $file.configMap | default dict }}
{{- default "nodes.yaml" $cm.key }}
{{- end }}
