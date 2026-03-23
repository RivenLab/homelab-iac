resource "vsphere_host_port_group" "vlans" {
  for_each = var.network_type == "standard" ? {
    for pair in flatten([
      for dc_name, hosts in var.esxi_hosts_by_dc : [
        for combo in setproduct(hosts, keys(var.vlans)) : {
          dc       = dc_name
          host     = combo[0]
          vlan_name = combo[1]
          vlan_id  = var.vlans[combo[1]]
        }
      ]
    ]) : "${pair.dc}-${pair.host}-${pair.vlan_name}" => pair
  } : {}

  name                = each.value.vlan_name
  host_system_id      = data.vsphere_host.hosts["${each.value.dc}-${each.value.host}"].id
  virtual_switch_name = var.virtual_switch_name
  vlan_id             = each.value.vlan_id
}

resource "vsphere_distributed_port_group" "dvs_vlans" {
  for_each = var.network_type == "distributed" ? {
    for pair in flatten([
      for dc_name in var.datacenters : [
        for vlan_name, vlan_id in var.vlans : {
          dc        = dc_name
          vlan_name = vlan_name
          vlan_id   = vlan_id
        }
      ]
    ]) : "${pair.dc}-${pair.vlan_name}" => pair
  } : {}

  name                            = each.value.vlan_name
  vlan_id                         = each.value.vlan_id
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.dvs[each.value.dc].id
}
