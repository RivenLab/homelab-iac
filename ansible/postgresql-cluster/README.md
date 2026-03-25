## PostgreSQL 2-Node Cluster Setup

This repository was designed to deploy a PostgreSQL cluster with 2 nodes only.
It provides an automated setup using Ansible to simplify installation, configuration, and management.

## Inspiration

This project was inspired by the following repository:
https://github.com/rom8726/ansible-patroni-ssl/tree/main


### Notes

The setup supports exactly two nodes or plus
Adjust configurations as needed for your environment
Tested only on Ubuntu 24.04




### Start playbook
```bash
ansible-playbook -i inventory.ini playbook.yml
```
