# Terraform-Managed ELK Observability Platform

<p align="center">
  <img src="https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform&logoColor=white" />
  <img src="https://img.shields.io/badge/Containers-Docker-2496ED?logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/Observability-ELK-005571?logo=elastic&logoColor=white" />
  <img src="https://img.shields.io/badge/CI-GitHub_Actions-2088FF?logo=githubactions&logoColor=white" />
  <img src="https://img.shields.io/badge/Security-Checkov-green" />
</p>

## Overview

This project demonstrates the deployment and operation of a centralized observability platform using Terraform, Docker, Elasticsearch, Logstash, Kibana, Filebeat, and Metricbeat.

The platform is managed entirely through Infrastructure as Code (IaC) and incorporates configuration templating, automated validation, security scanning, health monitoring, operational runbooks, and CI/CD workflows commonly found in modern Platform Engineering, Site Reliability Engineering (SRE), and Infrastructure Engineering environments.

The objective of this project is to demonstrate how observability platforms can be provisioned, maintained, and operated using repeatable and automated engineering practices.

---

## Technical Skills Demonstrated

### Infrastructure as Code

* Terraform module design
* Terraform variables, outputs, and state management
* Environment-specific configuration rendering
* Automated infrastructure validation

### Platform Engineering

* Docker container lifecycle management
* Service dependency management
* Infrastructure automation
* Configuration management

### Observability

* Centralized log aggregation
* Log enrichment and parsing
* Infrastructure monitoring
* Application telemetry collection
* Search and analytics workflows

### Security and Compliance

* Sensitive variable handling
* Security-focused configuration management
* Automated infrastructure scanning with Checkov
* Static analysis using TFLint

### Operations

* Health monitoring
* Operational runbooks
* Troubleshooting procedures
* Infrastructure documentation

---

## Architecture

<p align="center">
  <img src="docs/architecture.png" width="900" alt="Architecture Diagram">
</p>

### Platform Components

| Component      | Purpose                                                 |
| -------------- | ------------------------------------------------------- |
| Terraform      | Infrastructure provisioning and configuration rendering |
| Docker         | Container runtime platform                              |
| Elasticsearch  | Log and metrics storage, indexing, and search           |
| Kibana         | Visualization and analytics                             |
| Logstash       | Log ingestion, parsing, and enrichment                  |
| Filebeat       | Log collection and forwarding                           |
| Metricbeat     | Infrastructure and container metrics                    |
| GitHub Actions | Continuous integration and validation                   |

---

## Deployment Workflow

1. Terraform renders environment-specific configuration files.
2. Terraform provisions Docker networks, volumes, images, and containers.
3. Filebeat collects Docker and host logs.
4. Logstash processes and enriches incoming log events.
5. Elasticsearch indexes logs and metrics.
6. Metricbeat collects host and container telemetry.
7. Kibana provides visualization, search, dashboards, and analysis.
8. GitHub Actions validates infrastructure changes through automated checks.

---

## Repository Structure

```text
.
├── .github/
│   └── workflows/
├── docs/
│   ├── architecture.*
│   ├── runbooks/
│   └── screenshots/
├── modules/
│   ├── config/
│   └── docker-elk/
├── scripts/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
└── README.md
```

---

## Deployment

### Prerequisites

* Terraform 1.6+
* Docker Engine
* Git

### Clone Repository

```bash
git clone https://github.com/dj-3dub/elk-lab-terraform.git
cd elk-lab-terraform
```

### Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Update:

* Elastic credentials
* Kibana encryption keys
* Domain name
* Environment settings

### Initialize Terraform

```bash
terraform init
```

### Validate Configuration

```bash
terraform fmt -recursive
terraform validate
```

### Review Deployment Plan

```bash
terraform plan
```

### Deploy Platform

```bash
terraform apply
```

---

## Accessing the Platform

Terraform outputs provide access URLs:

```bash
terraform output
```

Example:

```text
http://elk.lab:5601
https://elk.lab
```

---

## Continuous Integration

Infrastructure changes are automatically validated through GitHub Actions.

Validation pipeline:

* Terraform formatting checks
* Terraform validation
* TFLint static analysis
* Checkov security scanning

This process helps identify configuration issues before deployment.

---

## Security Considerations

The project incorporates several security-focused practices:

* Sensitive Terraform variables
* Environment-specific configuration rendering
* No production credentials stored in source control
* Automated infrastructure scanning
* Docker network isolation
* Kibana encryption key management

For production environments, API-based authentication and certificate management should be implemented.

---

## Demonstration Data

Sample log traffic can be generated using:

```bash
./scripts/generate-nginx-logs.sh
```

This allows testing of:

* Log ingestion
* Parsing
* Enrichment
* Dashboard creation
* Search workflows

---

## Screenshots

### Kibana Dashboard

![Kibana Dashboard](docs/screenshots/kibana-dashboard.png)

### Kibana Discover

![Kibana Discover](docs/screenshots/kibana-discover.png)

### Metricbeat Host Overview

![Metricbeat Host Overview](docs/screenshots/metricbeat-host-overview.png)

### Container Health Monitoring

![Container Health Monitoring](docs/screenshots/docker-healthy-containers.png)

---

## Operations Runbook

Operational procedures are documented in:

```text
docs/runbooks/troubleshooting.md
```

Documented scenarios include:

* Elasticsearch health validation
* Kibana troubleshooting
* Log ingestion failures
* Credential updates
* Platform rebuild procedures

---

## Cleanup

```bash
terraform destroy
```

---

## Engineering Considerations

This project was intentionally designed as a single-node observability platform to demonstrate infrastructure provisioning, centralized logging, monitoring, configuration management, and operational support workflows.

The architecture can be extended to support:

* Multi-node Elasticsearch clusters
* TLS certificate management
* API-key authentication
* Kubernetes-based deployments
* Snapshot and backup automation
* Alerting and incident response integrations

---

## License

This project is licensed under the terms of the LICENSE file included in this repository.

---

## Author

Timothy Heverin

Infrastructure Engineering | Platform Engineering | Observability | Automation | Terraform | Linux | Cloud

