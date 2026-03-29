#!/bin/bash

# 1. List all instances using "OPNsense" or "Windows" images
echo "Searching for instances launched from 'OPNsense' or 'Windows' images..."

# Gather instances for both image types
mapfile -t OPNSENSE_IDS < <(openstack server list --image OPNsense -f value -c ID -c Name 2>/dev/null)
mapfile -t WINDOWS_IDS < <(openstack server list --image Windows -f value -c ID -c Name 2>/dev/null)

# Build a combined list with labels
declare -a ALL_INSTANCES
declare -a ALL_LABELS

while IFS= read -r line; do
    id=$(echo "$line" | awk '{print $1}')
    name=$(echo "$line" | awk '{print $2}')
    ALL_INSTANCES+=("$id")
    ALL_LABELS+=("[OPNsense] $name ($id)")
done < <(openstack server list --image OPNsense -f value -c ID -c Name 2>/dev/null)

while IFS= read -r line; do
    id=$(echo "$line" | awk '{print $1}')
    name=$(echo "$line" | awk '{print $2}')
    ALL_INSTANCES+=("$id")
    ALL_LABELS+=("[Windows]  $name ($id)")
done < <(openstack server list --image Windows -f value -c ID -c Name 2>/dev/null)

# Check if any instances were found
if [ ${#ALL_INSTANCES[@]} -eq 0 ]; then
    echo "Error: No instances found with 'OPNsense' or 'Windows' images."
    exit 1
fi

# 2. Display the list and let the user choose
echo ""
echo "Found the following instances:"
echo "----------------------------------------------"
for i in "${!ALL_LABELS[@]}"; do
    echo "  $((i+1))) ${ALL_LABELS[$i]}"
done
echo "----------------------------------------------"

while true; do
    read -p "Select an instance [1-${#ALL_INSTANCES[@]}]: " SELECTION
    if [[ "$SELECTION" =~ ^[0-9]+$ ]] && [ "$SELECTION" -ge 1 ] && [ "$SELECTION" -le "${#ALL_INSTANCES[@]}" ]; then
        break
    else
        echo "Invalid selection. Please enter a number between 1 and ${#ALL_INSTANCES[@]}."
    fi
done

INSTANCE_ID="${ALL_INSTANCES[$((SELECTION-1))]}"
echo ""
echo "Selected: ${ALL_LABELS[$((SELECTION-1))]}"

# 3. Ask user for the path to the SSH private key
read -p "Enter the path to your SSH private key [~/.ssh/id_rsa]: " KEY_PATH
KEY_PATH=${KEY_PATH:-~/.ssh/id_rsa}

# 4. Retrieve and decrypt the password
echo "Retrieving password..."
openstack server password show --private-key "$KEY_PATH" "$INSTANCE_ID"