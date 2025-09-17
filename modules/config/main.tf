locals {
  render_dir = abspath("${path.root}/rendered")
}

# Create all needed directories once
resource "null_resource" "mkdirs" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "mkdir -p '${local.render_dir}/logstash/pipelines.d' '${local.render_dir}/filebeat' '${local.render_dir}/metricbeat' '${local.render_dir}/ingest-pipelines' '${local.render_dir}/reverse-proxy' '${local.render_dir}/kibana'"
  }
}

# ----- Rendered files -----

# Logstash pipeline
resource "local_file" "logstash_pipeline" {
  depends_on = [null_resource.mkdirs]
  filename   = "${local.render_dir}/logstash/pipelines.d/nginx.conf"
  content = templatefile("${path.module}/templates/logstash/nginx.conf.tmpl", {
    elastic_password = var.elastic_password
  })
}

# Filebeat config
resource "local_file" "filebeat" {
  depends_on = [null_resource.mkdirs]
  filename   = "${local.render_dir}/filebeat/filebeat.yml"
  content    = file("${path.module}/templates/beats/filebeat.yml")
}

# Metricbeat config (inject password)
resource "local_file" "metricbeat" {
  depends_on = [null_resource.mkdirs]
  filename   = "${local.render_dir}/metricbeat/metricbeat.yml"
  content = replace(
    file("${path.module}/templates/beats/metricbeat.yml"),
    "REPLACE_WITH_ELASTIC_PASSWORD",
    var.elastic_password
  )
}

# Ingest pipeline JSON
resource "local_file" "ingest_pipeline" {
  depends_on = [null_resource.mkdirs]
  filename   = "${local.render_dir}/ingest-pipelines/access-geo-useragent.json"
  content    = file("${path.module}/templates/logstash/access-geo-useragent.json")
}

# Caddyfile
resource "local_file" "caddyfile" {
  depends_on = [null_resource.mkdirs]
  filename   = "${local.render_dir}/reverse-proxy/Caddyfile"
  content = templatefile("${path.module}/templates/reverse-proxy/Caddyfile.tmpl", {
    domain = var.domain
  })
}

# Kibana persistent config with encryption keys
resource "local_file" "kibana_yml" {
  depends_on = [null_resource.mkdirs]
  filename   = "${local.render_dir}/kibana/kibana.yml"
  content = templatefile("${path.module}/templates/kibana.yml.tmpl", {
    security_encryption_key  = var.kibana_security_encryption_key
    eso_encryption_key       = var.kibana_eso_encryption_key
    reporting_encryption_key = var.kibana_reporting_encryption_key
  })
}

# ----- Outputs for docker module -----
output "filebeat_path" { value = "${local.render_dir}/filebeat" }
output "metricbeat_path" { value = "${local.render_dir}/metricbeat" }
output "logstash_path" { value = "${local.render_dir}/logstash" }
output "caddyfile_path" { value = "${local.render_dir}/reverse-proxy/Caddyfile" }
output "kibana_config_path" { value = "${local.render_dir}/kibana/kibana.yml" }
