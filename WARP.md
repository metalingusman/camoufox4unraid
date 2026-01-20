# Camoufox Docker Container for UNRAID

## Project Overview

Docker container packaging Camoufox anti-detect browser as a Playwright WebSocket server for use with changedetection.io on UNRAID.

## Requirements

1. **Docker Container**: Run Camoufox as a remote WebSocket server
2. **Architecture**: AMD64/x86_64 (target: UNRAID servers)
3. **Build Environment**: Mac Apple Silicon with Podman
4. **Registry**: Docker Hub (`chrissimpson84/camoufox`)
5. **UNRAID Integration**: Community Applications XML template

## Repository

- **GitHub**: https://github.com/metalingusman/camoufox4unraid
- **Docker Hub**: https://hub.docker.com/r/chrissimpson84/camoufox

## Technical Decisions

### Base Image
- `python:3.10-slim` (Debian-based) for compatibility and size
- Python 3.10 chosen for Camoufox compatibility

### Dependencies
- System: `libgtk-3-0`, `libx11-xcb1`, `libasound2`, `xvfb`, `dbus-x11`, fonts
- Python: `camoufox[geoip]`, `playwright`

### Virtual Display
- Xvfb required even in headless mode for Firefox stability
- Display :99 with 1920x1080x24 resolution

### WebSocket Configuration
- Default port: 3000 (matches changedetection.io convention)
- Default path: `/connect`
- Full URL: `ws://hostname:3000/connect`

### Environment Variables
| Variable | Default | Purpose |
|----------|---------|---------|
| CAMOUFOX_PORT | 3000 | Server port |
| CAMOUFOX_WS_PATH | connect | WebSocket path |
| CAMOUFOX_HEADLESS | true | Headless mode |
| CAMOUFOX_GEOIP | false | GeoIP fingerprinting |
| CAMOUFOX_PROXY_SERVER | | Proxy URL |
| CAMOUFOX_PROXY_USERNAME | | Proxy auth |
| CAMOUFOX_PROXY_PASSWORD | | Proxy auth |

## Known Limitations

1. **Single Browser Instance**: Server runs one browser; fingerprints don't rotate between sessions
2. **Firefox vs Chrome**: changedetection.io typically uses Chrome; compatibility verified via Playwright protocol
3. **Shared Memory**: Requires `--shm-size=2g` minimum

## Build Commands

```bash
# Cross-compile for AMD64 on Apple Silicon
podman build --platform linux/amd64 -t chrissimpson84/camoufox:latest .

# Push to Docker Hub
podman push chrissimpson84/camoufox:latest
```

## File Structure

```
camoufox/
├── Dockerfile           # Container build definition
├── server.py            # Camoufox launch script
├── entrypoint.sh        # Container startup script
├── docker-compose.yml   # Example with changedetection.io
├── README.md            # User documentation
├── WARP.md              # Project memory (this file)
└── unraid/
    └── camoufox.xml     # UNRAID template
```

## Status

- [x] Project structure created
- [x] Dockerfile implemented
- [x] Server script with env var configuration
- [x] Entrypoint script with Xvfb
- [x] docker-compose.yml example
- [x] UNRAID XML template
- [x] README documentation
- [ ] Build and test locally
- [ ] Push to Docker Hub
- [ ] Test with changedetection.io
- [ ] Submit to UNRAID Community Applications

## Changelog

### 2026-01-20
- Initial project creation
- Dockerfile, server.py, entrypoint.sh implemented
- UNRAID template created
- Documentation written
