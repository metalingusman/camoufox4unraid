# Camoufox Connector Docker Image for changedetection.io
#
# This image runs camoufox-connector as a WebSocket bridge that resolves
# Playwright version mismatches between Camoufox and changedetection.io.
#
# Build for AMD64:
#   podman build --platform linux/amd64 -t chrissimpson84/camoufox-connector:latest .
#
# Run:
#   docker run -d --shm-size=2g -p 8080:8080 -p 9222:9222 chrissimpson84/camoufox-connector:latest

FROM python:3.11-slim

LABEL maintainer="metalingusman"
LABEL description="Camoufox Connector - WebSocket bridge for changedetection.io"
LABEL org.opencontainers.image.source="https://github.com/metalingusman/camoufox4unraid"

# Install system dependencies for browsers
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Browser dependencies
    libgtk-3-0 \
    libx11-xcb1 \
    libasound2 \
    libdbus-glib-1-2 \
    libxt6 \
    libxrender1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libxkbcommon0 \
    libgbm1 \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdrm2 \
    libxfixes3 \
    # Virtual display
    xvfb \
    dbus-x11 \
    # Utilities
    curl \
    wget \
    ca-certificates \
    # Fonts
    fonts-liberation \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt /app/requirements.txt

# Install Python packages
# Pin Playwright version to match changedetection.io (~=1.56.0)
RUN pip install --no-cache-dir -r /app/requirements.txt

# Fetch Camoufox browser with browserforge fingerprint data
RUN python -m camoufox fetch --browserforge

# Copy application files
COPY entrypoint.sh /app/entrypoint.sh

# Make entrypoint executable
RUN chmod +x /app/entrypoint.sh

# Default environment variables
ENV CAMOUFOX_MODE=single
ENV CAMOUFOX_POOL_SIZE=3
ENV CAMOUFOX_API_PORT=8080
ENV CAMOUFOX_API_HOST=0.0.0.0
ENV CAMOUFOX_WS_PORT_START=9222
ENV CAMOUFOX_HEADLESS=true
ENV CAMOUFOX_GEOIP=true
ENV CAMOUFOX_HUMANIZE=true
ENV CAMOUFOX_BLOCK_IMAGES=false
ENV DISPLAY=:99

# Expose ports
# 8080: HTTP API for health checks and /next endpoint
# 9222: WebSocket endpoint for browser connection
EXPOSE 8080
EXPOSE 9222

# Health check via HTTP API
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${CAMOUFOX_API_PORT}/health || exit 1

# Run entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]
