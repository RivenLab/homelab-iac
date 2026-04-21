





### Lunch
esxi1
```bash
ansible-playbook -i inventory/windows.ini playbooks/deploy_windows.yml -e @group_vars/esx1.yml
```
esxi2
```bash
ansible-playbook -i inventory/windows.ini playbooks/deploy_windows.yml -e @group_vars/esx2.yml
```
