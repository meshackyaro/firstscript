#!/bin/bash

# Configuration
SERVICE_NAME="app"                    # Service name in Docker Compose to scale
MIN_REPLICAS=1                        # Minimum number of replicas
MAX_REPLICAS=5                        # Maximum number of replicas
SCALE_UP_THRESHOLD=70                 # Scale up if CPU > 70%
SCALE_DOWN_THRESHOLD=30               # Scale down if CPU < 30%
PROMETHEUS_URL="http://localhost:9090" # Prometheus URL
CHECK_INTERVAL=30                     # Check interval in seconds
FIBONACCI_LOAD=true                  # Set to true to start generating load

# Function to get CPU usage from Prometheus
get_cpu_usage() {
  curl -s "${PROMETHEUS_URL}/api/v1/query" --data-urlencode \
    "query=avg(rate(container_cpu_usage_seconds_total{image!=\"\"}[1m])) * 100" | \
    jq -r '.data.result[0].value[1]' | awk '{print int($1)}'
}

# Function to scale service
scale_service() {
  local replicas=$1
  echo "Scaling $SERVICE_NAME to $replicas replicas..."
  docker-compose up --scale $SERVICE_NAME=$replicas -d
}

# Function to simulate CPU load by calling the Fibonacci endpoint
generate_fibonacci_load() {
  echo "Generating load on /fibonacci endpoint..."
  while $FIBONACCI_LOAD; do
    curl -s "http://localhost:8081/fibonacci?n=40" > /dev/null &
    sleep 0.5
  done
}

# Start load generation in the background
if $FIBONACCI_LOAD; then
  generate_fibonacci_load &
fi

# Main loop for auto-scaling
while true; do
  # Get current CPU usage
  CPU_USAGE=$(get_cpu_usage)
  if [[ -z "$CPU_USAGE" ]]; then
    echo "Error fetching CPU usage, skipping check..."
    sleep $CHECK_INTERVAL
    continue
  fi

  echo "Current CPU usage: ${CPU_USAGE}%"

  # Get current replicas count
  CURRENT_REPLICAS=$(docker-compose ps -q $SERVICE_NAME | wc -l)

  # Check if we need to scale up
  if [[ "$CPU_USAGE" -ge "$SCALE_UP_THRESHOLD" && "$CURRENT_REPLICAS" -lt "$MAX_REPLICAS" ]]; then
    NEW_REPLICAS=$((CURRENT_REPLICAS + 1))
    scale_service $NEW_REPLICAS

  # Check if we need to scale down
  elif [[ "$CPU_USAGE" -le "$SCALE_DOWN_THRESHOLD" && "$CURRENT_REPLICAS" -gt "$MIN_REPLICAS" ]]; then
    NEW_REPLICAS=$((CURRENT_REPLICAS - 1))
    scale_service $NEW_REPLICAS
  else
    echo "No scaling action required."
  fi

  # Wait for the next check
  sleep $CHECK_INTERVAL
done
