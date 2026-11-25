{{/*
Expand the name of the chart.
*/}}
{{- define "backend-go.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "backend-go.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "backend-go.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "backend-go.labels" -}}
helm.sh/chart: {{ include "backend-go.chart" . }}
{{ include "backend-go.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "backend-go.selectorLabels" -}}
app.kubernetes.io/name: {{ include "backend-go.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Defaults an umbrella chart shares with every backend-go alias through global.backendGo.
Empty when the service sets inheritGlobal: false.
*/}}
{{- define "backend-go.globalDefaults" -}}
{{- if .Values.inheritGlobal }}
{{- toYaml (dig "backendGo" dict (.Values.global | default dict)) }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "backend-go.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "backend-go.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
