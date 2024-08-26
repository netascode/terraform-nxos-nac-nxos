locals {
  vlans = flatten([
    for device in local.devices : [
      for vlan in try(local.device_config[device.name].vlans, []) : {
        key    = format("%s/%s", device.name, vlan.id)
        device = device.name
        id     = vlan.id
        vni    = try(vlan.vni, local.defaults.nxos.devices.configuration.vlans.vni, null)
        name   = try(vlan.name, local.defaults.nxos.devices.configuration.vlans.name, null)
      }
    ]
  ])
}

resource "nxos_bridge_domain" "bridge_domain" {
  for_each = { for v in local.vlans : v.key => v }

  device       = each.value.device
  fabric_encap = "vlan-${each.value.id}"
  access_encap = each.value.vni != null ? "vxlan-${each.value.vni}" : null
  name         = each.value.name
}
