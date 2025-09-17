variable "project_name" {
  type = string
}

variable "stack_version" {
  type = string
}

variable "elastic_password" {
  type      = string
  sensitive = true
}

variable "kibana_system_password" {
  type      = string
  sensitive = true
}

variable "es_java_opts" {
  type = string
}

variable "filebeat_path" {
  type = string
}

variable "metricbeat_path" {
  type = string
}

variable "logstash_path" {
  type = string
}

variable "caddyfile_path" {
  type = string
}

# NEW: path to rendered kibana.yml
variable "kibana_config_path" {
  type = string
}
