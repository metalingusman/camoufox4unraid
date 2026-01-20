# Camoufox Docker Container for changedetection.io

[![Docker Hub](https://img.shields.io/docker/pulls/chrissimpson84/camoufox)](https://hub.docker.com/r/chrissimpson84/camoufox)

A Docker container running [Camoufox](https://camoufox.com) as a Playwright-compatible WebSocket server, designed for use with [changedetection.io](https://github.com/dgtlmoon/changedetection.io).

## What is Camoufox?

Camoufox is an anti-detect browser based on Firefox with:
- Stealth patches to avoid bot detection
- Intelligent fingerprint rotation
- Compatible with Playwright API
- GeoIP-based fingerprinting support

## Quick Start

### Docker Run

```bash
docker run -d \
  --name camoufox \
  --shm-size=2g \
  -p 3000:3000 \
  chrissimpson84/camoufox:latest
```

### Docker Compose with changedetection.io

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
3. Click **Install**
4. Configure settings as needed
5. Click **Apply**

### Manual Template Installation

1. Download the template:
   ```bash
   wget -O /boot/config/plugins/dockerMan/templates-user/camoufox.xml \
     https://raw.githubusercontent.com/metalingusman/camoufox4unraid/main/unraid/camoufox.xml
   ```
2. Go to **Docker** tab → **Add Container**
3. Select **camoufox** from the template dropdown
4. Configure and apply

## Using with changedetection.io

1. Ensure both containers are on the same Docker network
2. In changedetection.io, set the environment variable:
   ```
   PLAYWRIGHT_DRIVER_URL=ws://camoufox:3000/connect
   ```
3. In changedetection.io settings, select **Playwright Chromium/Javascript** as the fetcher
   - Note: Despite the name, this works with Camoufox (Firefox-based)

## WebSocket Endpoint

The container exposes a Playwright-compatible WebSocket at:
```
ws://hostname:3000/connect
```

Connect using Playwright:
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.firefox.connect('ws://localhost:3000/connect')
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

```bash
# One-time setup for cross-compilation
podman machine ssh sudo rpm-ostree install qemu-user-static
podman machine ssh sudo systemctl reboot

# Build
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
