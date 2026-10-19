locals {
  bridge_domain_mode_map = {
    "ce"         = "CE"
    "fabricpath" = "FabricPath"
  }
}

resource "nxos_bridge_domain" "bridge_domain" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].system.interface_vlan_autostate, null) != null ||
    length(try(local.device_config[device.name].vlan.vlans, [])) > 0 ||
  length(try(local.device_config[device.name].vlan.configurations, [])) > 0 }
  device        = each.key
  svi_autostate = try(local.device_config[each.key].system.interface_vlan_autostate, null) == null ? null : try(local.device_config[each.key].system.interface_vlan_autostate) ? "enable" : "disable"
  bridge_domains = length(try(local.device_config[each.key].vlan.vlans, [])) > 0 ? { for vlan in try(local.device_config[each.key].vlan.vlans, []) : "vlan-${vlan.id}" => {
    access_encap = try(vlan.vn_segment, null) != null ? "vxlan-${try(vlan.vn_segment)}" : null
    name         = try(vlan.name, null)
    admin_state  = try(vlan.state_active, null) == null ? null : try(vlan.state_active) ? "active" : "suspend"
    bridge_mode  = try(vlan.bridge_mode, null)
    control = length(compact([
      try(vlan.policy_enforce_vlan, false) ? "policy-enforced" : "",
      try(vlan.untagged, false) ? "untagged" : "",
      ])) > 0 ? join(",", sort(compact([
        try(vlan.policy_enforce_vlan, false) ? "policy-enforced" : "",
        try(vlan.untagged, false) ? "untagged" : "",
    ]))) : null
    forwarding_mode     = null
    long_name           = try(vlan.long_name, null)
    mac_packet_classify = try(vlan.mac_packet_classify, null) == null ? null : try(vlan.mac_packet_classify) ? "enable" : "disable"
    mode                = try(local.bridge_domain_mode_map[try(vlan.mode)], null)
    vrf_name            = try(vlan.vrf, null)
    cross_connect       = try(vlan.cross_connect, null) == null ? null : try(vlan.cross_connect) ? "enable" : "disable"
    isolate             = try(vlan.isolate, null)
  } } : null
  # Every VLAN configuration is created here, as nxos_igmp_snooping requires the vlan configuration to exist
  vlan_configurations = length(try(local.device_config[each.key].vlan.configurations, [])) > 0 ? { for config in try(local.device_config[each.key].vlan.configurations, []) : "vlan-${config.id}" => {
    mac_learning = try(config.mac_learn, null) == null ? null : try(config.mac_learn) ? "enable" : "disable"
  } } : null

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
    nxos_vrf.vrf,
    nxos_spanning_tree.spanning_tree,
  ]
}
