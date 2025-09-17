terraform {
  required_version = ">= 1.6.0"
  required_providers {
    docker = { source = "kreuzwerker/docker", version = "~> 3.0" }
    local  = { source = "hashicorp/local", version = "~> 2.5" }
    null   = { source = "hashicorp/null", version = "~> 3.2" }
  }
}

provider "docker" {
  host = var.docker_host # e.g., unix:///var/run/docker.sock
}
