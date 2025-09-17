<h1 align="center">ELK Lab on Docker with Terraform (.lab)</h1>
<p align="center">
  <img src="https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform&logoColor=white" />
  <img src="https://img.shields.io/badge/Containers-Docker-2496ED?logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/Stack-ELK-005571?logo=elastic&logoColor=white" />
  <img src="https://img.shields.io/badge/OS-Debian-A81D33?logo=debian&logoColor=white" />
</p>

<p align="center"><b>Single-node Elasticsearch + Kibana + Logstash + Beats</b> — reproducible with Terraform. Plays nice with k3s (no host 80/443).</p>

---

## ⚡ TL;DR
```bash
terraform init
terraform apply -var-file=envs/local.tfvars -var deploy_containers=false   # render configs
terraform apply -var-file=envs/local.tfvars -var deploy_containers=true    # start stack
# Kibana → http://<vm-ip>:5601  (user: elastic / password from tfvars)
```
---

## What this demonstrates
- 🏗️ IaC (Terraform): modular Docker network/images/containers
- 🔐 Secure defaults: ES auth on; Kibana encryption keys (persisted)
- 🔭 Observability: Filebeat & Metricbeat → Logstash → ES (geoip + user-agent)
- ☸️ Platform-aware: k3s-friendly (no host 80/443)
- 🧼 Ops hygiene: one-shot bootstrap; Git-safe layout
- 🗺️ Clarity: Graphviz diagram + Make targets

---

## 🔭 Architecture
<p align="center">
  <img src="docs/architecture.png" width="820" alt="Architecture diagram"/>
Build this image: `make diagram`
</p>

**Stack @ a glance**

| Component    | Purpose                               | Port(s) | Notes |
|---|---|---:|---|
| Elasticsearch | Data store + ingest                   | 9200    | Security on |
| Kibana       | UI + apps                              | 5601    | Mounted `kibana.yml` with encryption keys |
| Logstash     | Parse/enrich nginx access logs         | 5044    | Uses ingest pipeline (geoip + UA) |
| Filebeat     | Ship container & host logs → Logstash  | —       | Binds `/var/log`, docker logs |
| Metricbeat   | System & Docker metrics → ES           | —       | Docker socket read-only |
| Caddy        | Optional reverse proxy                 | —       | No host 80/443 by default |

Generate diagram:
```bash
make install-graphviz
make diagram
```

---

## 🧩 Features
- Terraform modules for Docker network, images, containers
- Secure defaults: Kibana **persistent** encryption keys
- Ingest pipeline with **geoip** + **user-agent** enrich
- k3s-friendly (no host 80/443 binding)
- Git-safe layout: no secrets/state committed

---

## 📂 Layout (minimal)
```
modules/{config, docker-elk}/
envs/                # local.tfvars (ignored)
rendered/            # generated configs (ignored)
docs/architecture.dot
```

---

## 🚀 Quickstart (vars)
```bash
mkdir -p envs
cat > envs/local.tfvars <<'VARS'
project_name = "elk-lab"
domain       = "elk.lab"
docker_host  = "unix:///var/run/docker.sock"
stack_version = "8.15.0"
es_java_opts  = "-Xms2g -Xmx2g"

elastic_password        = "ChangeMe_Elastic"
kibana_system_password  = "ChangeMe_Kibana"

# Kibana encryption keys (persist!)
kibana_security_encryption_key  = "GENERATE_ME"
kibana_eso_encryption_key       = "GENERATE_ME"
kibana_reporting_encryption_key = "GENERATE_ME"
VARS
```

---

## 🧰 Make targets
```bash
make diagram         # build docs/architecture.{png,svg}
make tf-fmt          # terraform fmt -recursive
make tf-validate     # fmt + terraform validate
```

```bash
# tip: generate 32-byte hex keys for Kibana encryption keys
openssl rand -hex 32
```

---

## 🩺 Quick fixes
- Kibana “not ready” → reset `elastic` & `kibana_system` in ES, restart Kibana.
- vm.max_map_count → `echo 'vm.max_map_count=262144' | sudo tee /etc/sysctl.d/99-elastic.conf && sudo sysctl --system`
- Changed passwords → update `envs/local.tfvars`, re-render (deploy_containers=false), restart Logstash/Metricbeat.

---

## 🔐 Note
Lab stack; don’t expose 5601/9200 publicly. Prefer API keys for Beats/Logstash in prod.

## Cleanup
```bash
terraform destroy -var-file=envs/local.tfvars
