#!/bin/bash
set -e

export DATA_DIR="${DATA_DIR:-/data}"
export DB_PATH="${DATA_DIR}/storage.sqlite"
export PORT="${PORT:-3000}"

# 1. Restore database snapshot from HF on cold boot
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

# 4. Target application startup
if [ $# -gt 0 ]; then
    "$@" &
else
    # Execute Next.js standalone entrypoint directly
    if [ -f "/app/server.js" ]; then
        node /app/server.js &
    elif [ -f "server.js" ]; then
        node server.js &
    else
        npm run start &
    fi
fi

APP_PID=$!

# Keep entrypoint alive and wait on app process
wait "$APP_PID"
