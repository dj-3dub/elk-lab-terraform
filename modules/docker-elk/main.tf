# Network + data volume
resource "docker_network" "elk" {
  name = "${var.project_name}-net"
}

resource "docker_volume" "es_data" {
  name = "${var.project_name}-es-data"
}

# Images
resource "docker_image" "elasticsearch" {
  name         = "docker.elastic.co/elasticsearch/elasticsearch:${var.stack_version}"
  keep_locally = true
}

resource "docker_image" "kibana" {
  name         = "docker.elastic.co/kibana/kibana:${var.stack_version}"
  keep_locally = true
}

resource "docker_image" "logstash" {
  name         = "docker.elastic.co/logstash/logstash:${var.stack_version}"
  keep_locally = true
}

resource "docker_image" "filebeat" {
  name         = "docker.elastic.co/beats/filebeat:${var.stack_version}"
  keep_locally = true
}

resource "docker_image" "metricbeat" {
  name         = "docker.elastic.co/beats/metricbeat:${var.stack_version}"
  keep_locally = true
}

resource "docker_image" "caddy" {
  name         = "caddy:2.8"
  keep_locally = true
}

# Elasticsearch
resource "docker_container" "elasticsearch" {
  name  = "${var.project_name}-es01"
  image = docker_image.elasticsearch.image_id

  networks_advanced {
    name    = docker_network.elk.name
    aliases = ["elasticsearch"] # so Kibana/Beats can resolve http://elasticsearch:9200
  }

  env = [
    "discovery.type=single-node",
    "xpack.security.enabled=true",
    "ELASTIC_PASSWORD=${var.elastic_password}",
    "KIBANA_PASSWORD=${var.kibana_system_password}", # seeds kibana_system on first boot
    "ingest.geoip.downloader.enabled=false",
    "ES_JAVA_OPTS=${var.es_java_opts}"
  ]

  ulimit {
    name = "memlock"
    soft = -1
    hard = -1
  }

  mounts {
    target = "/usr/share/elasticsearch/data"
    type   = "volume"
    source = docker_volume.es_data.name
  }

  ports {
    internal = 9200
    external = 9200
  }

  restart = "unless-stopped"
}

# Kibana
resource "docker_container" "kibana" {
  name  = "${var.project_name}-kibana"
  image = docker_image.kibana.image_id

  networks_advanced {
    name = docker_network.elk.name
  }
  mounts {
    target    = "/usr/share/kibana/config/kibana.yml"
    type      = "bind"
    source    = var.kibana_config_path
    read_only = true
  }

  env = [
    "ELASTICSEARCH_HOSTS=[\"http://elasticsearch:9200\"]",
    "ELASTICSEARCH_USERNAME=kibana_system",
    "ELASTICSEARCH_PASSWORD=${var.kibana_system_password}",
    "SERVER_PUBLICBASEURL=http://elk.lab:5601"
  ]

  depends_on = [docker_container.elasticsearch]

  ports {
    internal = 5601
    external = 5601
  }

  restart = "unless-stopped"
}

# Logstash
resource "docker_container" "logstash" {
  name  = "${var.project_name}-logstash"
  image = docker_image.logstash.image_id

  networks_advanced {
    name = docker_network.elk.name
  }

  env = ["LS_JAVA_OPTS=-Xms1g -Xmx1g"]

  mounts {
    target = "/usr/share/logstash/pipeline"
    type   = "bind"
    source = var.logstash_path
  }

  ports {
    internal = 5044
    external = 5044
  }

  depends_on = [docker_container.elasticsearch]

  restart = "unless-stopped"
}

# Filebeat
resource "docker_container" "filebeat" {
  name  = "${var.project_name}-filebeat"
  image = docker_image.filebeat.image_id
  user  = "0:0"

  networks_advanced {
    name = docker_network.elk.name
  }

  mounts {
    target = "/usr/share/filebeat/filebeat.yml"
    type   = "bind"
    source = "${var.filebeat_path}/filebeat.yml"
  }

  mounts {
    target    = "/var/lib/docker/containers"
    type      = "bind"
    source    = "/var/lib/docker/containers"
    read_only = true
  }

  mounts {
    target    = "/var/run/docker.sock"
    type      = "bind"
    source    = "/var/run/docker.sock"
    read_only = true
  }

  mounts {
    target    = "/host/var/log"
    type      = "bind"
    source    = "/var/log"
    read_only = true
  }

  command = ["--strict.perms=false"]

  depends_on = [docker_container.logstash]

  restart = "unless-stopped"
}

# Metricbeat
resource "docker_container" "metricbeat" {
  name  = "${var.project_name}-metricbeat"
  image = docker_image.metricbeat.image_id
  user  = "0:0"

  networks_advanced {
    name = docker_network.elk.name
  }

  mounts {
    target = "/usr/share/metricbeat/metricbeat.yml"
    type   = "bind"
    source = "${var.metricbeat_path}/metricbeat.yml"
  }

  mounts {
    target    = "/var/run/docker.sock"
    type      = "bind"
    source    = "/var/run/docker.sock"
    read_only = true
  }

  mounts {
    target    = "/hostfs/sys/fs/cgroup"
    type      = "bind"
    source    = "/sys/fs/cgroup"
    read_only = true
  }

  mounts {
    target    = "/hostfs/proc"
    type      = "bind"
    source    = "/proc"
    read_only = true
  }

  mounts {
    target    = "/hostfs"
    type      = "bind"
    source    = "/"
    read_only = true
  }

  command = ["--strict.perms=false"]

  depends_on = [docker_container.elasticsearch, docker_container.kibana]

  restart = "unless-stopped"
}

# Caddy (NO host ports published — avoids conflict with k3s on 80/443)
resource "docker_container" "caddy" {
  name  = "${var.project_name}-caddy"
  image = docker_image.caddy.image_id

  networks_advanced {
    name = docker_network.elk.name
  }

  mounts {
    target = "/etc/caddy/Caddyfile"
    type   = "bind"
    source = var.caddyfile_path
  }

  # No ports{} here

  depends_on = [docker_container.kibana]
  restart    = "unless-stopped"
}
