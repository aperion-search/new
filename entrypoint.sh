#!/bin/bash
set -e

export DATA_DIR="${DATA_DIR:-/data}"
export DB_PATH="${DATA_DIR}/storage.sqlite"

# Ensure we are in the application root directory
cd /app

# 1. Restore state from Hugging Face on cold boot
python3 /app/sync.py restore || true

# 2. Background worker: periodic backup every 5 minutes
(
    while true; do
        sleep 300
        python3 /app/sync.py backup || true
    done
) &

# 3. Graceful shutdown handler
shutdown_handler() {
    echo "==> Shutdown signal received. Performing final sync..."
    python3 /app/sync.py backup || true
    exit 0
}

trap 'shutdown_handler' SIGTERM SIGINT

# 4. Start OmniRoute process
exec "$@"
