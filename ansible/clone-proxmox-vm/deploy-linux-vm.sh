#!/bin/bash
set -e
echo "=== Proxmox VM Deployment Script ==="

# Prompt for VM Name
read -p "VM Name: " VM_NAME
if [[ -z "$VM_NAME" ]]; then
  echo "VM Name is required"
  exit 1
fi

# Prompt for VM ID (template to clone from) - obligatoire
read -p "Template VMID (source template to clone from): " VM_ID
if [[ -z "$VM_ID" ]]; then
  echo "Template VMID is required"
  exit 1
fi

# Prompt for VMID Cloned (new VM ID) - obligatoire
read -p "New VM ID (vmid_cloned): " VMID_CLONED
if [[ -z "$VMID_CLONED" ]]; then
  echo "New VM ID is required"
  exit 1
fi

# Prompt for CPU cores with default
read -p "CPU Cores (default 2): " CPU_CORES
CPU_CORES=${CPU_CORES:-2}

# Prompt for RAM with default
read -p "RAM in MB (default 4096): " RAM
RAM=${RAM:-4096}

# Prompt for Disk Size with default
read -p "Disk Size (default 20G): " DISK_SIZE
DISK_SIZE=${DISK_SIZE:-20G}

# Prompt for IP
read -p "IP Address (default 10.20.20.10/24): " IP_ADDRESS
IP_ADDRESS=${IP_ADDRESS:-10.20.20.10/24}

# Prompt for Gateway
read -p "Gateway (default 10.20.20.1): " GATEWAY
GATEWAY=${GATEWAY:-10.20.20.1}

# Prompt for DNS
read -p "DNS Servers (comma separated, default 10.20.20.1,8.8.8.8): " DNS_SERVERS
DNS_SERVERS=${DNS_SERVERS:-10.20.20.1,8.8.8.8}

# Prompt for Hostname - default to {vm_name}.dragon.local
DEFAULT_HOSTNAME="${VM_NAME}.dragon.local"
read -p "Hostname (default ${DEFAULT_HOSTNAME}): " HOSTNAME
HOSTNAME=${HOSTNAME:-$DEFAULT_HOSTNAME}

# Summary
echo ""
echo "--- VM Configuration Summary ---"
echo "VM Name:        $VM_NAME"
echo "Template VMID:  $VM_ID"
echo "New VM ID:      $VMID_CLONED"
echo "CPU Cores:      $CPU_CORES"
echo "RAM:            $RAM MB"
echo "Disk Size:      $DISK_SIZE"
echo "IP Address:     $IP_ADDRESS"
echo "Gateway:        $GATEWAY"
echo "DNS Servers:    $DNS_SERVERS"
echo "Hostname:       $HOSTNAME"

# Confirm
read -p "Confirm configuration? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Configuration cancelled."
  exit 0
fi

echo "Creating VM..."

# Generate YAML
cat > /tmp/vm_vars.yml <<EOF
vm_templates:
  - template: 'gemini'
    vms:
      - name: "$VM_NAME"
        vmid: $VM_ID
        vmid_cloned: $VMID_CLONED
        network:
          ip: "$IP_ADDRESS"
          gateway: "$GATEWAY"
          dns_servers:
$(for dns in ${DNS_SERVERS//,/ }; do echo "            - \"$dns\""; done)
        hostname: "$HOSTNAME"
        cpu: $CPU_CORES
        ram: $RAM
        disk: "$DISK_SIZE"
EOF

echo "Generated vars file:"
cat /tmp/vm_vars.yml

# Run Ansible
ansible-playbook playbooks/main.yml \
    -i inventory/hosts.ini \
    --extra-vars "@/tmp/vm_vars.yml"

# Cleanup
rm /tmp/vm_vars.yml
echo "Done."
