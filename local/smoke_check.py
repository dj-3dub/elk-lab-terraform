#!/usr/bin/env python3

import json
import shutil
import socket
import subprocess
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

PROJECT = "elk-lab"

CONTAINERS = [
    "elk-lab-es01",
    "elk-lab-kibana",
    "elk-lab-logstash",
    "elk-lab-filebeat",
    "elk-lab-metricbeat",
    "elk-lab-caddy",
]


def run(cmd):
    return subprocess.run(cmd, text=True, capture_output=True)


def check_cmd(name):
    if shutil.which(name):
        print(f"[PASS] command found: {name}")
        return True
    print(f"[WARN] command not found: {name}")
    return False


def check_terraform():
    result = run(["terraform", "validate"])
    if result.returncode == 0:
        print("[PASS] terraform validate")
        return True

    print("[FAIL] terraform validate")
    print(result.stdout)
    print(result.stderr)
    return False


def check_containers():
    ok = True
    result = run(["docker", "ps", "--format", "{{.Names}}"])
    running = set(result.stdout.splitlines())

    for container in CONTAINERS:
        if container in running:
            print(f"[PASS] container running: {container}")
        else:
            print(f"[FAIL] container not running: {container}")
            ok = False

    return ok


def check_url(name, url):
    try:
        req = Request(url, headers={"User-Agent": "elk-lab-smoke-check"})
        with urlopen(req, timeout=8) as response:
            code = response.status
            print(f"[PASS] {name}: HTTP {code}")
            return True
    except HTTPError as exc:
        if exc.code in {401, 403}:
            print(f"[PASS] {name}: HTTP {exc.code} authentication required")
            return True
        print(f"[FAIL] {name}: HTTP {exc.code}")
        return False
    except (URLError, TimeoutError, ConnectionResetError, socket.timeout) as exc:
        print(f"[FAIL] {name}: {exc}")
        return False

def check_elasticsearch_health():
    try:
        req = Request(
            "http://localhost:9200/_cluster/health",
            headers={"User-Agent": "elk-lab-smoke-check"},
        )
        with urlopen(req, timeout=8) as response:
            data = json.loads(response.read().decode("utf-8"))
            status = data.get("status")

            if status in {"green", "yellow"}:
                print(f"[PASS] Elasticsearch health: {status}")
                return True

            print(f"[FAIL] Elasticsearch health: {status}")
            return False
    except HTTPError as exc:
        if exc.code == 401:
            print("[PASS] Elasticsearch reachable: HTTP 401 authentication required")
            return True
        print(f"[FAIL] Elasticsearch health: HTTP {exc.code}")
        return False
    except Exception as exc:
        print(f"[FAIL] Elasticsearch health check failed: {exc}")
        return False

def main():
    print("ELK Lab Local Smoke Check")
    print("=" * 32)

    checks = []

    checks.append(check_cmd("terraform"))
    checks.append(check_cmd("docker"))

    if shutil.which("terraform"):
        checks.append(check_terraform())

    if shutil.which("docker"):
        checks.append(check_containers())

    checks.append(check_elasticsearch_health())
    checks.append(check_url("Kibana", "http://localhost:5601/api/status"))

    passed = sum(1 for check in checks if check)
    total = len(checks)

    print("=" * 32)
    print(f"Result: {passed}/{total} checks passed")

    if passed != total:
        sys.exit(1)


if __name__ == "__main__":
    main()
