# ELK Lab Troubleshooting Runbook

## 1. Verify containers are running

```bash
docker ps
```

Expected result:

- Elasticsearch is running and healthy

- Kibana is running and healthy

- Logstash is running and healthy

## 2. Check container logs

```
docker logs elasticsearch --tail=100
docker logs kibana --tail=100
docker logs logstash --tail=100
```

## 3. Verify Elasticsearch health

```
curl http://localhost:9200/_cluster/health
```

Expected result:

```
{
  "status": "green"
}
```

`yellow` can be acceptable for a single-node lab.

## 4. Verify Kibana

```
curl http://localhost:5601/api/status
```

Then open:

```
http://localhost:5601
```

## 5. Verify Logstash pipeline

```
curl http://localhost:9600/_node/pipelines
```

## 6. Common issues

### Kibana is not ready

Check Elasticsearch first:

```
docker logs elasticsearch --tail=100
```

Then restart Kibana:

```
docker restart kibana
```

### Beats are not shipping logs

Check Filebeat or Metricbeat logs:

```
docker logs filebeat --tail=100
docker logs metricbeat --tail=100
```

### Passwords changed

Update your local `terraform.tfvars`, then re-render configs:

```
terraform apply -var="deploy_containers=false"
```

Restart affected containers:

```
docker restart kibana logstash metricbeat
```

## 7. Rebuild lab

```
terraform destroy
terraform apply
```
