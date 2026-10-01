#!/bin/bash
set -euo pipefail
echo "=== Proxmox VM Deployment Script ==="

# Prompt for VM Name
read -p "VM Name: " VM_NAME
if [[ -z "$VM_NAME" ]]; then
  echo "ERROR: VM Name is required"
  exit 1
fi

# Prompt for Template VMID (source)
read -p "Template VMID (source template to clone from): " VM_ID
if [[ -z "$VM_ID" ]]; then
  echo "ERROR: Template VMID is required"
  exit 1
fi

# Prompt for new VMID (destination)
read -p "New VM ID (vmid_cloned): " VMID_CLONED
if [[ -z "$VMID_CLONED" ]]; then
  echo "ERROR: New VM ID is required"
  exit 1
fi

# Optional settings with defaults
read -p "CPU Cores (default 2): " CPU_CORES
CPU_CORES=${CPU_CORES:-2}

read -p "RAM in MB (default 4096): " RAM
RAM=${RAM:-4096}

read -p "Disk Size in GB (default 20): " DISK_SIZE_GB
DISK_SIZE_GB=${DISK_SIZE_GB:-20}
# Strip any trailing G if user typed it
DISK_SIZE_GB="${DISK_SIZE_GB//G/}"

read -p "IP Address (default 10.20.20.10/24): " IP_ADDRESS
IP_ADDRESS=${IP_ADDRESS:-10.20.20.10/24}

read -p "Gateway (default 10.20.20.1): " GATEWAY
GATEWAY=${GATEWAY:-10.20.20.1}

read -p "DNS Servers (comma separated, default 10.20.20.1,8.8.8.8): " DNS_SERVERS
DNS_SERVERS=${DNS_SERVERS:-10.20.20.1,8.8.8.8}

DEFAULT_HOSTNAME="${VM_NAME}.dragon.local"
read -p "Hostname (default ${DEFAULT_HOSTNAME}): " HOSTNAME
HOSTNAME=${HOSTNAME:-$DEFAULT_HOSTNAME}

read -p "Install Docker? (y/N): " INSTALL_DOCKER
INSTALL_DOCKER=${INSTALL_DOCKER:-N}
if [[ "$INSTALL_DOCKER" =~ ^[Yy]$ ]]; then
  INSTALL_DOCKER_BOOL=true
else
  INSTALL_DOCKER_BOOL=false
fi

# Summary
echo ""
echo "--- VM Configuration Summary ---"
echo "VM Name:        $VM_NAME"
echo "Template VMID:  $VM_ID"
echo "New VM ID:      $VMID_CLONED"
echo "CPU Cores:      $CPU_CORES"
echo "RAM:            $RAM MB"
echo "Disk Size:      ${DISK_SIZE_GB}G"
echo "IP Address:     $IP_ADDRESS"
echo "Gateway:        $GATEWAY"
echo "DNS Servers:    $DNS_SERVERS"
echo "Hostname:       $HOSTNAME"
echo "Install Docker: $INSTALL_DOCKER_BOOL"
echo ""

read -p "Confirm configuration? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

echo "Creating VM..."

# Generate temporary vars file
VARS_FILE=$(mktemp /tmp/vm_vars.XXXXXX.yml)
INIT_INVENTORY=$(mktemp /tmp/vm_inventory.XXXXXX.ini)
trap "rm -f $VARS_FILE $INIT_INVENTORY" EXIT

cat > "$VARS_FILE" <<EOF
disk_size_gb: ${DISK_SIZE_GB}
install_docker: ${INSTALL_DOCKER_BOOL}
dns_servers:
$(for dns in ${DNS_SERVERS//,/ }; do echo "  - \"$dns\""; done)
vm_templates:
  - template: 'gemini'
    vms:
      - name: "${VM_NAME}"
        vmid: ${VM_ID}
        vmid_cloned: ${VMID_CLONED}
        network:
          ip: "${IP_ADDRESS}"
          gateway: "${GATEWAY}"
          dns_servers:
$(for dns in ${DNS_SERVERS//,/ }; do echo "            - \"$dns\""; done)
        hostname: "${HOSTNAME}"
        cpu: ${CPU_CORES}
        ram: ${RAM}
EOF

echo "Generated vars:"
cat "$VARS_FILE"
echo ""

# Run Ansible: clone the VM and wait for it to be reachable
ansible-playbook playbooks/deploy_linux.yml \
  -i inventory/hosts.ini \
  --extra-vars "@${VARS_FILE}"

# Register the new VM under the "linux" group so init-linux.yml can target it
VM_IP="${IP_ADDRESS%%/*}"
cat > "$INIT_INVENTORY" <<EOF
[linux]
${VM_IP}
EOF

# Run Ansible: configure the VM and take the post-deployment snapshot
ansible-playbook playbooks/init-linux.yml \
  -i inventory/hosts.ini \
  -i "$INIT_INVENTORY" \
  --extra-vars "@${VARS_FILE}"

echo "Done."
