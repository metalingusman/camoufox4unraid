#!/usr/bin/env python3
"""
Camoufox Server for changedetection.io integration.

This script launches Camoufox as a remote WebSocket server that can be
used with changedetection.io's Playwright content fetcher.

Environment Variables:
    CAMOUFOX_PORT: WebSocket server port (default: 3000)
    CAMOUFOX_WS_PATH: WebSocket URL path (default: connect)
    CAMOUFOX_HEADLESS: Run in headless mode (default: true)
    CAMOUFOX_GEOIP: Enable GeoIP-based fingerprinting (default: false)
    CAMOUFOX_PROXY_SERVER: Proxy server URL (optional)
    CAMOUFOX_PROXY_USERNAME: Proxy username (optional)
    CAMOUFOX_PROXY_PASSWORD: Proxy password (optional)
"""

import os
import sys
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def str_to_bool(value: str, default: bool = False) -> bool:
    """Convert string to boolean."""
    if not value:
        return default
    return value.lower() in ('true', '1', 'yes', 'on')


def get_proxy_config() -> dict | None:
    """Build proxy configuration from environment variables."""
    proxy_server = os.environ.get('CAMOUFOX_PROXY_SERVER')
    if not proxy_server:
        return None
    
    proxy_config = {'server': proxy_server}
    
    username = os.environ.get('CAMOUFOX_PROXY_USERNAME')
    password = os.environ.get('CAMOUFOX_PROXY_PASSWORD')
    
    if username:
        proxy_config['username'] = username
    if password:
        proxy_config['password'] = password
    
    logger.info(f"Proxy configured: {proxy_server}")
    return proxy_config


def main():
    """Launch Camoufox server."""
    try:
        from camoufox.server import launch_server
    except ImportError as e:
        logger.error(f"Failed to import camoufox: {e}")
        logger.error("Please ensure camoufox is installed: pip install camoufox[geoip]")
        sys.exit(1)
    
    # Configuration from environment variables
    port = int(os.environ.get('CAMOUFOX_PORT', 3000))
    ws_path = os.environ.get('CAMOUFOX_WS_PATH', 'connect')
    headless = str_to_bool(os.environ.get('CAMOUFOX_HEADLESS', 'true'), default=True)
    geoip = str_to_bool(os.environ.get('CAMOUFOX_GEOIP', 'false'), default=False)
    proxy_config = get_proxy_config()
    
    # Log configuration
    logger.info("=" * 60)
    logger.info("Camoufox Server Configuration")
    logger.info("=" * 60)
    logger.info(f"Port: {port}")
    logger.info(f"WebSocket Path: /{ws_path}")
    logger.info(f"Headless Mode: {headless}")
    logger.info(f"GeoIP Enabled: {geoip}")
    logger.info(f"Proxy: {'Configured' if proxy_config else 'None'}")
    logger.info("=" * 60)
    logger.info(f"WebSocket URL: ws://0.0.0.0:{port}/{ws_path}")
    logger.info("=" * 60)
    
    # Launch server
    try:
        launch_server(
            headless=headless,
            port=port,
            ws_path=ws_path,
            geoip=geoip,
            proxy=proxy_config
        )
    except Exception as e:
        logger.error(f"Server error: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()
