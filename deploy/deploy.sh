#!/usr/bin/env bash

set -euo pipefail

IMAGE="${IMAGE:?IMAGE is required}"
CONTAINER_NAME="github-devops"
PORT="8080"

echo "Deploying ${IMAGE}"

docker pull "${IMAGE}"

docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true

docker run -d \
  --name "${CONTAINER_NAME}" \
  --restart unless-stopped \
  -p "${PORT}:8080" \
  "${IMAGE}"

echo "Waiting for application..."

for i in {1..10}; do
    if curl -fsS "http://127.0.0.1:${PORT}/health" >/dev/null; then
        echo "Health check passed."
        echo "Deployment successful."
        exit 0
    fi

    echo "Health check failed, retrying... (${i}/10)"
    sleep 2
done

echo "Health check failed after 10 attempts."

docker logs "${CONTAINER_NAME}" || true
exit 1
