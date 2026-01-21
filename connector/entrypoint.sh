#!/usr/bin/env bash
#
# Camoufox Connector Entrypoint
#
# Starts Xvfb virtual display and launches camoufox-connector server.

set -e

echo "========================================"
echo "Camoufox Connector Starting..."
echo "========================================"

# Start D-Bus if available
if command -v dbus-daemon &> /dev/null; then
    echo "Starting D-Bus daemon..."
    mkdir -p /var/run/dbus
    dbus-daemon --system --fork 2>/dev/null || true
fi

# Start Xvfb virtual display
echo "Starting Xvfb virtual display on ${DISPLAY}..."
Xvfb ${DISPLAY} -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &
XVFB_PID=$!

# Wait for Xvfb to start
sleep 2

# Verify Xvfb is running
if ! kill -0 $XVFB_PID 2>/dev/null; then
    echo "ERROR: Xvfb failed to start"
    exit 1
fi
echo "Xvfb started successfully (PID: $XVFB_PID)"

# Build camoufox-connector command arguments
CMD_ARGS=""

# Mode configuration
if [ -n "$CAMOUFOX_MODE" ]; then
    CMD_ARGS="$CMD_ARGS --mode $CAMOUFOX_MODE"
fi

# Pool size (only relevant in pool mode)
if [ "$CAMOUFOX_MODE" = "pool" ] && [ -n "$CAMOUFOX_POOL_SIZE" ]; then
    CMD_ARGS="$CMD_ARGS --pool-size $CAMOUFOX_POOL_SIZE"
fi

# API configuration
if [ -n "$CAMOUFOX_API_PORT" ]; then
    CMD_ARGS="$CMD_ARGS --api-port $CAMOUFOX_API_PORT"
fi

if [ -n "$CAMOUFOX_API_HOST" ]; then
    CMD_ARGS="$CMD_ARGS --api-host $CAMOUFOX_API_HOST"
fi

# WebSocket port
if [ -n "$CAMOUFOX_WS_PORT_START" ]; then
    CMD_ARGS="$CMD_ARGS --ws-port-start $CAMOUFOX_WS_PORT_START"
fi

# Headless mode
if [ "$CAMOUFOX_HEADLESS" = "true" ]; then
    CMD_ARGS="$CMD_ARGS --headless"
elif [ "$CAMOUFOX_HEADLESS" = "false" ]; then
    CMD_ARGS="$CMD_ARGS --no-headless"
fi

# GeoIP configuration
if [ "$CAMOUFOX_GEOIP" = "true" ]; then
    CMD_ARGS="$CMD_ARGS --geoip"
elif [ "$CAMOUFOX_GEOIP" = "false" ]; then
    CMD_ARGS="$CMD_ARGS --no-geoip"
fi

# Humanize configuration
if [ "$CAMOUFOX_HUMANIZE" = "true" ]; then
    CMD_ARGS="$CMD_ARGS --humanize"
elif [ "$CAMOUFOX_HUMANIZE" = "false" ]; then
    CMD_ARGS="$CMD_ARGS --no-humanize"
fi

# Block images
if [ "$CAMOUFOX_BLOCK_IMAGES" = "true" ]; then
    CMD_ARGS="$CMD_ARGS --block-images"
fi

# Proxy configuration
if [ -n "$CAMOUFOX_PROXY" ]; then
    CMD_ARGS="$CMD_ARGS --proxy $CAMOUFOX_PROXY"
fi

# Debug mode
if [ "$CAMOUFOX_DEBUG" = "true" ]; then
    CMD_ARGS="$CMD_ARGS --debug"
fi

echo "========================================"
echo "Configuration:"
echo "  Mode: ${CAMOUFOX_MODE:-single}"
echo "  Pool Size: ${CAMOUFOX_POOL_SIZE:-3}"
echo "  API Port: ${CAMOUFOX_API_PORT:-8080}"
echo "  WS Port: ${CAMOUFOX_WS_PORT_START:-9222}"
echo "  Headless: ${CAMOUFOX_HEADLESS:-true}"
echo "  GeoIP: ${CAMOUFOX_GEOIP:-true}"
echo "  Humanize: ${CAMOUFOX_HUMANIZE:-true}"
echo "  Proxy: ${CAMOUFOX_PROXY:-none}"
echo "========================================"
echo "WebSocket URL: ws://0.0.0.0:${CAMOUFOX_WS_PORT_START:-9222}"
echo "Health API: http://0.0.0.0:${CAMOUFOX_API_PORT:-8080}/health"
echo "========================================"

# Cleanup function
cleanup() {
    echo "Shutting down..."
    kill $XVFB_PID 2>/dev/null || true
    exit 0
}

trap cleanup SIGTERM SIGINT

# Launch camoufox-connector
echo "Starting camoufox-connector..."
exec python -m camoufox_connector.server $CMD_ARGS
