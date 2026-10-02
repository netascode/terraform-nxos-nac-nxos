resource "nxos_igmp_snooping" "igmp_snooping" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].igmp_snooping, null) != null }
  device                                     = each.key
  domain_control                             = try(local.device_config[each.key].igmp_snooping.optimise_multicast_flood, null) == null ? null : (try(local.device_config[each.key].igmp_snooping.optimise_multicast_flood) ? "opt-flood" : "")
  global_vlan_vxlan                          = try(local.device_config[each.key].igmp_snooping.vxlan, null)
  global_vlan_disable_nve_static_router_port = try(local.device_config[each.key].igmp_snooping.disable_nve_static_router_port, null)
  global_vlan_vxlan_umc_drop_vlan            = try(local.device_config[each.key].igmp_snooping.vxlan_umc_drop_vlan, null) != null ? try(provider::utils::normalize_vlans(try(local.device_config[each.key].igmp_snooping.vxlan_umc_drop_vlan), "string-nxos"), null) : null

  depends_on = [
    nxos_feature.feature,
  ]
}
