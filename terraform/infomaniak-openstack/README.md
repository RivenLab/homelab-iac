# Prerequisites
```
- terraform
- openstack
- nova cli
```
---
# 1 Installation
## Install OpenStack CLI
```bash
pipx install python-openstackclient
```
## Install Nova CLI
```bash
pipx install python-novaclient
```
---
# 2 Load environment variables
## Source openrc.sh file
```bash
source load_env/openrc.sh
```

## Load Source s3-env.sh
```bash
source load_env/s3-env.sh
```

---
# 3 Run Terraform commands
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

---
# 4 Retrieve OPNsense password
```bash
bash scripts/get_instance_password.sh
```