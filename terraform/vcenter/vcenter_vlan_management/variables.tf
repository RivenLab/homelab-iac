# variables.tf
# Credentials
variable "vsphere_server" {
  type = string
  description = "vCenter server FQDN or IP"
}

variable "vsphere_username" {
  type      = string
  sensitive = true
  description = "vCenter username"
}

variable "vsphere_password" {
  type      = string
  sensitive = true
  description = "vCenter password"
}

variable "vsphere_insecure" {
  type    = bool
  default = true
  description = "Allow insecure connections to the vCenter server"
}

# vSphere Settings
#variable "vsphere_datacenter" {
#  type = string
#  description = "Name of the vSphere datacenter"
#}

#variable "esxi_hosts" {
#  type = list(string)
#  description = "List of ESXi hosts to configure"
#}

variable "datacenters" {
  type        = list(string)
  description = "List of vSphere datacenters"
}

variable "esxi_hosts_by_dc" {
  type        = map(list(string))
  description = "Map of datacenter names to lists of ESXi hosts in each datacenter"
}

variable "virtual_switch_name" {
  type = string
  description = "Name of the virtual switch to use"
  default = "vSwitch0"
}

variable "vlans" {
  type = map(number)
  description = "Map of VLAN names to VLAN IDs"
}
