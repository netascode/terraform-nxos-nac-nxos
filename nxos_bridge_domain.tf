resource "nxos_bridge_domain" "bridge_domain" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].system.svi_autostate, local.defaults.nxos.devices.configuration.system.svi_autostate, null) != null ||
  length(try(local.device_config[device.name].vlans, [])) > 0 }
  device        = each.key
  svi_autostate = try(local.device_config[each.key].system.svi_autostate, local.defaults.nxos.devices.configuration.system.svi_autostate, null)
  bridge_domains = { for vlan in try(local.device_config[each.key].vlans, []) : "vlan-${vlan.id}" => {
    access_encap = try(vlan.vni, local.defaults.nxos.devices.configuration.vlans.vni, null) != null ? "vxlan-${try(vlan.vni, local.defaults.nxos.devices.configuration.vlans.vni)}" : null
    name         = try(vlan.name, local.defaults.nxos.devices.configuration.vlans.name, null)
    admin_state  = try(vlan.admin_state, local.defaults.nxos.devices.configuration.vlans.admin_state, null)
    bridge_mode  = try(vlan.bridge_mode, local.defaults.nxos.devices.configuration.vlans.bridge_mode, null)
    control = join(",", sort(compact([
      try(vlan.policy_enforced, local.defaults.nxos.devices.configuration.vlans.policy_enforced, false) ? "policy-enforced" : "",
      try(vlan.untagged, local.defaults.nxos.devices.configuration.vlans.untagged, false) ? "untagged" : "",
    ])))
    forwarding_control = join(",", sort(compact([
      try(vlan.arp_flood, local.defaults.nxos.devices.configuration.vlans.arp_flood, false) ? "arp-flood" : "",
      try(vlan.multicast_flood, local.defaults.nxos.devices.configuration.vlans.multicast_flood, false) ? "mdst-flood" : "",
    ])))
    forwarding_mode = join(",", sort(compact([
      try(vlan.forwarding_mode_bridge, local.defaults.nxos.devices.configuration.vlans.forwarding_mode_bridge, false) ? "bridge" : "",
      try(vlan.forwarding_mode_route, local.defaults.nxos.devices.configuration.vlans.forwarding_mode_route, false) ? "route" : "",
    ])))
    long_name           = try(vlan.long_name, local.defaults.nxos.devices.configuration.vlans.long_name, null)
    mac_packet_classify = try(vlan.mac_packet_classify, local.defaults.nxos.devices.configuration.vlans.mac_packet_classify, null)
    mode                = try(vlan.mode, local.defaults.nxos.devices.configuration.vlans.mode, null)
    vrf_name            = try(vlan.vrf, local.defaults.nxos.devices.configuration.vlans.vrf, null)
    cross_connect       = try(vlan.cross_connect, local.defaults.nxos.devices.configuration.vlans.cross_connect, null)
  } }
}
