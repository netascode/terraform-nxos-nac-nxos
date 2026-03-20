resource "nxos_route_policy" "route_policy" {
  for_each = { for device in local.devices : device.name => device
    if length(try(local.device_config[device.name].ip_prefix_lists, [])) > 0 ||
  length(try(local.device_config[device.name].route_maps, [])) > 0 }
  device = each.key

  ipv4_prefix_lists = { for pl in try(local.device_config[each.key].ip_prefix_lists, []) : pl.name => {
    description = try(pl.description, local.defaults.nxos.devices.configuration.ip_prefix_lists.description, null)

    entries = { for entry in try(pl.entries, []) : entry.seq => {
      action     = try(entry.action, local.defaults.nxos.devices.configuration.ip_prefix_lists.entries.action, null)
      criteria   = try(entry.criteria, local.defaults.nxos.devices.configuration.ip_prefix_lists.entries.criteria, null)
      prefix     = try(entry.prefix, local.defaults.nxos.devices.configuration.ip_prefix_lists.entries.prefix, null)
      from_range = try(entry.ge, local.defaults.nxos.devices.configuration.ip_prefix_lists.entries.ge, null)
      to_range   = try(entry.le, local.defaults.nxos.devices.configuration.ip_prefix_lists.entries.le, null)
      mask       = try(entry.mask, local.defaults.nxos.devices.configuration.ip_prefix_lists.entries.mask, null)
    } }
  } }

  route_maps = { for rm in try(local.device_config[each.key].route_maps, []) : rm.name => {
    pbr_statistics = try(rm.pbr_statistics, local.defaults.nxos.devices.configuration.route_maps.pbr_statistics, null) != null ? (try(rm.pbr_statistics, local.defaults.nxos.devices.configuration.route_maps.pbr_statistics) ? "enabled" : "disabled") : null

    entries = { for entry in try(rm.entries, []) : entry.order => {
      action                  = try(entry.action, local.defaults.nxos.devices.configuration.route_maps.entries.action, null)
      description             = try(entry.description, local.defaults.nxos.devices.configuration.route_maps.entries.description, null)
      drop_on_fail_v4         = try(entry.drop_on_fail_v4, local.defaults.nxos.devices.configuration.route_maps.entries.drop_on_fail_v4, null) != null ? (try(entry.drop_on_fail_v4, local.defaults.nxos.devices.configuration.route_maps.entries.drop_on_fail_v4) ? "enabled" : "disabled") : null
      drop_on_fail_v6         = try(entry.drop_on_fail_v6, local.defaults.nxos.devices.configuration.route_maps.entries.drop_on_fail_v6, null) != null ? (try(entry.drop_on_fail_v6, local.defaults.nxos.devices.configuration.route_maps.entries.drop_on_fail_v6) ? "enabled" : "disabled") : null
      force_order_v4          = try(entry.force_order_v4, local.defaults.nxos.devices.configuration.route_maps.entries.force_order_v4, null) != null ? (try(entry.force_order_v4, local.defaults.nxos.devices.configuration.route_maps.entries.force_order_v4) ? "enabled" : "disabled") : null
      force_order_v6          = try(entry.force_order_v6, local.defaults.nxos.devices.configuration.route_maps.entries.force_order_v6, null) != null ? (try(entry.force_order_v6, local.defaults.nxos.devices.configuration.route_maps.entries.force_order_v6) ? "enabled" : "disabled") : null
      load_share_v4           = try(entry.load_share_v4, local.defaults.nxos.devices.configuration.route_maps.entries.load_share_v4, null) != null ? (try(entry.load_share_v4, local.defaults.nxos.devices.configuration.route_maps.entries.load_share_v4) ? "enabled" : "disabled") : null
      load_share_v6           = try(entry.load_share_v6, local.defaults.nxos.devices.configuration.route_maps.entries.load_share_v6, null) != null ? (try(entry.load_share_v6, local.defaults.nxos.devices.configuration.route_maps.entries.load_share_v6) ? "enabled" : "disabled") : null
      set_default_next_hop_v4 = try(entry.set_default_next_hop_v4, local.defaults.nxos.devices.configuration.route_maps.entries.set_default_next_hop_v4, null) != null ? (try(entry.set_default_next_hop_v4, local.defaults.nxos.devices.configuration.route_maps.entries.set_default_next_hop_v4) ? "enabled" : "disabled") : null
      set_default_next_hop_v6 = try(entry.set_default_next_hop_v6, local.defaults.nxos.devices.configuration.route_maps.entries.set_default_next_hop_v6, null) != null ? (try(entry.set_default_next_hop_v6, local.defaults.nxos.devices.configuration.route_maps.entries.set_default_next_hop_v6) ? "enabled" : "disabled") : null
      set_vrf_v4              = try(entry.set_vrf_v4, local.defaults.nxos.devices.configuration.route_maps.entries.set_vrf_v4, null) != null ? (try(entry.set_vrf_v4, local.defaults.nxos.devices.configuration.route_maps.entries.set_vrf_v4) ? "enabled" : "disabled") : null
      set_vrf_v6              = try(entry.set_vrf_v6, local.defaults.nxos.devices.configuration.route_maps.entries.set_vrf_v6, null) != null ? (try(entry.set_vrf_v6, local.defaults.nxos.devices.configuration.route_maps.entries.set_vrf_v6) ? "enabled" : "disabled") : null
      verify_availability_v4  = try(entry.verify_availability_v4, local.defaults.nxos.devices.configuration.route_maps.entries.verify_availability_v4, null) != null ? (try(entry.verify_availability_v4, local.defaults.nxos.devices.configuration.route_maps.entries.verify_availability_v4) ? "enabled" : "disabled") : null
      verify_availability_v6  = try(entry.verify_availability_v6, local.defaults.nxos.devices.configuration.route_maps.entries.verify_availability_v6, null) != null ? (try(entry.verify_availability_v6, local.defaults.nxos.devices.configuration.route_maps.entries.verify_availability_v6) ? "enabled" : "disabled") : null

      match_route_prefix_lists = try(entry.match_ip_prefix_list, local.defaults.nxos.devices.configuration.route_maps.entries.match_ip_prefix_list, null) != null ? {
        "sys/rpm/pfxlistv4-[${try(entry.match_ip_prefix_list, local.defaults.nxos.devices.configuration.route_maps.entries.match_ip_prefix_list)}]" = {}
      } : {}

      set_regular_community_additive     = try(entry.set_community, local.defaults.nxos.devices.configuration.route_maps.entries.set_community, null) != null ? (try(entry.set_community_additive, local.defaults.nxos.devices.configuration.route_maps.entries.set_community_additive, null) != null ? (try(entry.set_community_additive, local.defaults.nxos.devices.configuration.route_maps.entries.set_community_additive) ? "enabled" : "disabled") : "disabled") : null
      set_regular_community_no_community = try(entry.set_community, local.defaults.nxos.devices.configuration.route_maps.entries.set_community, null) != null ? (try(entry.set_community_none, local.defaults.nxos.devices.configuration.route_maps.entries.set_community_none, null) != null ? (try(entry.set_community_none, local.defaults.nxos.devices.configuration.route_maps.entries.set_community_none) ? "enabled" : "disabled") : "disabled") : null
      set_regular_community_criteria     = try(entry.set_community, local.defaults.nxos.devices.configuration.route_maps.entries.set_community, null) != null ? try(entry.set_community_criteria, local.defaults.nxos.devices.configuration.route_maps.entries.set_community_criteria, "none") : null

      set_regular_community_items = try(entry.set_community, local.defaults.nxos.devices.configuration.route_maps.entries.set_community, null) != null ? {
        try(entry.set_community, local.defaults.nxos.devices.configuration.route_maps.entries.set_community) = {}
      } : {}

      match_tags = { for tag in try(entry.match_tags, local.defaults.nxos.devices.configuration.route_maps.entries.match_tags, []) : tag => {} }
    } }
  } }
}
