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
      {{- $dataNodes = append $dataNodes $fqdn }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $dataNodes | join "," -}}
{{- end }}
