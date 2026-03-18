resource "nxos_bridge_domain" "bridge_domain" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].system.svi_autostate, local.defaults.nxos.devices.configuration.system.svi_autostate, null) != null ||
  length(try(local.device_config[device.name].vlan.vlans, [])) > 0 }
  device        = each.key
  svi_autostate = try(local.device_config[each.key].system.svi_autostate, local.defaults.nxos.devices.configuration.system.svi_autostate, null) == null ? null : try(local.device_config[each.key].system.svi_autostate, local.defaults.nxos.devices.configuration.system.svi_autostate) ? "enable" : "disable"
  bridge_domains = { for vlan in try(local.device_config[each.key].vlan.vlans, []) : "vlan-${vlan.id}" => {
    access_encap = try(vlan.vni, local.defaults.nxos.devices.configuration.vlan.vlans.vni, null) != null ? "vxlan-${try(vlan.vni, local.defaults.nxos.devices.configuration.vlan.vlans.vni)}" : null
    name         = try(vlan.name, local.defaults.nxos.devices.configuration.vlan.vlans.name, null)
    admin_state  = try(vlan.admin_state, local.defaults.nxos.devices.configuration.vlan.vlans.admin_state, null) == null ? null : try(vlan.admin_state, local.defaults.nxos.devices.configuration.vlan.vlans.admin_state) ? "active" : "suspend"
    bridge_mode  = try(vlan.bridge_mode, local.defaults.nxos.devices.configuration.vlan.vlans.bridge_mode, null)
    control = join(",", sort(compact([
      try(vlan.policy_enforced, local.defaults.nxos.devices.configuration.vlan.vlans.policy_enforced, false) ? "policy-enforced" : "",
      try(vlan.untagged, local.defaults.nxos.devices.configuration.vlan.vlans.untagged, false) ? "untagged" : "",
    ])))
    forwarding_control = null
    forwarding_mode = join(",", sort(compact([
      try(vlan.forwarding_mode_bridge, local.defaults.nxos.devices.configuration.vlan.vlans.forwarding_mode_bridge, false) ? "bridge" : "",
      try(vlan.forwarding_mode_route, local.defaults.nxos.devices.configuration.vlan.vlans.forwarding_mode_route, false) ? "route" : "",
    ])))
    long_name           = try(vlan.long_name, local.defaults.nxos.devices.configuration.vlan.vlans.long_name, null)
    mac_packet_classify = try(vlan.mac_packet_classify, local.defaults.nxos.devices.configuration.vlan.vlans.mac_packet_classify, null) == null ? null : try(vlan.mac_packet_classify, local.defaults.nxos.devices.configuration.vlan.vlans.mac_packet_classify) ? "enable" : "disable"
    mode                = try(vlan.mode, local.defaults.nxos.devices.configuration.vlan.vlans.mode, null)
    vrf_name            = try(vlan.vrf, local.defaults.nxos.devices.configuration.vlan.vlans.vrf, null)
    cross_connect       = try(vlan.cross_connect, local.defaults.nxos.devices.configuration.vlan.vlans.cross_connect, null) == null ? null : try(vlan.cross_connect, local.defaults.nxos.devices.configuration.vlan.vlans.cross_connect) ? "enable" : "disable"
  } }

  depends_on = [
    nxos_feature.feature,
    nxos_vrf.vrf,
  ]
}
