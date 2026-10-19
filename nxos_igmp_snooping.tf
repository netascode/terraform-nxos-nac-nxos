locals {
  # VLAN configurations with per-VLAN IGMP snooping settings (vlan configuration <id> > ip igmp snooping ..., layer-2 multicast lookup mac)
  igmp_snooping_vlans_map = { for device in local.devices : device.name => [
    for config in try(local.device_config[device.name].vlan.configurations, []) : config
    if try(config.igmp_snooping, null) != null || try(config.layer_2_multicast_lookup_mac, null) != null
  ] }
}

resource "nxos_igmp_snooping" "igmp_snooping" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].igmp_snooping, null) != null ||
  length(try(local.igmp_snooping_vlans_map[device.name], [])) > 0 }
  device                                     = each.key
  domain_control                             = try(local.device_config[each.key].igmp_snooping.optimise_multicast_flood, null) == null ? null : (try(local.device_config[each.key].igmp_snooping.optimise_multicast_flood) ? "opt-flood" : "")
  global_vlan_vxlan                          = try(local.device_config[each.key].igmp_snooping.vxlan, null)
  global_vlan_disable_nve_static_router_port = try(local.device_config[each.key].igmp_snooping.disable_nve_static_router_port, null)
  global_vlan_vxlan_umc_drop_vlan            = try(local.device_config[each.key].igmp_snooping.vxlan_umc_drop_vlan, null) != null ? try(provider::utils::normalize_vlans(try(local.device_config[each.key].igmp_snooping.vxlan_umc_drop_vlan), "string-nxos"), null) : null
  vlans = length(try(local.igmp_snooping_vlans_map[each.key], [])) > 0 ? { for config in local.igmp_snooping_vlans_map[each.key] : "vlan${config.id}" => {
    report_flood_all_interfaces   = try(config.igmp_snooping.report_flood_all, null)
    explicit_tracking             = try(config.igmp_snooping.explicit_tracking, null)
    igmp_snooping                 = try(config.igmp_snooping.enable, null)
    link_local_groups_suppression = try(config.igmp_snooping.link_local_groups_suppression, null)
    lookup_mac                    = try(config.layer_2_multicast_lookup_mac, null)
    query_flood                   = try(config.igmp_snooping.query_flood, null)
    report_suppression            = try(config.igmp_snooping.report_suppression, null)
    v3_report_suppression         = try(config.igmp_snooping.v3_report_suppression, null)
    querier_address               = try(config.igmp_snooping.querier, null)
    last_member_query_interval    = try(config.igmp_snooping.last_member_query_interval, null)
    query_interval                = try(config.igmp_snooping.query_interval, null)
    robustness_variable           = try(config.igmp_snooping.robustness_variable, null)
    query_max_response_time       = try(config.igmp_snooping.query_max_response_time, null)
    startup_query_count           = try(config.igmp_snooping.startup_query_count, null)
    startup_query_interval        = try(config.igmp_snooping.startup_query_interval, null)
    querier_timeout               = try(config.igmp_snooping.querier_timeout, null)
    version                       = try(config.igmp_snooping.version, null) != null ? "v${try(config.igmp_snooping.version)}" : null
    fast_leave                    = try(config.igmp_snooping.fast_leave, null)
    group_timeout                 = try(config.igmp_snooping.group_timeout, null)
    proxy_leave_use_group_address = try(config.igmp_snooping.proxy_leave_use_group_address, null)
    proxy_max_response_time       = try(config.igmp_snooping.proxy_general_queries_mrt, null)
    access_group_route_map        = try(config.igmp_snooping.access_group, null)
    mrouter_interfaces = length(try(config.igmp_snooping.mrouter_interfaces, [])) > 0 ? { for intf in try(config.igmp_snooping.mrouter_interfaces, []) :
      "${local.intf_prefix_map[intf.interface_type]}${intf.interface_id}" => {}
    } : null
    # Data model entries are keyed by group and source: entries without a source carry the group interfaces, entries with
    # a source the source interfaces of that group
    static_groups = length(try(config.igmp_snooping.static_groups, [])) > 0 ? { for group in distinct([for sg in try(config.igmp_snooping.static_groups, []) : sg.group]) : group => {
      interfaces = length(flatten([for sg in config.igmp_snooping.static_groups : try(sg.interfaces, []) if sg.group == group && try(sg.source, null) == null])) > 0 ? { for intf in flatten([for sg in config.igmp_snooping.static_groups : try(sg.interfaces, []) if sg.group == group && try(sg.source, null) == null]) :
        "${local.intf_prefix_map[intf.interface_type]}${intf.interface_id}" => {}
      } : null
      sources = length([for sg in config.igmp_snooping.static_groups : sg if sg.group == group && try(sg.source, null) != null]) > 0 ? { for sg in config.igmp_snooping.static_groups : sg.source => {
        interfaces = length(try(sg.interfaces, [])) > 0 ? { for intf in sg.interfaces : "${local.intf_prefix_map[intf.interface_type]}${intf.interface_id}" => {} } : null
      } if sg.group == group && try(sg.source, null) != null } : null
    } } : null
    report_flood_interfaces = length(try(config.igmp_snooping.report_flood_interfaces, [])) > 0 ? { for intf in try(config.igmp_snooping.report_flood_interfaces, []) :
      "${local.intf_prefix_map[intf.interface_type]}${intf.interface_id}" => {
        report_flood = true
      }
    } : null
  } } : null

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
    nxos_bridge_domain.bridge_domain,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
  ]
}
