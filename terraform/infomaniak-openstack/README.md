# Prerequisites
```
- terraform
- openstack
- nova cli
```

## Install OpenStack CLI
```bash
pipx install python-openstackclient
```
## Install Nova CLI
```bash
pipx install python-novaclient
```

## Source openrc.sh file
```bash
source openrc.sh
```

### Retrieve OPNsense password
```bash
bash scripts/get_opensense_password.sh
```

## Terraform commands

### 1. Init
```bash
terraform init
```

### 2. Plan
```bash
terraform plan
```

### 3. Apply
```bash
terraform apply -auto-approve
```

### 4. Output
```bash
terraform output
```

### 5. To Destroy
```bash
terraform destroy -auto-approve
```