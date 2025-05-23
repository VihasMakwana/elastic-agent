{{- define "elasticagent.system.config.metrics.init" -}}
{{- if $.Values.system.metrics.enabled}}
{{- $preset := $.Values.agent.presets.perNode -}}
{{- $inputVal := (include "elasticagent.system.config.metrics.input" $ | fromYamlArray) -}}
{{- include "elasticagent.preset.mutate.inputs" (list $ $preset $inputVal) -}}
{{- include "elasticagent.preset.mutate.outputs.byname" (list $ $preset $.Values.system.output) -}}
{{- end -}}
{{- end -}}

{{- define "elasticagent.system.config.metrics.input" -}}
- id: system-metrics
  type: system/metrics
  use_output: {{ $.Values.system.output }}
  data_stream:
    namespace: {{ $.Values.system.namespace }}
  streams:
    - data_stream:
        dataset: system.cpu
        type: metrics
      period: 10s
      cpu.metrics:
        - percentages
        - normalized_percentages
      metricsets:
        - cpu
      system.hostfs: '/hostfs'
    - data_stream:
        dataset: system.diskio
        type: metrics
      period: 10s
      diskio.include_devices: null
      metricsets:
        - diskio
      system.hostfs: '/hostfs'
    - data_stream:
        dataset: system.filesystem
        type: metrics
      period: 1m
      metricsets:
        - filesystem
      system.hostfs: '/hostfs'
      processors:
        - drop_event.when.regexp:
            system.filesystem.mount_point: ^/(sys|cgroup|proc|dev|etc|host|lib|snap)($|/)
    - data_stream:
        dataset: system.fsstat
        type: metrics
      period: 1m
      metricsets:
        - fsstat
      system.hostfs: '/hostfs'
      processors:
        - drop_event.when.regexp:
            system.fsstat.mount_point: ^/(sys|cgroup|proc|dev|etc|host|lib|snap)($|/)
    - data_stream:
        dataset: system.load
        type: metrics
      condition: '${host.platform} != ''windows'''
      period: 10s
      metricsets:
        - load
    - data_stream:
        dataset: system.memory
        type: metrics
      period: 10s
      metricsets:
        - memory
      system.hostfs: '/hostfs'
    - data_stream:
        dataset: system.network
        type: metrics
      period: 10s
      network.interfaces: null
      metricsets:
        - network
    - data_stream:
        dataset: system.process
        type: metrics
      period: 10s
      processes:
        - .*
      process.include_top_n.by_cpu: 5
      process.include_top_n.by_memory: 5
      process.cmdline.cache.enabled: true
      process.cgroups.enabled: false
      process.include_cpu_ticks: false
      metricsets:
        - process
      system.hostfs: '/hostfs'
      process.include_cpu_ticks: false
    - data_stream:
        dataset: system.process_summary
        type: metrics
      period: 10s
      metricsets:
        - process_summary
      system.hostfs: '/hostfs'
    - data_stream:
        dataset: system.socket_summary
        type: metrics
      period: 10s
      metricsets:
        - socket_summary
      system.hostfs: '/hostfs'
    - data_stream:
        type: metrics
        dataset: system.uptime
      metricsets:
        - uptime
      period: 10s
{{- end -}}
