# Homelab IAC

Infrastructure as Code for my homelab: Proxmox, vCenter, Docker, storage & monitoring automation using **Ansible**, **Packer** & **Terraform**.

---

## Ansible

All Ansible projects for homelab configuration & automation.

- [clone-proxmox-vm](ansible/clone-proxmox-vm/) – Automated Proxmox VM cloning from templates
- [clone-vcenter-vm](ansible/clone-vcenter-vm/) – Automated VMware vCenter VM cloning
- [docker-swarm-haproxy](ansible/docker-swarm-haproxy/) – Docker Swarm cluster + HAProxy frontend
- [glusterfs-cluster](ansible/glusterfs-cluster/) – Distributed GlusterFS storage cluster
- [postgresql-cluster](ansible/postgresql-cluster/) – Highly available PostgreSQL cluster
- [zabbix](ansible/zabbix/) – Zabbix monitoring installation & configuration
- [create-ansible-user.sh](ansible/create-ansible-user.sh) – Ansible user setup script

---

## Packer

All Packer projects for building VM templates & images.

- [vcenter](packer/vcenter/) – VMware vCenter VM templates for Terraform/Ansible
- [vcenter-archive](packer/vcenter-archive/) – Archived vCenter template versions

---

## Terraform

All Terraform projects for infrastructure provisioning.

- [proxmox](terraform/proxmox/) – Proxmox VM & resource provisioning
- [vcenter](terraform/vcenter/) – VMware vCenter VM & resource provisioning
- [README](terraform/README.md) – Terraform usage details & examples

---

## Notes

- Central repo for entire homelab Infrastructure as Code
- Each subfolder has its own README/documentation (WIP)
- Goal: Rebuild complete homelab from this repository
