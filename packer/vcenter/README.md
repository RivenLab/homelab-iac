<!-- markdownlint-disable first-line-h1 no-inline-html -->

## Linux Distributions

| Operating System             | Version   |
|:-----------------------------|:----------|
| Debian                       | 13        |
|                              | 12        |
| Ubuntu Server                | 24.04 LTS |
| Red Hat Enterprise Linux     | 9         |

## Microsoft Windows

| Operating System         | Version | Editions                    | Experience       |
|:-------------------------| :---    | :---                        | :---             |
| Microsoft Windows Server | 2025    | Standard and Datacenter     | Core and Desktop |
|                          | 2022    | Standard and Datacenter     | Core and Desktop |
|                          | 2019    | Standard and Datacenter     | Core and Desktop |
| Microsoft Windows        | 11      | Professional and Enterprise | -                |

## Documentation

### Requirements
```
ansible-core	>= 2.16
git	        >= 2.43.0
gomplate	>= 4.3.0
jq		>= 1.8.3
terraform	>= 1.10.0
xorriso		>= 1.5.6

python3-pywinrm
python3-requests
```

### Installation

Packages:
```bash
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y python3 python3-pip ansible git jq xorriso whois unzip terraform
echo "ansible-core $(ansible --version | grep 'ansible.*core' | awk '{print $3}' | tr -d ']')"
echo "terraform $(terraform version | awk -Fv '{print $2}' | head -n 1)"
export PATH="$HOME/.local/bin:$PATH"
```

Python3 Library :
```bash
pipx inject ansible pywinrm requests
```

Gomplate:
```bash
export GOMPLATE_VERSION="4.3.0"
wget -q https://github.com/hairyhenderson/gomplate/releases/download/v${GOMPLATE_VERSION}/gomplate_linux-amd64
chmod +x gomplate_linux-amd64
sudo mv gomplate_linux-amd64 /usr/local/bin/gomplate

```
