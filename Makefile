# ELK Observability Platform - Operational Makefile
# Use tabs, not spaces, for command indentation.

SHELL := /bin/bash

TF := terraform
TF_DIR := terraform
PROJECT := elk-lab

CONTAINERS := \
	$(PROJECT)-es01 \
	$(PROJECT)-kibana \
	$(PROJECT)-logstash \
	$(PROJECT)-filebeat \
	$(PROJECT)-metricbeat \
	$(PROJECT)-caddy

.PHONY: help \
	init fmt validate lint scan check \
	plan apply destroy up down restart \
	status logs health output docs clean

help:
	@echo "ELK Observability Platform Commands"
	@echo ""
	@echo "Terraform Workflow:"
	@echo "  make init        Initialize Terraform"
	@echo "  make fmt         Format Terraform files"
	@echo "  make validate    Validate Terraform configuration"
	@echo "  make plan        Show Terraform execution plan"
	@echo "  make apply       Deploy the ELK platform"
	@echo "  make destroy     Destroy the ELK platform"
	@echo ""
	@echo "Operational Commands:"
	@echo "  make up          Start/deploy the ELK platform"
	@echo "  make down        Stop/destroy the ELK platform"
	@echo "  make restart     Restart Terraform-managed containers"
	@echo "  make status      Show ELK container status"
	@echo "  make logs        Show recent container logs"
	@echo "  make health      Check Elasticsearch, Kibana, and container health"
	@echo "  make output      Show Terraform outputs"
	@echo ""
	@echo "Quality Checks:"
	@echo "  make lint        Run TFLint if installed"
	@echo "  make scan        Run Checkov if installed"
	@echo "  make check       Run fmt, validate, lint, and scan"
	@echo ""
	@echo "Documentation and Cleanup:"
	@echo "  make docs        Regenerate architecture diagrams if Graphviz is installed"
	@echo "  make clean       Remove rendered files and Terraform cache"

init:
	cd $(TF_DIR) && $(TF) init

fmt:
	cd $(TF_DIR) && $(TF) fmt -recursive

validate:
	cd $(TF_DIR) && $(TF) validate

lint:
	@if command -v tflint >/dev/null 2>&1; then \
		cd $(TF_DIR) && tflint --init && tflint --recursive; \
	else \
		echo "TFLint not installed. GitHub Actions will run it during CI."; \
	fi

scan:
	@if command -v checkov >/dev/null 2>&1; then \
		checkov -d $(TF_DIR) --framework terraform; \
	else \
		echo "Checkov not installed. GitHub Actions will run it during CI."; \
	fi

check: fmt validate lint scan

plan:
	cd $(TF_DIR) && $(TF) plan -var="deploy_containers=true"

apply:
	cd $(TF_DIR) && $(TF) apply -var="deploy_containers=true"

destroy:
	cd $(TF_DIR) && $(TF) destroy -var="deploy_containers=true"

up: apply

down: destroy

restart:
	@docker restart $(CONTAINERS)

status:
	@docker ps --filter "name=$(PROJECT)" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

logs:
	@for container in $(CONTAINERS); do \
		echo ""; \
		echo "===== $$container ====="; \
		docker logs $$container --tail=60 2>/dev/null || true; \
	done

health:
	@echo "Elasticsearch:"
	@curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:9200 || true
	@echo ""
	@echo "Kibana:"
	@curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:5601/api/status || true
	@echo ""
	@echo "Containers:"
	@docker ps --filter "name=$(PROJECT)" --format "table {{.Names}}\t{{.Status}}"

output:
	cd $(TF_DIR) && $(TF) output

docs:
	@if command -v dot >/dev/null 2>&1; then \
		dot -Tpng docs/architecture.dot -o docs/architecture.png; \
		dot -Tsvg docs/architecture.dot -o docs/architecture.svg; \
		echo "Architecture diagrams regenerated."; \
	else \
		echo "Graphviz not installed. Install graphviz to regenerate architecture diagrams."; \
	fi

clean:
	rm -rf $(TF_DIR)/.terraform
	rm -rf $(TF_DIR)/rendered
	rm -f $(TF_DIR)/.terraform.lock.hcl.backup
