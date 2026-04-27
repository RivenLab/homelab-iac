"""
Test Proxmox API connectivity.
Reads credentials from environment variables to avoid hardcoding secrets.

Usage:
  export PROXMOX_HOST=10.10.10.101
  export PROXMOX_USER=root@pam
  export PROXMOX_PASSWORD=yourpassword
  python tests/test-proxmox-api-login.py
"""
import os
from proxmoxer import ProxmoxAPI

host = os.environ.get("PROXMOX_HOST", "10.10.10.101")
user = os.environ.get("PROXMOX_USER", "root@pam")
password = os.environ.get("PROXMOX_PASSWORD")

if not password:
    raise SystemExit("ERROR: PROXMOX_PASSWORD environment variable is not set.")

try:
    proxmox = ProxmoxAPI(host, user=user, password=password, verify_ssl=False)
    print("Authentication successful!")
    nodes = proxmox.nodes.get()
    print("Connected nodes:", [node['node'] for node in nodes])
except Exception as e:
    print(f"Authentication failed: {e}")
