# Camoufox Docker Containers for UNRAID

## Project Overview

Docker containers packaging Camoufox anti-detect browser as Playwright WebSocket servers for use with changedetection.io on UNRAID.

## Containers

| Container | Description | Use Case |
|-----------|-------------|----------|
| `camoufox-connector` | WebSocket bridge with Playwright version compatibility | **Recommended** for changedetection.io |
| `camoufox` | Direct Camoufox server | When version compatibility isn't an issue |

## Requirements

1. **Docker Containers**: Run Camoufox as remote WebSocket servers
2. **Architecture**: AMD64/x86_64 (target: UNRAID servers)
3. **Build Environment**: Mac Apple Silicon with Podman
4. **Registry**: Docker Hub (`chrissimpson84/camoufox`, `chrissimpson84/camoufox-connector`)
5. **UNRAID Integration**: Community Applications XML templates

## Repository

- **GitHub**: https://github.com/metalingusman/camoufox4unraid
- **Docker Hub (connector)**: https://hub.docker.com/r/chrissimpson84/camoufox-connector
- **Docker Hub (direct)**: https://hub.docker.com/r/chrissimpson84/camoufox

## Technical Decisions

### Playwright Version Mismatch Issue
changedetection.io pins Playwright to ~1.56.0, while Camoufox uses the latest version. This causes protocol version mismatch errors. The connector solves this by:
- Using `camoufox-connector` package (PyPI 1.0.2) as WebSocket bridge
- Pinning Playwright to ~1.56.0 to match changedetection.io
- Supporting browser pools with fingerprint rotation

### Connector Container
- Base: `python:3.11-slim`
- Package: `camoufox-connector>=1.0.2` from PyPI
- Playwright: `~=1.56.0` (pinned to match changedetection.io)
- Ports: 8080 (HTTP API), 9222 (WebSocket)

### Direct Server Container
- Base: `python:3.10-slim` (Debian-based)
- Python: `camoufox[geoip]`, `playwright`
- Port: 3000 (WebSocket)

### Virtual Display
- Xvfb required even in headless mode for Firefox stability
- Display :99 with 1920x1080x24 resolution

### Connector Environment Variables
| Variable | Default | Purpose |
|----------|---------|--------|
| CAMOUFOX_MODE | single | Operating mode (single/pool) |
| CAMOUFOX_POOL_SIZE | 3 | Browser instances (pool mode) |
| CAMOUFOX_API_PORT | 8080 | HTTP API port |
| CAMOUFOX_WS_PORT_START | 9222 | WebSocket port |
| CAMOUFOX_HEADLESS | true | Headless mode |
| CAMOUFOX_GEOIP | true | GeoIP fingerprinting |
| CAMOUFOX_HUMANIZE | true | Human-like behavior |
| CAMOUFOX_PROXY | | Proxy URL |

### Direct Server Environment Variables
| Variable | Default | Purpose |
|----------|---------|--------|
| CAMOUFOX_PORT | 3000 | Server port |
| CAMOUFOX_WS_PATH | connect | WebSocket path |
| CAMOUFOX_HEADLESS | true | Headless mode |
| CAMOUFOX_GEOIP | false | GeoIP fingerprinting |
| CAMOUFOX_PROXY_SERVER | | Proxy URL |

## Known Limitations

1. **Shared Memory**: Requires `--shm-size=2g` minimum
2. **Firefox vs Chrome**: changedetection.io typically uses Chrome; compatibility verified via Playwright protocol

## Build Commands

```bash
# Cross-compile for AMD64 on Apple Silicon

# Connector (recommended)
podman build --platform linux/amd64 -t chrissimpson84/camoufox-connector:latest ./connector
podman push chrissimpson84/camoufox-connector:latest

# Direct server
podman build --platform linux/amd64 -t chrissimpson84/camoufox:latest .
podman push chrissimpson84/camoufox:latest
```

## File Structure

```
camoufox/
├── connector/
│   ├── Dockerfile       # Connector container build
│   ├── entrypoint.sh    # Connector startup script
│   └── requirements.txt # Pinned Playwright version
├── Dockerfile           # Direct server build
├── server.py            # Direct server launch script
├── entrypoint.sh        # Direct server startup script
├── docker-compose.yml   # Example with changedetection.io
├── README.md            # User documentation
├── WARP.md              # Project memory (this file)
└── unraid/
    ├── camoufox.xml             # Direct server UNRAID template
    └── camoufox-connector.xml   # Connector UNRAID template
```

## Status

### Direct Server (camoufox)
- [x] Dockerfile implemented
- [x] Server script with env var configuration
- [x] Entrypoint script with Xvfb
- [x] UNRAID XML template
- [ ] Build and test locally
- [ ] Push to Docker Hub

### Connector (camoufox-connector)
- [x] connector/Dockerfile implemented
- [x] connector/requirements.txt with pinned Playwright ~=1.56.0
- [x] connector/entrypoint.sh with Xvfb
- [x] UNRAID XML template (camoufox-connector.xml)
- [x] Build and test locally
- [x] Push to Docker Hub

### Integration
- [x] docker-compose.yml with both options
- [x] README documentation
- [ ] Test with changedetection.io
- [ ] Submit to UNRAID Community Applications

## Changelog

### 2026-01-21
- Added camoufox-connector container to resolve Playwright version mismatch
- Created connector/Dockerfile, entrypoint.sh, requirements.txt
- Added camoufox-connector.xml UNRAID template
- Updated docker-compose.yml with connector profile
- Updated README with connector documentation

### 2026-01-20
- Initial project creation
- Dockerfile, server.py, entrypoint.sh implemented
- UNRAID template created
- Documentation written
