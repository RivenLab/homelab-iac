# output.tf

# Output information about all created port groups
output "port_groups" {
  value = var.network_type == "standard" ? {
    for k, pg in vsphere_host_port_group.vlans : k => {
      name       = pg.name
      datacenter = split("-", k)[0]
      host       = split("-", k)[1]
      vlan_id    = pg.vlan_id
      key        = pg.key
    }
  } : {
    for k, pg in vsphere_distributed_port_group.dvs_vlans : k => {
      name       = pg.name
      datacenter = split("-", k)[0]
      vlan_id    = pg.vlan_id
      key        = pg.key
    }
  }
  description = "Details of all created port groups"
}

# Output count of VLANs created per host
output "vlans_per_host" {
  value = var.network_type == "standard" ? {
    for pair in flatten([
      for dc, hosts in var.esxi_hosts_by_dc : [
        for host in hosts : {
          key  = "${dc}-${host}"
          dc   = dc
          host = host
        }
      ]
    ]) : pair.key => length([
      for k, pg in vsphere_host_port_group.vlans : pg if startswith(k, "${pair.dc}-${pair.host}")
    ])
  } : {}
  description = "Number of VLANs created on each host (standard switch only)"
}

# Output VLANs by datacenter
output "vlans_by_datacenter" {
  value = {
    for dc in var.datacenters : dc => var.network_type == "standard" ? length([
      for k, pg in vsphere_host_port_group.vlans : pg if split("-", k)[0] == dc
    ]) : length([
      for k, pg in vsphere_distributed_port_group.dvs_vlans : pg if split("-", k)[0] == dc
    ])
  }
  description = "Number of VLANs created in each datacenter"
}

# Output summary statistics
output "summary" {
  value = {
    network_type      = var.network_type
    total_port_groups = var.network_type == "standard" ? length(vsphere_host_port_group.vlans) : length(vsphere_distributed_port_group.dvs_vlans)
    total_datacenters = length(var.datacenters)
    total_hosts       = var.network_type == "standard" ? sum([for dc, hosts in var.esxi_hosts_by_dc : length(hosts)]) : 0
    total_vlans       = length(var.vlans)
    port_groups_per_datacenter = {
      for dc in var.datacenters : dc => var.network_type == "standard" ? length([
        for k, pg in vsphere_host_port_group.vlans : pg if split("-", k)[0] == dc
      ]) : length([
        for k, pg in vsphere_distributed_port_group.dvs_vlans : pg if split("-", k)[0] == dc
      ])
    }
  }
  description = "Summary statistics about the deployment"
}

# List all unique VLAN IDs in use
output "vlan_ids" {
  value = distinct(var.network_type == "standard" ? [for vlan in vsphere_host_port_group.vlans : vlan.vlan_id] : [for vlan in vsphere_distributed_port_group.dvs_vlans : vlan.vlan_id])
  description = "List of all unique VLAN IDs in use"
}
