resource "nxos_bridge_domain" "bridge_domain" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].system.svi_autostate, local.defaults.nxos.devices.configuration.system.svi_autostate, null) != null ||
  length(try(local.device_config[device.name].vlans, [])) > 0 }
  device        = each.key
  svi_autostate = try(local.device_config[each.key].system.svi_autostate, local.defaults.nxos.devices.configuration.system.svi_autostate, null)
  bridge_domains = { for vlan in try(local.device_config[each.key].vlans, []) : "vlan-${vlan.id}" => {
    access_encap        = try(vlan.vni, local.defaults.nxos.devices.configuration.vlans.vni, null) != null ? "vxlan-${try(vlan.vni, local.defaults.nxos.devices.configuration.vlans.vni)}" : null
    name                = try(vlan.name, local.defaults.nxos.devices.configuration.vlans.name, null)
    bridge_domain_state = try(vlan.bridge_domain_state, local.defaults.nxos.devices.configuration.vlans.bridge_domain_state, null)
    admin_state         = try(vlan.admin_state, local.defaults.nxos.devices.configuration.vlans.admin_state, null)
    bridge_mode         = try(vlan.bridge_mode, local.defaults.nxos.devices.configuration.vlans.bridge_mode, null)
    control             = try(vlan.control, local.defaults.nxos.devices.configuration.vlans.control, null)
    forwarding_control  = try(vlan.forwarding_control, local.defaults.nxos.devices.configuration.vlans.forwarding_control, null)
    forwarding_mode     = try(vlan.forwarding_mode, local.defaults.nxos.devices.configuration.vlans.forwarding_mode, null)
    long_name           = try(vlan.long_name, local.defaults.nxos.devices.configuration.vlans.long_name, null)
    mac_packet_classify = try(vlan.mac_packet_classify, local.defaults.nxos.devices.configuration.vlans.mac_packet_classify, null)
    mode                = try(vlan.mode, local.defaults.nxos.devices.configuration.vlans.mode, null)
    vrf_name            = try(vlan.vrf_name, local.defaults.nxos.devices.configuration.vlans.vrf_name, null)
    cross_connect       = try(vlan.cross_connect, local.defaults.nxos.devices.configuration.vlans.cross_connect, null)
  } }
}
