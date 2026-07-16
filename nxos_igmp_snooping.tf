resource "nxos_igmp_snooping" "igmp_snooping" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].igmp_snooping, null) != null }
  device = each.key

  # igmpsnoopEntity / igmpsnoopInst admin state (CLI: ip igmp snooping)
  admin_state          = try(local.device_config[each.key].igmp_snooping.enable, null) == null ? null : (try(local.device_config[each.key].igmp_snooping.enable) ? "enabled" : "disabled")
  instance_admin_state = try(local.device_config[each.key].igmp_snooping.enable, null) == null ? null : (try(local.device_config[each.key].igmp_snooping.enable) ? "enabled" : "disabled")

  # igmpsnoopInst.ctrl bitmask (only value: stateful-ha)
  instance_control = try(local.device_config[each.key].igmp_snooping.stateful_ha, null) == null ? null : (try(local.device_config[each.key].igmp_snooping.stateful_ha) ? "stateful-ha" : null)

  # igmpsnoopDom.ctrl bitmask (querier / opt-flood / routing — comma-separated)
  domain_control = (
    try(local.device_config[each.key].igmp_snooping.querier, false) ||
    try(local.device_config[each.key].igmp_snooping.optimised_multicast_flood, false) ||
    try(local.device_config[each.key].igmp_snooping.routing, false)
    ) ? join(",", sort(compact([
      try(local.device_config[each.key].igmp_snooping.querier, false) ? "querier" : "",
      try(local.device_config[each.key].igmp_snooping.optimised_multicast_flood, false) ? "opt-flood" : "",
      try(local.device_config[each.key].igmp_snooping.routing, false) ? "routing" : "",
  ]))) : null

  # igmpsnoopGVlan attributes (VXLAN snooping + NVE static router port)
  global_vlan_vxlan                          = try(local.device_config[each.key].igmp_snooping.vxlan, null)
  global_vlan_disable_nve_static_router_port = try(local.device_config[each.key].igmp_snooping.disable_nve_static_router_port, null)
  global_vlan_vxlan_umc_drop_vlan            = try(local.device_config[each.key].igmp_snooping.vxlan_unknown_multicast_drop_vlans, null)

  depends_on = [
    nxos_feature.feature,
  ]
}
