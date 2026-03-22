# output.tf

# Output information about all created port groups
output "port_groups" {
  value = {
    for k, pg in vsphere_host_port_group.vlans : k => {
      name      = pg.name
      datacenter = split("-", k)[0]
      host      = split("-", k)[1]
      vlan_id   = pg.vlan_id
      key       = pg.key
    }
  }
  description = "Details of all created port groups"
}

# Output count of VLANs created per host
output "vlans_per_host" {
  value = {
    for pair in flatten([
      for dc, hosts in var.esxi_hosts_by_dc : [
        for host in hosts : {
          key = "${dc}-${host}"
          dc = dc
          host = host
        }
      ]
    ]) : pair.key => length([
      for k, pg in vsphere_host_port_group.vlans : pg if startswith(k, "${pair.dc}-${pair.host}")
    ])
  }
  description = "Number of VLANs created on each host"
}

# Output VLANs by datacenter
output "vlans_by_datacenter" {
  value = {
    for dc in var.datacenters : dc => length([
      for k, pg in vsphere_host_port_group.vlans : pg if split("-", k)[0] == dc
    ])
  }
  description = "Number of VLANs created in each datacenter"
}

# Output summary statistics
output "summary" {
  value = {
    total_port_groups = length(vsphere_host_port_group.vlans)
    total_datacenters = length(var.datacenters)
    total_hosts       = sum([for dc, hosts in var.esxi_hosts_by_dc : length(hosts)])
    total_vlans       = length(var.vlans)
    port_groups_per_datacenter = {
      for dc in var.datacenters : dc => length([
        for k, pg in vsphere_host_port_group.vlans : pg if split("-", k)[0] == dc
      ])
    }
  }
  description = "Summary statistics about the deployment"
}

# List all unique VLAN IDs in use
output "vlan_ids" {
  value = distinct([for vlan in vsphere_host_port_group.vlans : vlan.vlan_id])
  description = "List of all unique VLAN IDs in use"
}
