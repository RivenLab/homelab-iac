### RUN :
ansible-playbook playbook.yml --tags packages
ansible-playbook playbook.yml --tags config,service


### PSK retation :
ansible-playbook playbook.yml -i inventory/hosts.yml --tags config -e zabbix_agent_rotate_psk=true


### Add Zabbix
ansible-playbook -i inventory/hosts.yml playbook.yml --tags config,zabbix_api