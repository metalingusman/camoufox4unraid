# Camoufox Docker Image for changedetection.io
# 
# This image runs Camoufox as a remote WebSocket server compatible with
# changedetection.io's Playwright content fetcher.
#
# Build for AMD64:
#   podman build --platform linux/amd64 -t chrissimpson84/camoufox:latest .
#
# Run:
#   docker run -d --shm-size=2g -p 3000:3000 chrissimpson84/camoufox:latest

FROM python:3.10-slim

LABEL maintainer="metalingusman"
LABEL description="Camoufox anti-detect browser server for changedetection.io"
LABEL org.opencontainers.image.source="https://github.com/metalingusman/camoufox4unraid"

# Install system dependencies
# - libgtk-3-0, libx11-xcb1, libasound2: Firefox/browser dependencies
# - xvfb: Virtual framebuffer for headless display
# - curl: Health checks
# - dbus-x11: D-Bus for Firefox
# - libdbus-glib-1-2: D-Bus GLib bindings
# - libxt6: X Toolkit Intrinsics
# - libxrender1: X Render Extension
# - libxcomposite1: X Composite Extension
# - libxdamage1: X Damage Extension
# - fonts-liberation: Standard fonts
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgtk-3-0 \
    libx11-xcb1 \
    libasound2 \
    xvfb \
    curl \
    dbus-x11 \
    libdbus-glib-1-2 \
    libxt6 \
    libxrender1 \
    libxcomposite1 \
    libxdamage1 \
    fonts-liberation \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
# - camoufox[geoip]: Camoufox with GeoIP support for location-based fingerprinting
# - playwright: Browser automation framework
RUN pip install --no-cache-dir \
    "camoufox[geoip]" \
    "playwright"

# Fetch Camoufox browser with browserforge fingerprint data
RUN python -m camoufox fetch --browserforge

# Create app directory
WORKDIR /app

# Copy application files
COPY server.py /app/server.py
COPY entrypoint.sh /app/entrypoint.sh

# Make entrypoint executable
RUN chmod +x /app/entrypoint.sh

# Default environment variables
ENV CAMOUFOX_PORT=3000
ENV CAMOUFOX_WS_PATH=connect
ENV CAMOUFOX_HEADLESS=true
ENV CAMOUFOX_GEOIP=false
ENV DISPLAY=:99

# Expose WebSocket port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:${CAMOUFOX_PORT}/ || exit 1

# Run entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]
