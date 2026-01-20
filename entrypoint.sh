#!/usr/bin/env bash
set -e

# Entrypoint script for Camoufox Docker container
# Starts Xvfb virtual display and launches the Camoufox server

echo "=========================================="
echo "Camoufox Container Starting"
echo "=========================================="

# Start X virtual framebuffer for headless display
# Even in headless mode, Firefox may need a display for some operations
echo "Starting Xvfb virtual display on :99..."
Xvfb :99 -screen 0 1920x1080x24 &
XVFB_PID=$!

# Wait for Xvfb to start
sleep 2

# Verify Xvfb is running
if ! kill -0 $XVFB_PID 2>/dev/null; then
    echo "ERROR: Xvfb failed to start"
    exit 1
fi

echo "Xvfb started successfully (PID: $XVFB_PID)"

# Set display environment variable
export DISPLAY=:99

# Handle graceful shutdown
cleanup() {
    echo "Shutting down..."
    if [ -n "$XVFB_PID" ]; then
        kill $XVFB_PID 2>/dev/null || true
    fi
    exit 0
}

trap cleanup SIGTERM SIGINT

# Launch the Camoufox server
# Using exec replaces this shell process with Python,
# ensuring signals are properly forwarded
echo "Launching Camoufox server..."
exec python3 /app/server.py
