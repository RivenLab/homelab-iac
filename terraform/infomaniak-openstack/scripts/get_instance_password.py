#!/usr/bin/env python3

import subprocess
import json
import sys
from concurrent.futures import ThreadPoolExecutor

def get_instances(image_filter):
    """Fetch instances for a given image filter using OpenStack CLI."""
    try:
        result = subprocess.run(
            ["openstack", "server", "list", "--image", image_filter, "-f", "json"],
            capture_output=True, text=True, timeout=60
        )
        if result.returncode != 0:
            print(f"Warning: Could not fetch {image_filter} instances: {result.stderr.strip()}")
            return []

        servers = json.loads(result.stdout)
        return [(s["ID"], s["Name"], image_filter) for s in servers]
    except Exception as e:
        print(f"Error fetching {image_filter} instances: {e}")
        return []

def get_password(instance_id, key_path):
    """Retrieve and decrypt the instance password."""
    result = subprocess.run(
        ["openstack", "server", "password", "show", "--private-key", key_path, instance_id],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"Error retrieving password: {result.stderr.strip()}")
        sys.exit(1)
    return result.stdout.strip()

def main():
    print("Searching for OPNsense and Windows instances ...")

    # Fetch both image types IN PARALLEL
    with ThreadPoolExecutor(max_workers=2) as executor:
        future_opnsense = executor.submit(get_instances, "OPNsense")
        future_windows  = executor.submit(get_instances, "Windows")

    opnsense_instances = future_opnsense.result()
    windows_instances  = future_windows.result()

    # Combine results
    all_instances = opnsense_instances + windows_instances

    if not all_instances:
        print("No instances found with 'OPNsense' or 'Windows' images.")
        sys.exit(1)

    # Display the list
    print(f"\nFound {len(all_instances)} instance(s):\n")
    print(f"  {'#':<4} {'Type':<12} {'Name':<30} {'ID'}")
    print("  " + "-" * 75)

    for i, (inst_id, name, img_type) in enumerate(all_instances, start=1):
        tag = f"[{img_type}]"
        print(f"  {i:<4} {tag:<12} {name:<30} {inst_id}")

    print()

    # User selection with validation
    while True:
        try:
            choice = input(f"Select an instance [1-{len(all_instances)}]: ").strip()
            choice = int(choice)
            if 1 <= choice <= len(all_instances):
                break
            print(f"  Please enter a number between 1 and {len(all_instances)}.")
        except ValueError:
            print("  Invalid input. Please enter a number.")

    selected_id, selected_name, selected_type = all_instances[choice - 1]
    print(f"\nSelected: [{selected_type}] {selected_name} ({selected_id})")

    # Ask for SSH key path
    key_path = input("\nEnter the path to your SSH private key [~/.ssh/id_rsa]: ").strip()
    if not key_path:
        key_path = "~/.ssh/id_rsa"

    # Retrieve password
    print("\nRetrieving password...")
    password = get_password(selected_id, key_path)

    if password:
        print(f"\nPassword: {password}")
    else:
        print("\nNo password returned. The instance may not have a password set.")

if __name__ == "__main__":
    main()