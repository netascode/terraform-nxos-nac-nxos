locals {
  community_list_mode_map = {
    "standard" = "standard"
    "expanded" = "regex"
  }

  rp_community_well_known_map = {
    "internet"     = "regular:wk-nn2:internet"
    "no-export"    = "regular:wk-nn2:no-export"
    "no-advertise" = "regular:wk-nn2:no-advertise"
    "local-AS"     = "regular:wk-nn2:no-export-subconfed"
  }

  rp_route_type_map = {
    "internal"             = "internal"
    "external"             = "external"
    "local"                = "local"
    "type-1"               = "ospf-type1"
    "type-2"               = "ospf-type2"
    "nssa-external"        = "ospf-nssa-external"
    "level-1"              = "isis-l1"
    "level-2"              = "isis-l2"
    "inter-area"           = "ospf-inter-area"
    "intra-area"           = "ospf-intra-area"
    "redistributed-direct" = "redistributed-direct"
  }

  rp_evpn_route_type_map = {
    "1"          = "R1"
    "2"          = "R2_ALL"
    "2-mac-only" = "mac-only"
    "2-mac-ip"   = "mac-ip"
    "3"          = "R3"
    "4"          = "R4"
    "5"          = "R5"
    "6"          = "R6"
  }

  rp_policy_interfaces = { for device in local.devices : device.name => concat(
    flatten([
      for intf_type, intf_prefix in { "ethernets" = "eth", "port_channels" = "po", "vlans" = "vlan", "loopbacks" = "lo" } : [
        for int in try(local.device_config[device.name].interfaces[intf_type], []) : { id = "${intf_prefix}${int.id}", ip = try(int.ip, null), ipv6 = try(int.ipv6, null) }
      ]
    ]),
    flatten([
      for intf_type, intf_prefix in { "ethernets" = "eth", "port_channels" = "po" } : [
        for int in try(local.device_config[device.name].interfaces[intf_type], []) : [
          for sub in try(int.subinterfaces, []) : { id = "${intf_prefix}${int.id}.${sub.id}", ip = try(sub.ip, null), ipv6 = try(sub.ipv6, null) }
        ]
      ]
    ])
  ) }
  rp_ipv4_policy_interfaces_map = { for device in local.devices : device.name => {
    for int in local.rp_policy_interfaces[device.name] : int.id => {
      route_map_name = int.ip.policy_route_map
    } if try(int.ip.policy_route_map, null) != null
  } }
  rp_ipv6_policy_interfaces_map = { for device in local.devices : device.name => {
    for int in local.rp_policy_interfaces[device.name] : int.id => {
      route_map_name = int.ipv6.policy_route_map
    } if try(int.ipv6.policy_route_map, null) != null
  } }
}

resource "nxos_route_policy" "route_policy" {
  for_each = { for device in local.devices : device.name => device
    if length(try(local.device_config[device.name].ip_prefix_lists, [])) > 0 ||
    length(try(local.device_config[device.name].ipv6_prefix_lists, [])) > 0 ||
    length(try(local.device_config[device.name].route_maps, [])) > 0 ||
    length(try(local.device_config[device.name].community_lists, [])) > 0 ||
    length(try(local.device_config[device.name].ip_as_path_access_lists, [])) > 0 ||
    length(local.rp_ipv4_policy_interfaces_map[device.name]) > 0 ||
  length(local.rp_ipv6_policy_interfaces_map[device.name]) > 0 }
  device = each.key

  ipv4_prefix_lists = length(try(local.device_config[each.key].ip_prefix_lists, [])) > 0 ? { for pl in try(local.device_config[each.key].ip_prefix_lists, []) : pl.name => {
    description = try(pl.description, null)

    entries = length(try(pl.entries, [])) > 0 ? { for entry in try(pl.entries, []) : entry.seq => {
      action     = try(entry.action, null)
      criteria   = try(entry.ge, null) != null || try(entry.le, null) != null ? "inexact" : "exact"
      prefix     = try(entry.prefix, null)
      from_range = try(entry.ge, null)
      to_range   = try(entry.le, null)
      mask       = try(entry.mask, null)
    } } : null
  } } : null

  ipv6_prefix_lists = length(try(local.device_config[each.key].ipv6_prefix_lists, [])) > 0 ? { for pl in try(local.device_config[each.key].ipv6_prefix_lists, []) : pl.name => {
    description = try(pl.description, null)

    entries = length(try(pl.entries, [])) > 0 ? { for entry in try(pl.entries, []) : entry.seq => {
      action     = try(entry.action, null)
      criteria   = try(entry.ge, null) != null || try(entry.le, null) != null ? "inexact" : "exact"
      prefix     = try(entry.prefix, null)
      from_range = try(entry.ge, null)
      to_range   = try(entry.le, null)
      mask       = try(entry.mask, null)
    } } : null
  } } : null

  route_maps = length(try(local.device_config[each.key].route_maps, [])) > 0 ? { for rm in try(local.device_config[each.key].route_maps, []) : rm.name => {
    pbr_statistics = try(rm.pbr_statistics, null) != null ? (try(rm.pbr_statistics) ? "enabled" : "disabled") : null

    entries = length(try(rm.entries, [])) > 0 ? { for entry in try(rm.entries, []) : entry.order => {
      action                  = try(entry.action, null)
      description             = try(entry.description, null)
      drop_on_fail_v4         = try(entry.drop_on_fail_v4, null) != null ? (try(entry.drop_on_fail_v4) ? "enabled" : "disabled") : null
      drop_on_fail_v6         = try(entry.drop_on_fail_v6, null) != null ? (try(entry.drop_on_fail_v6) ? "enabled" : "disabled") : null
      force_order_v4          = try(entry.force_order_v4, null) != null ? (try(entry.force_order_v4) ? "enabled" : "disabled") : null
      force_order_v6          = try(entry.force_order_v6, null) != null ? (try(entry.force_order_v6) ? "enabled" : "disabled") : null
      load_share_v4           = try(entry.load_share_v4, null) != null ? (try(entry.load_share_v4) ? "enabled" : "disabled") : null
      load_share_v6           = try(entry.load_share_v6, null) != null ? (try(entry.load_share_v6) ? "enabled" : "disabled") : null
      set_default_next_hop_v4 = try(entry.set_default_next_hop_v4, null) != null ? (try(entry.set_default_next_hop_v4) ? "enabled" : "disabled") : null
      set_default_next_hop_v6 = try(entry.set_default_next_hop_v6, null) != null ? (try(entry.set_default_next_hop_v6) ? "enabled" : "disabled") : null
      set_vrf_v4              = try(entry.set_vrf_v4, null) != null ? (try(entry.set_vrf_v4) ? "enabled" : "disabled") : null
      set_vrf_v6              = try(entry.set_vrf_v6, null) != null ? (try(entry.set_vrf_v6) ? "enabled" : "disabled") : null
      verify_availability_v4  = try(entry.verify_availability_v4, null) != null ? (try(entry.verify_availability_v4) ? "enabled" : "disabled") : null
      verify_availability_v6  = try(entry.verify_availability_v6, null) != null ? (try(entry.verify_availability_v6) ? "enabled" : "disabled") : null

      match_route_prefix_lists = anytrue([try(entry.match_ip_address_prefix_list, null) != null, try(entry.match_ipv6_address_prefix_list, null) != null]) ? merge(
        try(entry.match_ip_address_prefix_list, null) != null ? {
          "sys/rpm/pfxlistv4-[${try(entry.match_ip_address_prefix_list)}]" = {}
        } : {},
        try(entry.match_ipv6_address_prefix_list, null) != null ? {
          "sys/rpm/pfxlistv6-[${try(entry.match_ipv6_address_prefix_list)}]" = {}
        } : {},
      ) : null

      match_route_access_lists = try(entry.match_ip_address, null) != null ? {
        "sys/rpm/accesslist-[${try(entry.match_ip_address)}]" = {}
      } : null

      match_route_ipv6_access_lists = try(entry.match_ipv6_address, null) != null ? {
        "sys/rpm/accesslist-[${try(entry.match_ipv6_address)}]" = {}
      } : null

      set_regular_community_additive     = try(entry.set_community, null) != null ? (try(entry.set_community_additive, null) != null ? (try(entry.set_community_additive) ? "enabled" : "disabled") : "disabled") : null
      set_regular_community_no_community = try(entry.set_community, null) != null ? (try(entry.set_community_none, null) != null ? (try(entry.set_community_none) ? "enabled" : "disabled") : "disabled") : null
      set_regular_community_criteria     = try(entry.set_community, null) != null ? "none" : null

      set_regular_community_items = try(entry.set_community, null) != null ? {
        for c in compact(split(" ", try(entry.set_community))) :
        try(
          local.rp_community_well_known_map[c],
          can(regex("^[0-9]+:[0-9]+$", c)) ? (
            tonumber(split(":", c)[0]) <= 65535 ? "regular:as2-nn2:${c}" : "regular:as4-nn2:${c}"
          ) : c
        ) => {}
      } : null

      set_community_list_name     = try(entry.set_comm_list, null)
      set_community_list_delete   = try(entry.set_comm_list, null) != null ? "enabled" : null
      set_community_list_criteria = try(entry.set_comm_list, null) != null ? "none" : null

      set_extended_community_route_target_additive = length(try(entry.set_extcommunity_rt, [])) > 0 ? (try(entry.set_extcommunity_rt_additive, null) != null ? (try(entry.set_extcommunity_rt_additive) ? "enabled" : "disabled") : "disabled") : null
      set_extended_community_route_target_criteria = length(try(entry.set_extcommunity_rt, [])) > 0 ? "none" : null

      set_extended_community_route_target_items = length(try(entry.set_extcommunity_rt, [])) > 0 ? {
        for rt in try(entry.set_extcommunity_rt, []) :
        "transitive;${can(regex("\\.", rt)) ? "route-target:ipv4-nn2:${rt}" : (tonumber(split(":", rt)[0]) <= 65535 ? "route-target:as2-nn2:${rt}" : "route-target:as4-nn2:${rt}")}" => {}
      } : null

      set_as_path_prepend         = length(try(entry.set_as_path_prepend, [])) > 0 ? join(" ", [for asn in try(entry.set_as_path_prepend, []) : tostring(asn)]) : null
      set_as_path_prepend_last_as = try(entry.set_as_path_prepend_last_as, null)
      set_origin                  = try(entry.set_origin, null)
      set_origin_asn              = try(entry.set_origin_egp_asn, null)
      set_tag                     = try(entry.set_tag, null)
      set_weight                  = try(entry.set_weight, null)

      match_tags = length(try(entry.match_tags, [])) > 0 ? { for tag in try(entry.match_tags, []) : tag => {} } : null

      match_interfaces = length(try(entry.match_interfaces, [])) > 0 ? { for intf in try(entry.match_interfaces, []) : "${local.intf_prefix_map[intf.interface_type]}${intf.interface_id}" => {} } : null

      match_route_types = length(concat(try(entry.match_route_types, []), try(entry.match_evpn_route_types, []))) > 0 ? merge(
        { for rt in try(entry.match_route_types, []) : local.rp_route_type_map[rt] => {} },
        { for rt in try(entry.match_evpn_route_types, []) : local.rp_evpn_route_type_map[tostring(rt)] => {} },
      ) : null

      match_as_path_lists = length(try(entry.match_as_path, [])) > 0 ? {
        for name in try(entry.match_as_path, []) : "sys/rpm/accesslist-[${name}]" => {}
      } : null

      match_as_number_as_path_lists = length(try(entry.match_as_number_as_path_list, [])) > 0 ? {
        for name in try(entry.match_as_number_as_path_list, []) : "sys/rpm/accesslist-[${name}]" => {}
      } : null

      set_metric                       = try(entry.set_metric, null)
      set_metric_delay                 = try(entry.set_metric_delay, null)
      set_metric_load                  = try(entry.set_metric_load, null)
      set_metric_mtu                   = try(entry.set_metric_mtu, null)
      set_metric_reliability           = try(entry.set_metric_reliability, null)
      set_metric_type                  = try(entry.set_metric_type, null)
      set_next_hop_v4_peer_address     = try(entry.set_ip_next_hop_peer_address, null) != null ? (try(entry.set_ip_next_hop_peer_address) ? "enabled" : "disabled") : null
      set_next_hop_v4_unchanged        = try(entry.set_ip_next_hop_unchanged, null) != null ? (try(entry.set_ip_next_hop_unchanged) ? "enabled" : "disabled") : null
      set_next_hop_v4_redist_unchanged = try(entry.set_ip_next_hop_redist_unchanged, null) != null ? (try(entry.set_ip_next_hop_redist_unchanged) ? "enabled" : "disabled") : null
      set_next_hop_v6_peer_address     = try(entry.set_ipv6_next_hop_peer_address, null) != null ? (try(entry.set_ipv6_next_hop_peer_address) ? "enabled" : "disabled") : null
      set_next_hop_v6_unchanged        = try(entry.set_ipv6_next_hop_unchanged, null) != null ? (try(entry.set_ipv6_next_hop_unchanged) ? "enabled" : "disabled") : null
      set_next_hop_v6_redist_unchanged = try(entry.set_ipv6_next_hop_redist_unchanged, null) != null ? (try(entry.set_ipv6_next_hop_redist_unchanged) ? "enabled" : "disabled") : null
      set_local_preference             = try(entry.set_local_preference, null)
      set_policy_tag                   = try(entry.set_pctag, null)
      set_path_selection_advertise     = try(entry.set_path_selection_advertise, null) != null ? { "unspecified" = "unspecified", "all" = "ps-all", "backup" = "ps-bestplus", "best2" = "ps-best2", "multipaths" = "ps-mpath" }[try(entry.set_path_selection_advertise)] : null
      set_evpn_gateway_ip              = try(entry.set_evpn_gateway_ip, null)
      set_evpn_gateway_type            = try(entry.set_evpn_gateway_ip_type, null)

      set_next_hops = length(concat(try(entry.set_ip_next_hops, []), try(entry.set_ipv6_next_hops, []))) > 0 ? { for nh in concat(try(entry.set_ip_next_hops, []), try(entry.set_ipv6_next_hops, [])) : nh.address => {
        track_id = try(nh.track, null)
        vrf      = try(nh.vrf, null)
      } } : null

      set_interfaces = try(entry.set_interface_null0, false) ? { "null0" = {} } : null

      match_next_hop_prefix_lists = try(entry.match_ip_next_hop_prefix_list, null) != null ? {
        "sys/rpm/pfxlistv4-[${try(entry.match_ip_next_hop_prefix_list)}]" = {}
      } : null

      match_regular_community_criteria = try(entry.match_community, null) != null ? (try(entry.match_community_exact_match, null) != null ? (try(entry.match_community_exact_match) ? "exact" : null) : null) : null

      match_regular_community_lists = try(entry.match_community, null) != null ? {
        "sys/rpm/rtregcom-[${try(entry.match_community)}]" = {}
      } : null
    } } : null
  } } : null

  community_lists = length(try(local.device_config[each.key].community_lists, [])) > 0 ? { for cl in try(local.device_config[each.key].community_lists, []) : cl.name => {
    mode = try(local.community_list_mode_map[try(cl.mode)], null)

    entries = length(try(cl.entries, [])) > 0 ? { for entry in try(cl.entries, []) : entry.seq => {
      action = try(entry.action, null)
      regex  = try(entry.regex, null)

      items = length(try(entry.communities, [])) > 0 ? { for community in try(entry.communities, []) :
        try(
          local.rp_community_well_known_map[community],
          can(regex("^[0-9]+:[0-9]+$", community)) ? (
            tonumber(split(":", community)[0]) <= 65535 ? "regular:as2-nn2:${community}" : "regular:as4-nn2:${community}"
          ) : community
        ) => {}
      } : null
    } } : null
  } } : null

  as_path_access_lists = length(try(local.device_config[each.key].ip_as_path_access_lists, [])) > 0 ? { for al in try(local.device_config[each.key].ip_as_path_access_lists, []) : al.name => {
    entries = length(try(al.entries, [])) > 0 ? { for entry in try(al.entries, []) : entry.seq => {
      action = try(entry.action, null)
      regex  = try(entry.regex, null)
    } } : null
  } } : null

  ipv4_policy_interfaces = length(local.rp_ipv4_policy_interfaces_map[each.key]) > 0 ? local.rp_ipv4_policy_interfaces_map[each.key] : null
  ipv6_policy_interfaces = length(local.rp_ipv6_policy_interfaces_map[each.key]) > 0 ? local.rp_ipv6_policy_interfaces_map[each.key] : null

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
    nxos_vrf.vrf,
    nxos_track.track,
    nxos_access_list.access_list,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_svi_interface.svi_interface,
    nxos_loopback_interface.loopback_interface,
    nxos_subinterface.subinterface,
  ]
}
