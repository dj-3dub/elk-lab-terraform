module "config" {
  source                          = "./modules/config"
  project_name                    = var.project_name
  domain                          = var.domain
  stack_version                   = var.stack_version
  elastic_password                = var.elastic_password
  kibana_system_password          = var.kibana_system_password
  es_java_opts                    = var.es_java_opts
  kibana_security_encryption_key  = var.kibana_security_encryption_key
  kibana_eso_encryption_key       = var.kibana_eso_encryption_key
  kibana_reporting_encryption_key = var.kibana_reporting_encryption_key
}

module "docker_elk" {
  source = "./modules/docker-elk"
  count  = var.deploy_containers ? 1 : 0

  project_name           = var.project_name
  stack_version          = var.stack_version
  elastic_password       = var.elastic_password
  kibana_system_password = var.kibana_system_password
  es_java_opts           = var.es_java_opts

  filebeat_path      = module.config.filebeat_path
  metricbeat_path    = module.config.metricbeat_path
  logstash_path      = module.config.logstash_path
  caddyfile_path     = module.config.caddyfile_path
  kibana_config_path = module.config.kibana_config_path
}
