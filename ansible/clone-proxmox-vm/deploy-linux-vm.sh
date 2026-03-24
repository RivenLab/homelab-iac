#!/bin/bash

# Prompt for VM Name
read -p "VM Name: " VM_NAME


# Prompt for CPU cores with default
read -p "CPU Cores (default 2): " CPU_CORES
CPU_CORES=${CPU_CORES:-2}

# Prompt for RAM with default
read -p "RAM in MB (default 4096): " RAM
RAM=${RAM:-4096}

# Prompt for Disk Size with default
read -p "Disk Size (default 20G): " DISK_SIZE
DISK_SIZE=${DISK_SIZE:-20G}

# Prompt for IP with optional placeholder
read -p "IP Address (default 10.80.80.10/24): " IP_ADDRESS
IP_ADDRESS=${IP_ADDRESS:-10.80.80.10/24}

# Prompt for Gateway with optional default
read -p "Gateway (default 10.80.80.1): " GATEWAY
GATEWAY=${GATEWAY:-10.80.80.1}

# Prompt for DNS with optional default
read -p "DNS Servers (default 10.80.80.1,8.8.8.8): " DNS_SERVERS
DNS_SERVERS=${DNS_SERVERS:-10.80.80.1,8.8.8.8}

# Prompt for Hostname with optional default
read -p "Hostname (default vm1.example.local): " HOSTNAME
HOSTNAME=${HOSTNAME:-vm1.example.local}

# Print collected information
echo -e "\n--- VM Configuration Summary ---"
echo "VM Name: $VM_NAME"
echo "CPU Cores: $CPU_CORES"
echo "RAM: $RAM MB"
echo "Disk Size: $DISK_SIZE"
echo "IP Address: $IP_ADDRESS"
echo "Gateway: $GATEWAY"
echo "DNS Servers: $DNS_SERVERS"
echo "Hostname: $HOSTNAME"

# Prompt for confirmation
read -p "Confirm configuration? (y/N): " CONFIRM

if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Configuration confirmed. Creating VM..."

    # Generate temporary variables file
    cat > /tmp/vm_vars.yml <<EOF
vm_templates:
  - template: 'gemini'
    vms:
      - name: "$VM_NAME"
        network:
          ip: "$IP_ADDRESS"
          gateway: "$GATEWAY"
          dns_servers: [${DNS_SERVERS//,/\, }]
        hostname: "$HOSTNAME"
        cpu: $CPU_CORES
        ram: $RAM
        disk: "$DISK_SIZE"
EOF

    # Run Ansible playbook
    ansible-playbook playbooks/main.yml \
        -i inventory/hosts.ini \
        --extra-vars "@/tmp/vm_vars.yml"

    # Clean up temporary file
    rm /tmp/vm_vars.yml

else
    echo "Configuration cancelled."
fi
