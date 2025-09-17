variable "project_name" {
  type = string
}

variable "domain" {
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

# NEW: Kibana encryption keys
variable "kibana_security_encryption_key" {
  type      = string
  sensitive = true
}

variable "kibana_eso_encryption_key" {
  type      = string
  sensitive = true
}

variable "kibana_reporting_encryption_key" {
  type      = string
  sensitive = true
}
