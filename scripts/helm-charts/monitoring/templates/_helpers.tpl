{{- define "monitoring.name" -}}
monitoring
{{- end }}

{{- define "monitoring.fullname" -}}
{{ .Release.Name }}
{{- end }}