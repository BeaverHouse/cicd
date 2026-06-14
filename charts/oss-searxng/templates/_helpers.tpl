{{- define "oss-searxng.labels" -}}
app.kubernetes.io/name: searxng
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "oss-searxng.selectorLabels" -}}
app: searxng
{{- end -}}
