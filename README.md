# Camoufox Docker Containers for changedetection.io

[![Docker Hub](https://img.shields.io/docker/pulls/chrissimpson84/camoufox)](https://hub.docker.com/r/chrissimpson84/camoufox)

Docker containers running [Camoufox](https://camoufox.com) anti-detect browser for use with [changedetection.io](https://github.com/dgtlmoon/changedetection.io).

## Available Containers

| Container | Description | Use Case |
|-----------|-------------|----------|
| `camoufox-connector` | WebSocket bridge with Playwright version compatibility | **Recommended** for changedetection.io |
| `camoufox` | Direct Camoufox server | When version compatibility isn't an issue |

## Why Use the Connector?

changedetection.io pins Playwright to version ~1.56.0, while Camoufox may use a different version. This causes "Playwright version mismatch" errors. The connector resolves this by:

- Pinning Playwright to match changedetection.io's version
- Providing a compatible WebSocket bridge
- Supporting browser pools with fingerprint rotation

## What is Camoufox?

Camoufox is an anti-detect browser based on Firefox with:
- Stealth patches to avoid bot detection
- Intelligent fingerprint rotation
- Compatible with Playwright API
- GeoIP-based fingerprinting support

## Quick Start

### Using Camoufox Connector (Recommended)

```bash
docker run -d \
  --name camoufox-connector \
  --shm-size=2g \
  -p 8080:8080 \
  -p 9222:9222 \
  chrissimpson84/camoufox-connector:latest
```

### Using Direct Camoufox Server

```bash
docker run -d \
  --name camoufox \
  --shm-size=2g \
  -p 3000:3000 \
  chrissimpson84/camoufox:latest
```

### Docker Compose with changedetection.io

**Using Connector (Recommended):**

```yaml
services:
  camoufox-connector:
    image: chrissimpson84/camoufox-connector:latest
    container_name: camoufox-connector
    shm_size: 2g
    environment:
      - CAMOUFOX_MODE=single
      - CAMOUFOX_HEADLESS=true
      - CAMOUFOX_GEOIP=true

  changedetection:
    image: ghcr.io/dgtlmoon/changedetection.io:latest
    container_name: changedetection
    volumes:
      - changedetection-data:/datastore
    environment:
      - PLAYWRIGHT_DRIVER_URL=ws://camoufox-connector:9222
    ports:
      - "5000:5000"
    depends_on:
      - camoufox-connector

volumes:
  changedetection-data:
```

**Using Direct Server:**

```yaml
services:
  camoufox:
    image: chrissimpson84/camoufox:latest
    container_name: camoufox
    shm_size: 2g
    environment:
      - CAMOUFOX_PORT=3000
      - CAMOUFOX_WS_PATH=connect

  changedetection:
    image: ghcr.io/dgtlmoon/changedetection.io:latest
    container_name: changedetection
    volumes:
      - changedetection-data:/datastore
    environment:
      - PLAYWRIGHT_DRIVER_URL=ws://camoufox:3000/connect
    ports:
      - "5000:5000"
    depends_on:
      - camoufox

volumes:
  changedetection-data:
```

## Environment Variables

### Camoufox Connector

| Variable | Default | Description |
|----------|---------|-------------|
| `CAMOUFOX_MODE` | `single` | Operating mode: `single` or `pool` |
| `CAMOUFOX_POOL_SIZE` | `3` | Number of browsers (pool mode) |
| `CAMOUFOX_API_PORT` | `8080` | HTTP API port for health checks |
| `CAMOUFOX_WS_PORT_START` | `9222` | WebSocket port for browser connection |
| `CAMOUFOX_HEADLESS` | `true` | Run in headless mode |
| `CAMOUFOX_GEOIP` | `true` | Enable GeoIP fingerprinting |
| `CAMOUFOX_HUMANIZE` | `true` | Enable human-like behavior |
| `CAMOUFOX_BLOCK_IMAGES` | `false` | Block image loading |
| `CAMOUFOX_PROXY` | | Proxy URL (http://user:pass@host:port) |
| `CAMOUFOX_DEBUG` | `false` | Enable debug logging |

### Direct Camoufox Server

| Variable | Default | Description |
|----------|---------|-------------|
| `CAMOUFOX_PORT` | `3000` | WebSocket server port |
| `CAMOUFOX_WS_PATH` | `connect` | WebSocket URL path |
| `CAMOUFOX_HEADLESS` | `true` | Run in headless mode |
| `CAMOUFOX_GEOIP` | `false` | Enable GeoIP fingerprinting |
| `CAMOUFOX_PROXY_SERVER` | | Proxy server URL |
| `CAMOUFOX_PROXY_USERNAME` | | Proxy username |
| `CAMOUFOX_PROXY_PASSWORD` | | Proxy password |

## UNRAID Installation

### Via Community Applications

1. Go to the **Apps** tab in UNRAID
2. Search for "camoufox"
3. Choose either:
   - **camoufox-connector** (recommended for changedetection.io)
   - **camoufox** (direct server)
4. Click **Install**
5. Configure settings as needed
6. Click **Apply**

### Manual Template Installation

**Connector (Recommended):**
```bash
wget -O /boot/config/plugins/dockerMan/templates-user/camoufox-connector.xml \
  https://raw.githubusercontent.com/metalingusman/camoufox4unraid/main/unraid/camoufox-connector.xml
```

**Direct Server:**
```bash
wget -O /boot/config/plugins/dockerMan/templates-user/camoufox.xml \
  https://raw.githubusercontent.com/metalingusman/camoufox4unraid/main/unraid/camoufox.xml
```

Then go to **Docker** tab → **Add Container** and select the template.

## Using with changedetection.io

1. Ensure both containers are on the same Docker network
2. In changedetection.io, set the environment variable:

   **Using Connector (Recommended):**
   ```
   PLAYWRIGHT_DRIVER_URL=ws://camoufox-connector:9222
   ```

   **Using Direct Server:**
   ```
   PLAYWRIGHT_DRIVER_URL=ws://camoufox:3000/connect
   ```
3. In changedetection.io settings, select **Playwright Chromium/Javascript** as the fetcher
   - Note: Despite the name, this works with Camoufox (Firefox-based)

## WebSocket Endpoints

### Connector

| Endpoint | Description |
|----------|-------------|
| `ws://hostname:9222` | Browser WebSocket connection |
| `http://hostname:8080/health` | Health check API |
| `http://hostname:8080/next` | Get next browser (pool mode) |

### Direct Server

| Endpoint | Description |
|----------|-------------|
| `ws://hostname:3000/connect` | Browser WebSocket connection |

### Example: Connect with Playwright

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    # Using connector
    browser = p.firefox.connect('ws://localhost:9222')
    # Or using direct server
    # browser = p.firefox.connect('ws://localhost:3000/connect')
    
    page = browser.new_page()
    page.goto('https://example.com')
    # ...
```

## Important Notes

### Shared Memory Requirement

Browsers require significant shared memory. Always run with `--shm-size=2g` or higher:

```bash
docker run --shm-size=2g chrissimpson84/camoufox:latest
```

In UNRAID, this is configured via **Extra Parameters**: `--shm-size=2g`

### Firefox vs Chrome

Camoufox uses Firefox, while changedetection.io's default browser is Chrome. The Playwright WebSocket protocol is compatible between both browsers, but some edge cases may behave differently.

### Single Browser Instance

The Camoufox server runs a single browser instance. Fingerprints do not rotate between sessions. For high-scale use cases, consider running multiple containers.

## Building from Source

### Prerequisites

- Podman or Docker
- For cross-compilation on Apple Silicon: `qemu-user-static`

### Build for AMD64 (using Podman on Mac)

**Connector:**
```bash
# One-time setup for cross-compilation
podman machine ssh sudo rpm-ostree install qemu-user-static
podman machine ssh sudo systemctl reboot

# Build connector
podman build --platform linux/amd64 -t chrissimpson84/camoufox-connector:latest ./connector

# Push to Docker Hub
podman push chrissimpson84/camoufox-connector:latest
```

**Direct Server:**
```bash
# Build direct server
podman build --platform linux/amd64 -t chrissimpson84/camoufox:latest .

# Push to Docker Hub
podman push chrissimpson84/camoufox:latest
```

## Troubleshooting

### Container crashes immediately
- Ensure `--shm-size=2g` is set
- Check logs: `docker logs camoufox`

### changedetection.io can't connect
- Verify both containers are on the same network
- Check the WebSocket URL format: `ws://camoufox:3000/connect`
- Ensure Camoufox container is healthy: `docker ps`

### Browser detection issues
- Try enabling GeoIP with a proxy for more accurate fingerprinting
- Camoufox works best with a residential proxy

## License

MIT License - See [LICENSE](LICENSE) for details.

## Credits

- [Camoufox](https://github.com/daijro/camoufox) by daijro
- [changedetection.io](https://github.com/dgtlmoon/changedetection.io) by dgtlmoon
