#!/bin/bash

set -euo pipefail
umask 077

USERNAME="ansible"
SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5a4Aqkcvsmu4NQS7vj/fIRZ4E9ao8h5VUdcUaemCSU dragon@jumper"
HOME_DIR="/home/$USERNAME"
SSH_DIR="$HOME_DIR/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
SUDOERS_DIR="/etc/sudoers.d"
SUDOERS_FILE="$SUDOERS_DIR/$USERNAME"
SSHD_CONFIG="/etc/ssh/sshd_config"

if [ "$EUID" -ne 0 ]; then
  echo "Run as root."
  exit 1
fi

echo "Creating/locking user $USERNAME..."

if ! id "$USERNAME" &>/dev/null; then
    useradd -m -s /bin/bash -U "$USERNAME"
    echo "User $USERNAME created."
fi
passwd -l "$USERNAME"
echo "User password locked."

echo "Setting up SSH directory and key..."

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
chown "$USERNAME:$USERNAME" "$SSH_DIR"

if [ ! -f "$AUTHORIZED_KEYS" ] || ! grep -qxF "$SSH_KEY" "$AUTHORIZED_KEYS"; then
    echo "$SSH_KEY" >> "$AUTHORIZED_KEYS"
    echo "SSH key added."
fi
chmod 600 "$AUTHORIZED_KEYS"
chown "$USERNAME:$USERNAME" "$AUTHORIZED_KEYS"

echo "Configuring sudoers..."

mkdir -p "$SUDOERS_DIR"
chmod 755 "$SUDOERS_DIR"

cat > "$SUDOERS_FILE" << EOF
$USERNAME ALL=(ALL) NOPASSWD: ALL
EOF
chown root:root "$SUDOERS_FILE"
chmod 440 "$SUDOERS_FILE"

if visudo -cf "$SUDOERS_FILE"; then
    echo "Sudoers file valid."
else
    echo "Error in sudoers file!"
    exit 1
fi

echo "Configuring sshd_config Match block for $USERNAME..."

if ! grep -q "^[[:space:]]*Match User $USERNAME[[:space:]]*\$" "$SSHD_CONFIG"; then
    cat >> "$SSHD_CONFIG" << EOF

# Ansible user restrictions (added $(date))
Match User $USERNAME
    PasswordAuthentication no
    PubkeyAuthentication yes
    X11Forwarding no
    AllowTcpForwarding no
    PermitTTY no
EOF
    
    echo "Match block added."
    
    # Proper validation with Match context
    if sshd -T -f "$SSHD_CONFIG" -C "user=$USERNAME"; then
        echo "sshd_config valid for $USERNAME."
        systemctl reload ssh || systemctl restart sshd || service ssh restart
        echo "SSH reloaded."
    else
        echo "sshd_config syntax error! Revert changes or check manually."
        exit 1
    fi
else
    echo "Match block already exists."
fi

