#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${1:-./demo-nginx-access.log}"

STATUS_CODES=(200 200 200 301 302 400 401 403 404 500 502)
PATHS=("/" "/login" "/dashboard" "/api/users" "/api/orders" "/admin" "/health" "/checkout")
METHODS=("GET" "POST" "PUT" "DELETE")
IPS=("192.168.1.10" "10.0.0.25" "172.16.4.8" "203.0.113.44" "198.51.100.12")

for i in {1..250}; do
  ip="${IPS[$RANDOM % ${#IPS[@]}]}"
  method="${METHODS[$RANDOM % ${#METHODS[@]}]}"
  path="${PATHS[$RANDOM % ${#PATHS[@]}]}"
  status="${STATUS_CODES[$RANDOM % ${#STATUS_CODES[@]}]}"
  bytes=$((RANDOM % 5000 + 200))

  echo "$ip - - [$(date '+%d/%b/%Y:%H:%M:%S %z')] \"$method $path HTTP/1.1\" $status $bytes \"-\" \"Mozilla/5.0\"" >> "$LOG_FILE"
done

echo "Generated demo logs at $LOG_FILE"
