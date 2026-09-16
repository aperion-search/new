#!/bin/bash
set -e

export DATA_DIR="${DATA_DIR:-/data}"
export DB_PATH="${DATA_DIR}/storage.sqlite"

# 1. Restore state from Hugging Face on cold boot
python3 /sync.py restore

# 2. Background worker: periodic backup every 5 minutes
(
    while true; do
        sleep 300
        python3 /sync.py backup
    done
) &

# 3. Graceful shutdown handler
shutdown_handler() {
    echo "==> Shutdown signal received. Performing final sync..."
    python3 /sync.py backup
    exit 0
}

trap 'shutdown_handler' SIGTERM SIGINT

# 4. Start OmniRoute process in background and wait
exec "$@" &
child_pid=$!
wait "$child_pid"
