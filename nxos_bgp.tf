locals {
  address_family_names_map = {
    ipv4_unicast    = "ipv4-ucast"
    ipv4_multicast  = "ipv4-mcast"
    vpnv4_unicast   = "vpnv4-ucast"
    ipv6_unicast    = "ipv6-ucast"
    ipv6_multicast  = "ipv6-mcast"
    vpnv6_unicast   = "vpnv6-ucast"
    vpnv6_multicast = "vpnv6-mcast"
    l2vpn_evpn      = "l2vpn-evpn"
    ipv4_lucast     = "ipv4-lucast"
    ipv6_lucast     = "ipv6-lucast"
    lnkstate        = "lnkstate"
    ipv4_mvpn       = "ipv4-mvpn"
    ipv6_mvpn       = "ipv6-mvpn"
    l2vpn_vpls      = "l2vpn-vpls"
    ipv4_mdt        = "ipv4-mdt"
  }
}

resource "nxos_bgp" "bgp" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].routing.bgp.asn, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].routing.bgp.admin_state, local.defaults.nxos.devices.configuration.routing.bgp.admin_state, false) ? "enabled" : "disabled"

  instance_admin_state                     = "enabled"
  asn                                      = try(local.device_config[each.key].routing.bgp.asn, null)
  disable_policy_batching                  = try(local.device_config[each.key].routing.bgp.disable_policy_batching, local.defaults.nxos.devices.configuration.routing.bgp.disable_policy_batching, false) ? "enabled" : "disabled"
  disable_policy_batching_nexthop          = try(local.device_config[each.key].routing.bgp.disable_policy_batching_nexthop, local.defaults.nxos.devices.configuration.routing.bgp.disable_policy_batching_nexthop, false) ? "enabled" : "disabled"
  disable_policy_batching_ipv4_prefix_list = try(local.device_config[each.key].routing.bgp.disable_policy_batching_ipv4_prefix_list, local.defaults.nxos.devices.configuration.routing.bgp.disable_policy_batching_ipv4_prefix_list, null)
  disable_policy_batching_ipv6_prefix_list = try(local.device_config[each.key].routing.bgp.disable_policy_batching_ipv6_prefix_list, local.defaults.nxos.devices.configuration.routing.bgp.disable_policy_batching_ipv6_prefix_list, null)
  fabric_soo                               = try(local.device_config[each.key].routing.bgp.fabric_soo, local.defaults.nxos.devices.configuration.routing.bgp.fabric_soo, null)
  flush_routes                             = try(local.device_config[each.key].routing.bgp.flush_routes, local.defaults.nxos.devices.configuration.routing.bgp.flush_routes, false) ? "enabled" : "disabled"
  isolate                                  = try(local.device_config[each.key].routing.bgp.isolate, local.defaults.nxos.devices.configuration.routing.bgp.isolate, null)
  isolate_route_map                        = try(local.device_config[each.key].routing.bgp.isolate_route_map, local.defaults.nxos.devices.configuration.routing.bgp.isolate_route_map, null)
  med_dampening_interval                   = try(local.device_config[each.key].routing.bgp.med_dampening_interval, local.defaults.nxos.devices.configuration.routing.bgp.med_dampening_interval, null)
  nexthop_suppress_default_resolution      = try(local.device_config[each.key].routing.bgp.nexthop_suppress_default_resolution, local.defaults.nxos.devices.configuration.routing.bgp.nexthop_suppress_default_resolution, false) ? "enabled" : "disabled"
  rd_dual                                  = try(local.device_config[each.key].routing.bgp.rd_dual, local.defaults.nxos.devices.configuration.routing.bgp.rd_dual, false) ? "enabled" : "disabled"
  rd_dual_id                               = try(local.device_config[each.key].routing.bgp.rd_dual_id, local.defaults.nxos.devices.configuration.routing.bgp.rd_dual_id, null)

  vrfs = { for vrf in try(local.device_config[each.key].routing.bgp.vrfs, []) : vrf.vrf => {
    router_id                = try(vrf.router_id, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.router_id, null)
    alloc_index              = try(vrf.allocate_index, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.allocate_index, null)
    bestpath_first_always    = try(vrf.bestpath_limit_always, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.bestpath_limit_always, false) ? "enabled" : "disabled"
    bestpath_interval        = try(vrf.bestpath_limit, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.bestpath_limit, null)
    bandwidth_reference      = try(vrf.bandwidth_reference, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.bandwidth_reference, null)
    bandwidth_reference_unit = try(vrf.bandwidth_reference_unit, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.bandwidth_reference_unit, null)
    cluster_id               = try(vrf.cluster_id, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.cluster_id, null)
    hold_time                = try(vrf.hold_time, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.hold_time, null)
    keepalive_interval       = try(vrf.keepalive_interval, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.keepalive_interval, null)
    local_asn                = try(vrf.local_as, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.local_as, null)
    max_as_limit             = try(vrf.maxas_limit, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.maxas_limit, null)
    mode                     = try(vrf.mode, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.mode, null)
    prefix_peer_timeout      = try(vrf.prefix_peer_timeout, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.prefix_peer_timeout, null)
    prefix_peer_wait_time    = try(vrf.prefix_peer_wait, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.prefix_peer_wait, null)
    reconnect_interval       = try(vrf.reconnect_interval, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.reconnect_interval, null)
    router_id_auto           = try(vrf.router_id_auto, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.router_id_auto, false) ? "enabled" : "disabled"

    route_control_enforce_first_as     = try(vrf.enforce_first_as, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.enforce_first_as, false) ? "enabled" : "disabled"
    route_control_fib_accelerate       = try(vrf.neighbor_down_fib_accelerate, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbor_down_fib_accelerate, false) ? "enabled" : "disabled"
    route_control_log_neighbor_changes = try(vrf.log_neighbor_changes, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.log_neighbor_changes, false) ? "enabled" : "disabled"
    route_control_suppress_routes      = try(vrf.suppress_fib_pending, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.suppress_fib_pending, false) ? "enabled" : "disabled"

    graceful_restart_control        = try(vrf.graceful_restart, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.graceful_restart, null)
    graceful_restart_interval       = try(vrf.graceful_restart_restart_time, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.graceful_restart_restart_time, null)
    graceful_restart_stale_interval = try(vrf.graceful_restart_stalepath_time, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.graceful_restart_stalepath_time, null)

    address_families = { for af in try(vrf.address_families, []) : local.address_family_names_map[af.address_family] => {
      critical_nexthop_timeout               = try(af.nexthop_trigger_delay_critical, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.nexthop_trigger_delay_critical, null)
      non_critical_nexthop_timeout           = try(af.nexthop_trigger_delay_non_critical, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.nexthop_trigger_delay_non_critical, null)
      advertise_l2vpn_evpn                   = try(af.advertise_l2vpn_evpn, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.advertise_l2vpn_evpn, false) ? "enabled" : "disabled"
      advertise_physical_ip_for_type5_routes = try(af.advertise_pip, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.advertise_pip, false) ? "enabled" : "disabled"
      max_ecmp_paths                         = try(af.maximum_paths, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.maximum_paths, null)
      max_external_ecmp_paths                = try(af.maximum_paths_eibgp, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.maximum_paths_eibgp, null)
      max_external_internal_ecmp_paths       = try(af.maximum_paths_eibgp_ibgp, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.maximum_paths_eibgp_ibgp, null)
      max_local_ecmp_paths                   = try(af.maximum_paths_local, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.maximum_paths_local, null)
      max_mixed_ecmp_paths                   = try(af.maximum_paths_mixed, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.maximum_paths_mixed, null)
      default_information_originate          = try(af.default_information_originate, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.default_information_originate, false) ? "enabled" : "disabled"
      next_hop_route_map_name                = try(af.nexthop_route_map, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.nexthop_route_map, null)
      prefix_priority                        = try(af.prefix_priority, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.prefix_priority, null)
      retain_rt_all                          = try(af.retain_route_target_all, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.retain_route_target_all, false) ? "enabled" : "disabled"
      advertise_only_active_routes           = try(af.advertise_only_active_routes, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.advertise_only_active_routes, false) ? "enabled" : "disabled"
      table_map_route_map_name               = try(af.table_map, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.table_map, null)
      vni_ethernet_tag                       = try(af.allow_vni_in_ethertag, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.allow_vni_in_ethertag, false) ? "enabled" : "disabled"
      wait_igp_converged                     = try(af.wait_igp_convergence, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.wait_igp_convergence, false) ? "enabled" : "disabled"
      advertise_system_mac                   = try(af.advertise_system_mac, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.advertise_system_mac, false) ? "enabled" : "disabled"
      allocate_label_all                     = try(af.allocate_label_all, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.allocate_label_all, false) ? "enabled" : "disabled"
      allocate_label_option_b                = try(af.allocate_label_option_b, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.allocate_label_option_b, false) ? "enabled" : "disabled"
      allocate_label_route_map               = try(af.allocate_label_route_map, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.allocate_label_route_map, null)
      bestpath_origin_as_allow_invalid       = try(af.bestpath_origin_as_allow_invalid, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.bestpath_origin_as_allow_invalid, false) ? "enabled" : "disabled"
      bestpath_origin_as_use_validity        = try(af.bestpath_origin_as_use_validity, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.bestpath_origin_as_use_validity, false) ? "enabled" : "disabled"
      client_to_client_reflection            = try(af.client_to_client_reflection, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.client_to_client_reflection, false) ? "enabled" : "disabled"
      default_metric                         = try(af.default_metric, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.default_metric, null)
      export_gateway_ip                      = try(af.export_gateway_ip, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.export_gateway_ip, false) ? "enabled" : "disabled"
      igp_metric                             = try(af.dampen_igp_metric, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.dampen_igp_metric, null)
      label_allocation_mode                  = try(af.label_allocation_mode, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.label_allocation_mode, false) ? "enabled" : "disabled"
      max_path_unequal_cost                  = try(af.maximum_paths_unequal_cost, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.maximum_paths_unequal_cost, false) ? "enabled" : "disabled"
      nexthop_load_balance_egress_multisite  = try(af.nexthop_load_balance_egress_multisite, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.nexthop_load_balance_egress_multisite, false) ? "enabled" : "disabled"
      originate_map                          = try(af.originate_map, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.originate_map, null)
      origin_as_validate                     = try(af.origin_as_validate, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.origin_as_validate, false) ? "enabled" : "disabled"
      origin_as_validate_signal_ibgp         = try(af.origin_as_validate_signal_ibgp, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.origin_as_validate_signal_ibgp, false) ? "enabled" : "disabled"
      retain_rt_route_map                    = try(af.retain_route_target_route_map, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.retain_route_target_route_map, null)
      table_map_filter                       = try(af.table_map_filter, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.table_map_filter, false) ? "enabled" : "disabled"
      timer_bestpath_defer                   = try(af.timers_bestpath_defer, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.timers_bestpath_defer, null)
      timer_bestpath_defer_max               = try(af.timers_bestpath_defer_maximum, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.timers_bestpath_defer_maximum, null)

      advertised_prefixes = { for prefix in try(af.networks, []) : prefix.prefix => {
        route_map = try(prefix.route_map, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.networks.route_map, null)
        evpn      = try(prefix.evpn, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.networks.evpn, false) ? "enabled" : "disabled"
      } }

      redistributions = { for redist in try(af.redistributions, []) : "${redist.protocol};${try(redist.protocol_instance, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.redistributions.protocol_instance, "none")}" => {
        route_map        = try(redist.route_map, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.redistributions.route_map, null)
        scope            = try(redist.scope, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.redistributions.scope, null)
        srv6_prefix_type = try(redist.srv6_prefix_type, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.redistributions.srv6_prefix_type, null)
        asn              = try(redist.asn, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.address_families.redistributions.asn, null)
      } }
    } }

    peer_templates = vrf.vrf == "default" ? { for pt in try(local.device_config[each.key].routing.bgp.peer_templates, []) : pt.name => {
      remote_asn                     = try(pt.remote_as, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.remote_as, null)
      description                    = try(pt.description, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.description, null)
      peer_type                      = try(pt.peer_type, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.peer_type, null)
      source_interface               = try(pt.update_source_interface_type, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.update_source_interface_type, null) != null ? "${local.intf_prefix_map[try(pt.update_source_interface_type, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.update_source_interface_type)]}${try(pt.update_source_interface_id, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.update_source_interface_id, "")}" : null
      admin_state                    = try(pt.admin_state, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.admin_state, false) ? "enabled" : "disabled"
      affinity_group                 = try(pt.affinity_group, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.affinity_group, null)
      asn_type                       = try(pt.remote_as_type, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.remote_as_type, null)
      bfd_type                       = try(pt.bfd_type, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.bfd_type, null)
      bmp_server_1                   = try(pt.bmp_activate_server_1, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.bmp_activate_server_1, false) ? "enabled" : "disabled"
      bmp_server_2                   = try(pt.bmp_activate_server_2, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.bmp_activate_server_2, false) ? "enabled" : "disabled"
      capability_suppress_4_byte_asn = try(pt.capability_suppress_4_byte_asn, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.capability_suppress_4_byte_asn, false) ? "enabled" : "disabled"
      connection_mode                = try(pt.connection_mode, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.connection_mode, null)
      peer_control                   = join(",", sort(compact([try(pt.bfd, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.bfd, false) ? "bfd" : "", try(pt.dont_capability_negotiate, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.dont_capability_negotiate, false) ? "cap-neg-off" : "", try(pt.disable_connected_check, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.disable_connected_check, false) ? "dis-conn-check" : "", !try(pt.dynamic_capability, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.dynamic_capability, true) ? "no-dyn-cap" : ""])))
      hold_time                      = try(pt.hold_time, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.hold_time, null)
      keepalive_interval             = try(pt.keepalive_interval, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.keepalive_interval, null)
      log_neighbor_changes           = try(pt.log_neighbor_changes, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.log_neighbor_changes, null)
      low_memory_exempt              = try(pt.low_memory_exempt, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.low_memory_exempt, false) ? "enabled" : "disabled"
      max_peer_count                 = try(pt.maximum_peers, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.maximum_peers, null)
      password_type                  = try(pt.password_type, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.password_type, null)
      password                       = try(pt.password, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.password, null)
      private_as_control             = try(pt.remove_private_as, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.remove_private_as, null)
      session_template               = try(pt.inherit_peer_session, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.inherit_peer_session, null)
      ebgp_multihop_ttl              = try(pt.ebgp_multihop_ttl, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.ebgp_multihop_ttl, null)
      ttl_security_hops              = try(pt.ttl_security_hops, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.ttl_security_hops, null)

      peer_template_address_families = { for af in try(pt.address_families, []) : local.address_family_names_map[af.address_family] => {
        control                       = join(",", sort(compact([try(af.advertisement_interval, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.advertisement_interval, null) != null ? "advertisement-interval" : "", try(af.allowas_in, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.allowas_in, false) ? "allow-self-as" : "", try(af.default_originate, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.default_originate, false) ? "default-originate" : "", try(af.disable_peer_as_check, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.disable_peer_as_check, false) ? "dis-peer-as-check" : "", try(af.next_hop_self, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.next_hop_self, false) ? "nh-self" : "", try(af.next_hop_self_all, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.next_hop_self_all, false) ? "nh-self-all" : "", try(af.route_reflector_client, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.route_reflector_client, false) ? "rr-client" : "", try(af.suppress_inactive, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.suppress_inactive, false) ? "suppress-inactive" : ""])))
        send_community_extended       = try(af.send_community_extended, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.send_community_extended, false) ? "enabled" : "disabled"
        send_community_standard       = try(af.send_community_standard, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.send_community_standard, false) ? "enabled" : "disabled"
        advertise_gateway_ip          = try(af.advertise_gateway_ip, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.advertise_gateway_ip, false) ? "enabled" : "disabled"
        advertisement_interval        = try(af.advertisement_interval, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.advertisement_interval, null)
        advertise_local_labeled_route = try(af.advertise_local_labeled_route, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.advertise_local_labeled_route, false) ? "enabled" : "disabled"
        aigp                          = try(af.aigp, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.aigp, false) ? "enabled" : "disabled"
        allowed_self_as_count         = try(af.allowas_in_count, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.allowas_in_count, null)
        as_override                   = try(af.as_override, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.as_override, false) ? "enabled" : "disabled"
        default_originate             = try(af.default_originate, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.default_originate, false) ? "enabled" : "disabled"
        default_originate_route_map   = try(af.default_originate_route_map, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.default_originate_route_map, null)
        dmz_link_bandwidth            = try(af.dmz_link_bandwidth, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.dmz_link_bandwidth, false) ? "enabled" : "disabled"
        encapsulation_mpls            = try(af.encapsulation_mpls, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.encapsulation_mpls, false) ? "enabled" : "disabled"
        link_bandwidth_cumulative     = try(af.link_bandwidth_cumulative, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.link_bandwidth_cumulative, false) ? "enabled" : "disabled"
        nexthop_thirdparty            = try(af.next_hop_third_party, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.next_hop_third_party, false) ? "enabled" : "disabled"
        rewrite_rt_asn                = try(af.rewrite_evpn_rt_asn, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.rewrite_evpn_rt_asn, false) ? "enabled" : "disabled"
        soft_reconfiguration_backup   = try(af.soft_reconfiguration_inbound, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.soft_reconfiguration_inbound, null)
        site_of_origin                = try(af.site_of_origin, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.site_of_origin, null)
        unsuppress_map                = try(af.unsuppress_map, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.unsuppress_map, null)
        weight                        = try(af.weight, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.weight, null)

        max_prefix_action       = try(af.maximum_prefix.action, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.maximum_prefix.action, null)
        max_prefix_number       = try(af.maximum_prefix.number, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.maximum_prefix.number, null)
        max_prefix_restart_time = try(af.maximum_prefix.restart_time, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.maximum_prefix.restart_time, null)
        max_prefix_threshold    = try(af.maximum_prefix.threshold, local.defaults.nxos.devices.configuration.routing.bgp.peer_templates.address_families.maximum_prefix.threshold, null)
      } }
    } } : {}

    peers = { for nei in try(vrf.neighbors, []) : nei.ip => {
      remote_asn                     = try(nei.remote_as, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.remote_as, null)
      description                    = try(nei.description, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.description, null)
      peer_template                  = try(nei.inherit_peer, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.inherit_peer, null)
      peer_type                      = try(nei.peer_type, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.peer_type, null)
      source_interface               = try(nei.update_source_interface_type, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.update_source_interface_type, null) != null ? "${local.intf_prefix_map[try(nei.update_source_interface_type, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.update_source_interface_type)]}${try(nei.update_source_interface_id, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.update_source_interface_id, "")}" : null
      hold_time                      = try(nei.hold_time, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.hold_time, null)
      keepalive_interval             = try(nei.keepalive_interval, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.keepalive_interval, null)
      ebgp_multihop_ttl              = try(nei.ebgp_multihop_ttl, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.ebgp_multihop_ttl, null)
      peer_control                   = join(",", sort(compact([try(nei.bfd, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.bfd, false) ? "bfd" : "", try(nei.dont_capability_negotiate, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.dont_capability_negotiate, false) ? "cap-neg-off" : "", try(nei.disable_connected_check, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.disable_connected_check, false) ? "dis-conn-check" : "", !try(nei.dynamic_capability, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.dynamic_capability, true) ? "no-dyn-cap" : ""])))
      password_type                  = try(nei.password_type, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.password_type, null)
      password                       = try(nei.password, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.password, null)
      admin_state                    = try(nei.admin_state, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.admin_state, false) ? "enabled" : "disabled"
      affinity_group                 = try(nei.affinity_group, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.affinity_group, null)
      asn_type                       = try(nei.remote_as_type, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.remote_as_type, null)
      bfd_type                       = try(nei.bfd_type, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.bfd_type, null)
      bmp_server_1                   = try(nei.bmp_activate_server_1, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.bmp_activate_server_1, false) ? "enabled" : "disabled"
      bmp_server_2                   = try(nei.bmp_activate_server_2, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.bmp_activate_server_2, false) ? "enabled" : "disabled"
      capability_suppress_4_byte_asn = try(nei.capability_suppress_4_byte_asn, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.capability_suppress_4_byte_asn, false) ? "enabled" : "disabled"
      connection_mode                = try(nei.connection_mode, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.connection_mode, null)
      log_neighbor_changes           = try(nei.log_neighbor_changes, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.log_neighbor_changes, null)
      low_memory_exempt              = try(nei.low_memory_exempt, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.low_memory_exempt, false) ? "enabled" : "disabled"
      max_peer_count                 = try(nei.maximum_peers, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.maximum_peers, null)
      private_as_control             = try(nei.remove_private_as, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.remove_private_as, null)
      session_template               = try(nei.inherit_peer_session, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.inherit_peer_session, null)
      ttl_security_hops              = try(nei.ttl_security_hops, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.ttl_security_hops, null)

      local_asn_propagation = try(nei.local_as_propagation, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.local_as_propagation, null)
      local_asn             = try(nei.local_as, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.local_as, null)

      peer_address_families = { for af in try(nei.address_families, []) : local.address_family_names_map[af.address_family] => {
        control                       = join(",", sort(compact([try(af.advertisement_interval, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.advertisement_interval, null) != null ? "advertisement-interval" : "", try(af.allowas_in, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.allowas_in, false) ? "allow-self-as" : "", try(af.default_originate, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.default_originate, false) ? "default-originate" : "", try(af.disable_peer_as_check, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.disable_peer_as_check, false) ? "dis-peer-as-check" : "", try(af.next_hop_self, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.next_hop_self, false) ? "nh-self" : "", try(af.next_hop_self_all, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.next_hop_self_all, false) ? "nh-self-all" : "", try(af.route_reflector_client, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.route_reflector_client, false) ? "rr-client" : "", try(af.suppress_inactive, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.suppress_inactive, false) ? "suppress-inactive" : ""])))
        send_community_extended       = try(af.send_community_extended, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.send_community_extended, false) ? "enabled" : "disabled"
        send_community_standard       = try(af.send_community_standard, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.send_community_standard, false) ? "enabled" : "disabled"
        advertise_gateway_ip          = try(af.advertise_gateway_ip, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.advertise_gateway_ip, false) ? "enabled" : "disabled"
        advertisement_interval        = try(af.advertisement_interval, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.advertisement_interval, null)
        advertise_local_labeled_route = try(af.advertise_local_labeled_route, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.advertise_local_labeled_route, false) ? "enabled" : "disabled"
        aigp                          = try(af.aigp, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.aigp, false) ? "enabled" : "disabled"
        allowed_self_as_count         = try(af.allowas_in_count, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.allowas_in_count, null)
        as_override                   = try(af.as_override, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.as_override, false) ? "enabled" : "disabled"
        default_originate             = try(af.default_originate, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.default_originate, false) ? "enabled" : "disabled"
        default_originate_route_map   = try(af.default_originate_route_map, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.default_originate_route_map, null)
        dmz_link_bandwidth            = try(af.dmz_link_bandwidth, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.dmz_link_bandwidth, false) ? "enabled" : "disabled"
        encapsulation_mpls            = try(af.encapsulation_mpls, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.encapsulation_mpls, false) ? "enabled" : "disabled"
        link_bandwidth_cumulative     = try(af.link_bandwidth_cumulative, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.link_bandwidth_cumulative, false) ? "enabled" : "disabled"
        nexthop_thirdparty            = try(af.next_hop_third_party, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.next_hop_third_party, false) ? "enabled" : "disabled"
        rewrite_rt_asn                = try(af.rewrite_evpn_rt_asn, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.rewrite_evpn_rt_asn, false) ? "enabled" : "disabled"
        soft_reconfiguration_backup   = try(af.soft_reconfiguration_inbound, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.soft_reconfiguration_inbound, null)
        site_of_origin                = try(af.site_of_origin, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.site_of_origin, null)
        unsuppress_map                = try(af.unsuppress_map, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.unsuppress_map, null)
        weight                        = try(af.weight, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.weight, null)

        max_prefix_action       = try(af.maximum_prefix.action, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.maximum_prefix.action, null)
        max_prefix_number       = try(af.maximum_prefix.number, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.maximum_prefix.number, null)
        max_prefix_restart_time = try(af.maximum_prefix.restart_time, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.maximum_prefix.restart_time, null)
        max_prefix_threshold    = try(af.maximum_prefix.threshold, local.defaults.nxos.devices.configuration.routing.bgp.vrfs.neighbors.address_families.maximum_prefix.threshold, null)

        route_controls = { for direction in compact([try(af.route_map_in, null) != null ? "in" : "", try(af.route_map_out, null) != null ? "out" : ""]) : direction => {
          route_map_name = direction == "in" ? af.route_map_in : af.route_map_out
        } }

        prefix_list_controls = { for direction in compact([try(af.prefix_list_in, null) != null ? "in" : "", try(af.prefix_list_out, null) != null ? "out" : ""]) : direction => {
          list = direction == "in" ? af.prefix_list_in : af.prefix_list_out
        } }
      } }
    } }
  } }

  depends_on = [
    nxos_feature.feature,
    nxos_route_policy.route_policy,
    nxos_vrf.vrf,
  ]
}
