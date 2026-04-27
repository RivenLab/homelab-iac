# manage-proxmox-vm

Ansible project to deploy and configure Linux VMs on Proxmox VE by cloning a cloud-init template.

## Flow

```
deploy-linux-vm.sh
  └─> playbooks/deploy_linux.yml
        ├─ Play 1 (localhost) → proxmox_clone_linux   # Clone template, configure Cloud-Init, start VM
        ├─ Play 2 (target VM) → linux_resize_disk     # Grow partition/filesystem to requested size
        │                     → manage_users          # Remove packer user, create dragon user + SSH key
        └─ Play 3 (localhost) → proxmox_snapshot      # Post-deployment snapshot via Proxmox API
```

## Prerequisites

```bash
pip install proxmoxer requests
ansible-galaxy collection install community.general ansible.posix
```

## Configuration

Copy `group_vars/main.yml.example` to `group_vars/main.yml` and fill in your values:

```yaml
proxmox_host: "10.10.10.101"
proxmox_node: "prx2"
proxmox_api_user: "root@pam"
proxmox_api_password: "yourpassword"
proxmox_storage: "vm-nvme1"

linux_user: "dragon"
linux_user_password: "yourpassword"
linux_ssh_pubkey: "ssh-ed25519 AAAA..."

disk_size_gb: 20
```

Copy `inventory/hosts.ini.example` to `inventory/hosts.ini` and set the target VM IP.

## Usage

```bash
chmod +x deploy-linux-vm.sh
./deploy-linux-vm.sh
```

## Variables Reference

| Variable | Description | Default |
|---|---|---|
| `proxmox_host` | Proxmox API host | — |
| `proxmox_node` | Proxmox node name | — |
| `proxmox_api_user` | Proxmox API user | `root@pam` |
| `proxmox_api_password` | Proxmox API password | — |
| `proxmox_storage` | Storage pool for cloned disks | `vm-nvme1` |
| `linux_user` | Username to create on the VM | `dragon` |
| `linux_user_password` | Password for the user | — |
| `linux_ssh_pubkey` | SSH public key for the user | — |
| `disk_size_gb` | Target disk size after resize (integer, GB) | `20` |
