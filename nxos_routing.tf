resource "nxos_route_policy" "route_policy" {
  for_each = { for device in local.devices : device.name => device
    if length(try(local.device_config[device.name].routing.ipv4_prefix_lists, [])) > 0 ||
  length(try(local.device_config[device.name].routing.route_maps, [])) > 0 }
  device = each.key

  ipv4_prefix_lists = { for pl in try(local.device_config[each.key].routing.ipv4_prefix_lists, []) : pl.name => {
    description = try(pl.description, local.defaults.nxos.devices.configuration.routing.ipv4_prefix_lists.description, null)

    entries = { for entry in try(pl.entries, []) : entry.order => {
      action     = try(entry.action, local.defaults.nxos.devices.configuration.routing.ipv4_prefix_lists.entries.action, null)
      criteria   = try(entry.criteria, local.defaults.nxos.devices.configuration.routing.ipv4_prefix_lists.entries.criteria, null)
      prefix     = try(entry.prefix, local.defaults.nxos.devices.configuration.routing.ipv4_prefix_lists.entries.prefix, null)
      from_range = try(entry.from_range, local.defaults.nxos.devices.configuration.routing.ipv4_prefix_lists.entries.from_range, null)
      to_range   = try(entry.to_range, local.defaults.nxos.devices.configuration.routing.ipv4_prefix_lists.entries.to_range, null)
      mask       = try(entry.mask, local.defaults.nxos.devices.configuration.routing.ipv4_prefix_lists.entries.mask, null)
    } }
  } }

  route_maps = { for rm in try(local.device_config[each.key].routing.route_maps, []) : rm.name => {
    pbr_statistics = try(rm.pbr_statistics, local.defaults.nxos.devices.configuration.routing.route_maps.pbr_statistics, null) != null ? (try(rm.pbr_statistics, local.defaults.nxos.devices.configuration.routing.route_maps.pbr_statistics) ? "enabled" : "disabled") : null

    entries = { for entry in try(rm.entries, []) : entry.order => {
      action                  = try(entry.action, local.defaults.nxos.devices.configuration.routing.route_maps.entries.action, null)
      description             = try(entry.description, local.defaults.nxos.devices.configuration.routing.route_maps.entries.description, null)
      drop_on_fail_v4         = try(entry.drop_on_fail_v4, local.defaults.nxos.devices.configuration.routing.route_maps.entries.drop_on_fail_v4, null) != null ? (try(entry.drop_on_fail_v4, local.defaults.nxos.devices.configuration.routing.route_maps.entries.drop_on_fail_v4) ? "enabled" : "disabled") : null
      drop_on_fail_v6         = try(entry.drop_on_fail_v6, local.defaults.nxos.devices.configuration.routing.route_maps.entries.drop_on_fail_v6, null) != null ? (try(entry.drop_on_fail_v6, local.defaults.nxos.devices.configuration.routing.route_maps.entries.drop_on_fail_v6) ? "enabled" : "disabled") : null
      force_order_v4          = try(entry.force_order_v4, local.defaults.nxos.devices.configuration.routing.route_maps.entries.force_order_v4, null) != null ? (try(entry.force_order_v4, local.defaults.nxos.devices.configuration.routing.route_maps.entries.force_order_v4) ? "enabled" : "disabled") : null
      force_order_v6          = try(entry.force_order_v6, local.defaults.nxos.devices.configuration.routing.route_maps.entries.force_order_v6, null) != null ? (try(entry.force_order_v6, local.defaults.nxos.devices.configuration.routing.route_maps.entries.force_order_v6) ? "enabled" : "disabled") : null
      load_share_v4           = try(entry.load_share_v4, local.defaults.nxos.devices.configuration.routing.route_maps.entries.load_share_v4, null) != null ? (try(entry.load_share_v4, local.defaults.nxos.devices.configuration.routing.route_maps.entries.load_share_v4) ? "enabled" : "disabled") : null
      load_share_v6           = try(entry.load_share_v6, local.defaults.nxos.devices.configuration.routing.route_maps.entries.load_share_v6, null) != null ? (try(entry.load_share_v6, local.defaults.nxos.devices.configuration.routing.route_maps.entries.load_share_v6) ? "enabled" : "disabled") : null
      set_default_next_hop_v4 = try(entry.set_default_next_hop_v4, local.defaults.nxos.devices.configuration.routing.route_maps.entries.set_default_next_hop_v4, null) != null ? (try(entry.set_default_next_hop_v4, local.defaults.nxos.devices.configuration.routing.route_maps.entries.set_default_next_hop_v4) ? "enabled" : "disabled") : null
      set_default_next_hop_v6 = try(entry.set_default_next_hop_v6, local.defaults.nxos.devices.configuration.routing.route_maps.entries.set_default_next_hop_v6, null) != null ? (try(entry.set_default_next_hop_v6, local.defaults.nxos.devices.configuration.routing.route_maps.entries.set_default_next_hop_v6) ? "enabled" : "disabled") : null
      set_vrf_v4              = try(entry.set_vrf_v4, local.defaults.nxos.devices.configuration.routing.route_maps.entries.set_vrf_v4, null) != null ? (try(entry.set_vrf_v4, local.defaults.nxos.devices.configuration.routing.route_maps.entries.set_vrf_v4) ? "enabled" : "disabled") : null
      set_vrf_v6              = try(entry.set_vrf_v6, local.defaults.nxos.devices.configuration.routing.route_maps.entries.set_vrf_v6, null) != null ? (try(entry.set_vrf_v6, local.defaults.nxos.devices.configuration.routing.route_maps.entries.set_vrf_v6) ? "enabled" : "disabled") : null
      verify_availability_v4  = try(entry.verify_availability_v4, local.defaults.nxos.devices.configuration.routing.route_maps.entries.verify_availability_v4, null) != null ? (try(entry.verify_availability_v4, local.defaults.nxos.devices.configuration.routing.route_maps.entries.verify_availability_v4) ? "enabled" : "disabled") : null
      verify_availability_v6  = try(entry.verify_availability_v6, local.defaults.nxos.devices.configuration.routing.route_maps.entries.verify_availability_v6, null) != null ? (try(entry.verify_availability_v6, local.defaults.nxos.devices.configuration.routing.route_maps.entries.verify_availability_v6) ? "enabled" : "disabled") : null

      match_route_prefix_lists = try(entry.match_prefix_list, local.defaults.nxos.devices.configuration.routing.route_maps.entries.match_prefix_list, null) != null ? {
        "sys/rpm/pfxlistv4-[${try(entry.match_prefix_list, local.defaults.nxos.devices.configuration.routing.route_maps.entries.match_prefix_list)}]" = {}
      } : {}

      set_regular_community_additive     = try(entry.additive, local.defaults.nxos.devices.configuration.routing.route_maps.entries.additive, null) != null ? (try(entry.additive, local.defaults.nxos.devices.configuration.routing.route_maps.entries.additive) ? "enabled" : "disabled") : null
      set_regular_community_no_community = try(entry.no_community, local.defaults.nxos.devices.configuration.routing.route_maps.entries.no_community, null) != null ? (try(entry.no_community, local.defaults.nxos.devices.configuration.routing.route_maps.entries.no_community) ? "enabled" : "disabled") : null
      set_regular_community_criteria     = try(entry.set_criteria, local.defaults.nxos.devices.configuration.routing.route_maps.entries.set_criteria, null)

      set_regular_community_items = try(entry.community, local.defaults.nxos.devices.configuration.routing.route_maps.entries.community, null) != null ? {
        try(entry.community, local.defaults.nxos.devices.configuration.routing.route_maps.entries.community) = {}
      } : {}

      match_tags = { for tag in try(entry.match_tags, local.defaults.nxos.devices.configuration.routing.route_maps.entries.match_tags, []) : tag => {} }
    } }
  } }
}
