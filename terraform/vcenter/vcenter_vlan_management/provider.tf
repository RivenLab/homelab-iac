provider "vsphere" {
  vsphere_server       = var.vsphere_server
  user                 = var.vsphere_username
  password             = var.vsphere_password
  allow_unverified_ssl = var.vsphere_insecure
}

# 1 datacenter
#data "vsphere_datacenter" "datacenter" {
#  name = var.vsphere_datacenter
#}

# Get all ESXi hosts in the datacenter
#data "vsphere_host" "hosts" {
#  for_each      = toset(var.esxi_hosts)
#  name          = each.key
#  datacenter_id = data.vsphere_datacenter.datacenter.id
#}



data "vsphere_datacenter" "datacenters" {
  for_each = toset(var.datacenters)
  name     = each.key
}

data "vsphere_host" "hosts" {
  for_each = {
    for pair in flatten([
      for dc_name, hosts in var.esxi_hosts_by_dc : [
        for host in hosts : {
          dc   = dc_name
          host = host
        }
      ]
    ]) : "${pair.dc}-${pair.host}" => pair
  }
  
  name          = each.value.host
  datacenter_id = data.vsphere_datacenter.datacenters[each.value.dc].id
}
