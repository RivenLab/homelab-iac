# © Broadcom. All Rights Reserved.
# The term “Broadcom” refers to Broadcom Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-2-Clause

# Red Hat Enterprise Linux Server 9

### Installs from the first attached CD-ROM/DVD on the system.
cdrom

### Performs the kickstart installation in text mode.
### By default, kickstart installations are performed in graphical mode.
text

### Accepts the End User License Agreement.
eula --agreed

### Sets the language to use during installation and the default language to use on the installed system.
lang ${vm_guest_os_language}

### Sets the default keyboard type for the system.
keyboard ${vm_guest_os_keyboard}

### Configure network information for target system and activate network devices in the installer environment (optional)
### --onboot	  enable device at a boot time
### --device	  device to be activated and / or configured with the network command
### --bootproto	  method to obtain networking configuration for device (default dhcp)
### --noipv6	  disable IPv6 on this device
${network}

### Lock the root account.
rootpw --lock

### The selected profile will restrict root login.
### Add a user that can login and escalate privileges.
user --name=${build_username} --iscrypted --password=${build_password_encrypted} --groups=wheel

### Configure firewall settings for the system.
### --enabled	reject incoming connections that are not in response to outbound requests
### --ssh		allow sshd service through the firewall
firewall --enabled --ssh

### Sets up the authentication options for the system.
### The SSDD profile sets sha512 to hash passwords. Passwords are shadowed by default
### See the manual page for authselect-profile for a complete list of possible options.
authselect select sssd

### Sets the state of SELinux on the installed system.
### Defaults to enforcing.
selinux --enforcing

### Sets the system time zone.
timezone ${vm_guest_os_timezone}

### Partitioning
${storage}

### Modifies the default set of services that will run under the default runlevel.
services --enabled=NetworkManager,sshd

### Do not configure X on the installed system.
skipx

### Packages selection.
%packages --ignoremissing --excludedocs
@core
-iwl*firmware
%end

### Post-installation commands.
%post
# --- DEBUG: Verify that Packer passed RHSM variables ---
echo "RHSM_USER=${rhsm_username}" > /root/ks_vars.log
echo "RHSM_PASS=${rhsm_password}" >> /root/ks_vars.log
echo "BUILD_USER=${build_username}" >> /root/ks_vars.log


# --- Register the system with Red Hat Subscription ---
if [ -n "${rhsm_username}" ] && [ -n "${rhsm_password}" ]; then
  /usr/sbin/subscription-manager register --username ${rhsm_username} --password '${rhsm_password}' --autosubscribe --force

  # Enable all repos needed for standard packages
  /usr/sbin/subscription-manager repos --enable "rhel-9-for-x86_64-baseos-rpms"
  /usr/sbin/subscription-manager repos --enable "rhel-9-for-x86_64-appstream-rpms"
  /usr/sbin/subscription-manager repos --enable "codeready-builder-for-rhel-9-x86_64-rpms"

  # Refresh package metadata
  dnf makecache
else
  echo "RHSM credentials not set. Skipping registration." >> /tmp/ks_vars.log
fi

# --- Install basic packages (ensure these exist for Ansible later) ---
dnf install -y sudo open-vm-tools perl git vim wget unzip net-tools

# --- Install EPEL if needed for extra packages ---
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
dnf makecache

# --- Install additional packages from Packer variable ---
%{ if additional_packages != "" ~}
dnf install -y ${additional_packages}
%{ endif ~}

# --- Setup sudoers ---
echo "${build_username} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${build_username}
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

%end

# Reboot automatically after installation
reboot --eject
