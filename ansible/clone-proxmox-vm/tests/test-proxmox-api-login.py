from proxmoxer import ProxmoxAPI

try:
    proxmox = ProxmoxAPI('10.80.80.2', user='root@pam', password='', verify_ssl=False)
    print("Authentication successful!")
    # Optional: Try a simple API call to verify
    nodes = proxmox.nodes.get()
    print("Connected nodes:", [node['node'] for node in nodes])
except Exception as e:
    print(f"Authentication failed: {e}")
