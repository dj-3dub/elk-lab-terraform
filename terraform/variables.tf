variable "project_name" {
  type    = string
  default = "elk-lab"
}

variable "domain" {
  type    = string
  default = "elk.lab"
}

variable "docker_host" {
  type    = string
  default = "unix:///var/run/docker.sock"
}

variable "stack_version" {
  type    = string
  default = "8.15.0"
}

variable "elastic_password" {
  description = "Password for the built-in elastic superuser."
  type        = string
  sensitive   = true
}

variable "kibana_system_password" {
  description = "Password for the built-in kibana_system user."
  type        = string
  sensitive   = true
}

variable "es_java_opts" {
  type    = string
  default = "-Xms2g -Xmx2g"
}

variable "deploy_containers" {
  type    = bool
  default = false
}

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
