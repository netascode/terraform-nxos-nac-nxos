locals {
  segment_routing = { for device in local.devices : device.name => try(local.device_config[device.name].routing.segment_routing, {}) }
}

resource "nxos_segment_routing" "segment_routing" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].routing.segment_routing, null) != null }
  device                         = each.key
  admin_state                    = "enabled"
  instance_admin_state           = try(local.segment_routing[each.key].mpls.shutdown, null) == null ? null : (try(local.segment_routing[each.key].mpls.shutdown) ? "disabled" : "enabled")
  srgb_allocation_retry_interval = try(local.segment_routing[each.key].mpls.timers_srgb_retry, null)
  srgb_cleanup_interval          = try(local.segment_routing[each.key].mpls.timers_srgb_cleanup, null)
  global_blocks = try(local.segment_routing[each.key].mpls.global_block_min, null) != null || try(local.segment_routing[each.key].mpls.global_block_max, null) != null ? {
    "mpls" = {
      label_blocks = {
        "srgb-1" = {
          minimum_label = try(local.segment_routing[each.key].mpls.global_block_min, null)
          maximum_label = try(local.segment_routing[each.key].mpls.global_block_max, null)
        }
      }
    }
  } : null
  domains = length(try(local.segment_routing[each.key].mpls.connected_prefix_sid_map_address_families, [])) > 0 ? {
    "default" = {
      address_families = { for af in try(local.segment_routing[each.key].mpls.connected_prefix_sid_map_address_families, []) : af.address_family => {
        connected_prefix_sid_maps = length(try(af.prefixes, [])) > 0 ? {
          "mpls" = {
            prefix_sids = { for pfx in try(af.prefixes, []) : pfx.prefix => {
              sid_value      = try(pfx.absolute, pfx.index, null)
              sid_value_type = try(pfx.absolute, null) != null ? "absolute" : try(pfx.index, null) != null ? "index" : null
            } }
          }
        } : null
      } }
    }
  } : null

  srv6_admin_state                  = try(local.segment_routing[each.key].srv6, null) != null ? "enabled" : null
  srv6_encapsulation_source_address = try(local.segment_routing[each.key].srv6.encapsulation_source_address, null)
  srv6_locators = length(try(local.segment_routing[each.key].srv6.locators, [])) > 0 ? { for loc in try(local.segment_routing[each.key].srv6.locators, []) : loc.name => {
    prefix = try(loc.prefix, null)
  } } : null

  traffic_engineering_admin_state = try(local.segment_routing[each.key].traffic_engineering, null) != null ? "enabled" : null
  traffic_engineering_encapsulations = try(local.segment_routing[each.key].traffic_engineering.encapsulation_mpls_source_ipv4, null) != null ? {
    "mpls" = {
      source_address = try(local.segment_routing[each.key].traffic_engineering.encapsulation_mpls_source_ipv4)
    }
  } : null
  liveness_detection_interval        = try(local.segment_routing[each.key].traffic_engineering.liveness_detection_interval, null)
  liveness_detection_multiplier      = try(local.segment_routing[each.key].traffic_engineering.liveness_detection_multiplier, null)
  liveness_detection_bfd_admin_state = try(local.segment_routing[each.key].traffic_engineering.liveness_detection_mpls_bfd, null) == null ? null : (try(local.segment_routing[each.key].traffic_engineering.liveness_detection_mpls_bfd) ? "enabled" : "disabled")
  liveness_detection_oam_admin_state = try(local.segment_routing[each.key].traffic_engineering.liveness_detection_mpls_oam, null) == null ? null : (try(local.segment_routing[each.key].traffic_engineering.liveness_detection_mpls_oam) ? "enabled" : "disabled")
  pcc_source_address                 = try(local.segment_routing[each.key].traffic_engineering.pcc_source_address_ipv4, null)
  pces = length(try(local.segment_routing[each.key].traffic_engineering.pcc_pce_addresses, [])) > 0 ? { for pce in try(local.segment_routing[each.key].traffic_engineering.pcc_pce_addresses, []) : pce.ipv4 => {
    precedence = try(pce.precedence, null)
  } } : null
  affinity_colors = length(try(local.segment_routing[each.key].traffic_engineering.affinity_map_colors, [])) > 0 ? { for color in try(local.segment_routing[each.key].traffic_engineering.affinity_map_colors, []) : color.color => {
    bit_position = try(color.bit_position, null)
  } } : null
  traffic_engineering_srv6_locators = length(try(local.segment_routing[each.key].traffic_engineering.segment_routing_srv6_locators, [])) > 0 ? { for loc in try(local.segment_routing[each.key].traffic_engineering.segment_routing_srv6_locators, []) : loc => {} } : null
  traffic_engineering_interfaces = length(try(local.segment_routing[each.key].traffic_engineering.interfaces, [])) > 0 ? { for int in try(local.segment_routing[each.key].traffic_engineering.interfaces, []) : "${local.intf_prefix_map[int.interface_type]}${int.interface_id}" => {
    metric          = try(int.metric, null)
    affinity_colors = length(try(int.affinity_colors, [])) > 0 ? { for color in try(int.affinity_colors, []) : color => {} } : null
  } } : null
  segment_lists = length(try(local.segment_routing[each.key].traffic_engineering.segment_lists, [])) > 0 ? { for sl in try(local.segment_routing[each.key].traffic_engineering.segment_lists, []) : sl.name => {
    labels = length([for idx in try(sl.indexes, []) : idx if try(idx.mpls_label, null) != null]) > 0 ? { for idx in try(sl.indexes, []) : idx.index => {
      label = idx.mpls_label
    } if try(idx.mpls_label, null) != null } : null
    sids = length([for idx in try(sl.indexes, []) : idx if try(idx.segment_routing_srv6, null) != null]) > 0 ? { for idx in try(sl.indexes, []) : idx.index => {
      sid = idx.segment_routing_srv6
    } if try(idx.segment_routing_srv6, null) != null } : null
    policy_endpoints = length([for idx in try(sl.indexes, []) : idx if try(idx.policy_endpoint, false)]) > 0 ? { for idx in try(sl.indexes, []) : idx.index => {
      enable = true
    } if try(idx.policy_endpoint, false) } : null
  } } : null
  on_demand_colors = length(try(local.segment_routing[each.key].traffic_engineering.on_demand_colors, [])) > 0 ? { for odn in try(local.segment_routing[each.key].traffic_engineering.on_demand_colors, []) : odn.color => {
    shutdown                           = try(odn.shutdown, null)
    lockdown                           = try(odn.lockdown, null)
    liveness_detection_shutdown        = try(odn.liveness_detection.shutdown, null)
    liveness_detection_index_limit     = try(odn.liveness_detection.index_limit, null)
    liveness_detection_bfd_admin_state = try(odn.liveness_detection.mpls_bfd, null) == null ? null : (try(odn.liveness_detection.mpls_bfd) ? "enabled" : "disabled")
    liveness_detection_oam_admin_state = try(odn.liveness_detection.mpls_oam, null) == null ? null : (try(odn.liveness_detection.mpls_oam) ? "enabled" : "disabled")
    candidate_paths = length(try(odn.candidate_paths_preferences, [])) > 0 ? { for pref in try(odn.candidate_paths_preferences, []) : pref.preference => {
      shutdown                    = try(pref.shutdown, null)
      explicit_segment_lists      = length(try(pref.explicit_segment_lists, [])) > 0 ? { for sl in try(pref.explicit_segment_lists, []) : sl => {} } : null
      dynamic_admin_state         = try(pref.dynamic, null) == null ? null : (try(pref.dynamic) ? "enabled" : "disabled")
      dynamic_pcep_admin_state    = try(pref.dynamic_pcep, null) == null ? null : (try(pref.dynamic_pcep) ? "enabled" : "disabled")
      dynamic_metric_type         = try(pref.dynamic_metric_type, null)
      dataplane                   = try(pref.constraints_segments_dataplane_mpls, null) == true ? "mpls" : null
      protection_type             = try(pref.constraints_segments_protected, null) == true ? "protected" : try(pref.constraints_segments_unprotected, null) == true ? "unprotected" : null
      disjoint_type               = try(pref.constraints_association_group_disjoint_type, null)
      disjoint_id                 = try(pref.constraints_association_group_disjoint_id, null)
      include_all_affinity_colors = length(try(pref.constraints_affinity_include_all_colors, [])) > 0 ? { for color in try(pref.constraints_affinity_include_all_colors, []) : color => {} } : null
      include_any_affinity_colors = length(try(pref.constraints_affinity_include_any_colors, [])) > 0 ? { for color in try(pref.constraints_affinity_include_any_colors, []) : color => {} } : null
      exclude_any_affinity_colors = length(try(pref.constraints_affinity_exclude_any_colors, [])) > 0 ? { for color in try(pref.constraints_affinity_exclude_any_colors, []) : color => {} } : null
    } } : null
  } } : null
  policies = length(try(local.segment_routing[each.key].traffic_engineering.policies, [])) > 0 ? { for pol in try(local.segment_routing[each.key].traffic_engineering.policies, []) : pol.name => {
    color                              = try(pol.color, null)
    endpoint                           = try(pol.endpoint, null)
    shutdown                           = try(pol.shutdown, null)
    lockdown                           = try(pol.lockdown, null)
    liveness_detection_shutdown        = try(pol.liveness_detection.shutdown, null)
    liveness_detection_index_limit     = try(pol.liveness_detection.index_limit, null)
    liveness_detection_bfd_admin_state = try(pol.liveness_detection.mpls_bfd, null) == null ? null : (try(pol.liveness_detection.mpls_bfd) ? "enabled" : "disabled")
    liveness_detection_oam_admin_state = try(pol.liveness_detection.mpls_oam, null) == null ? null : (try(pol.liveness_detection.mpls_oam) ? "enabled" : "disabled")
    candidate_paths = length(try(pol.candidate_paths_preferences, [])) > 0 ? { for pref in try(pol.candidate_paths_preferences, []) : pref.preference => {
      shutdown                    = try(pref.shutdown, null)
      explicit_segment_lists      = length(try(pref.explicit_segment_lists, [])) > 0 ? { for sl in try(pref.explicit_segment_lists, []) : sl => {} } : null
      dynamic_admin_state         = try(pref.dynamic, null) == null ? null : (try(pref.dynamic) ? "enabled" : "disabled")
      dynamic_pcep_admin_state    = try(pref.dynamic_pcep, null) == null ? null : (try(pref.dynamic_pcep) ? "enabled" : "disabled")
      dynamic_metric_type         = try(pref.dynamic_metric_type, null)
      dataplane                   = try(pref.constraints_segments_dataplane_mpls, null) == true ? "mpls" : null
      protection_type             = try(pref.constraints_segments_protected, null) == true ? "protected" : try(pref.constraints_segments_unprotected, null) == true ? "unprotected" : null
      disjoint_type               = try(pref.constraints_association_group_disjoint_type, null)
      disjoint_id                 = try(pref.constraints_association_group_disjoint_id, null)
      include_all_affinity_colors = length(try(pref.constraints_affinity_include_all_colors, [])) > 0 ? { for color in try(pref.constraints_affinity_include_all_colors, []) : color => {} } : null
      include_any_affinity_colors = length(try(pref.constraints_affinity_include_any_colors, [])) > 0 ? { for color in try(pref.constraints_affinity_include_any_colors, []) : color => {} } : null
      exclude_any_affinity_colors = length(try(pref.constraints_affinity_exclude_any_colors, [])) > 0 ? { for color in try(pref.constraints_affinity_exclude_any_colors, []) : color => {} } : null
    } } : null
  } } : null

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_svi_interface.svi_interface,
  ]
}
