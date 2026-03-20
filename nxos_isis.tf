locals {
  isis_interfaces = concat(local.interfaces_ethernets, local.interfaces_loopbacks, local.interfaces_vlans, local.interfaces_port_channels)
}

resource "nxos_isis" "isis" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].feature.isis, local.defaults.nxos.devices.configuration.feature.isis, false) }
  device      = each.key
  admin_state = "enabled"

  instances = { for inst in try(local.device_config[each.key].routing.isis_instances, []) : inst.name => {
    admin_state  = try(inst.shutdown, local.defaults.nxos.devices.configuration.routing.isis_instances.shutdown, false) ? "disabled" : "enabled"
    flush_routes = try(inst.flush_routes, local.defaults.nxos.devices.configuration.routing.isis_instances.flush_routes, null)
    isolate      = try(inst.isolate, local.defaults.nxos.devices.configuration.routing.isis_instances.isolate, null)

    vrfs = { for vrf in try(inst.vrfs, []) : vrf.vrf => {
      admin_state              = try(vrf.shutdown, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.shutdown, false) ? "disabled" : "enabled"
      authentication_check_l1  = try(vrf.authentication_check_level_1, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.authentication_check_level_1, null)
      authentication_check_l2  = try(vrf.authentication_check_level_2, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.authentication_check_level_2, null)
      authentication_key_l1    = try(vrf.authentication_key_chain_level_1, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.authentication_key_chain_level_1, null)
      authentication_key_l2    = try(vrf.authentication_key_chain_level_2, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.authentication_key_chain_level_2, null)
      authentication_type_l1   = try(vrf.authentication_type_level_1, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.authentication_type_level_1, null)
      authentication_type_l2   = try(vrf.authentication_type_level_2, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.authentication_type_level_2, null)
      bandwidth_reference      = try(vrf.bandwidth_reference, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.bandwidth_reference, null)
      bandwidth_reference_unit = try(vrf.bandwidth_reference_unit, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.bandwidth_reference_unit, null)
      is_type                  = try(vrf.is_type, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.is_type, null)
      metric_type              = try(vrf.metric_style, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.metric_style, null)
      mtu                      = try(vrf.lsp_mtu, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.lsp_mtu, null)
      net                      = try(vrf.net, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.net, null)
      passive_default          = try(vrf.passive_default, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.passive_default, null)
      control                  = try(vrf.log_adjacency_changes, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.log_adjacency_changes, null) != null ? (try(vrf.log_adjacency_changes, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.log_adjacency_changes) ? "log-adj-changes" : "unspecified") : null
      lsp_lifetime             = try(vrf.max_lsp_lifetime, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.max_lsp_lifetime, null)
      queue_limit              = try(vrf.queue_limit, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.queue_limit, null)
      overload_admin_state     = try(vrf.set_overload_bit, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.set_overload_bit, null)
      overload_startup_time    = try(vrf.overload_startup_time, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.overload_startup_time, null)
      overload_bgp_as_number   = try(vrf.overload_bgp_as_number, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.overload_bgp_as_number, null)
      overload_suppress        = try(vrf.overload_suppress, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.overload_suppress, null)

      address_families = { for af in try(vrf.address_families, []) : replace(replace(af.address_family, "ipv4_unicast", "v4"), "ipv6_unicast", "v6") => {
        segment_routing_mpls                    = try(af.segment_routing_mpls, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.segment_routing_mpls, null)
        enable_bfd                              = try(af.bfd, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.bfd, null)
        prefix_advertise_passive_l1             = try(af.advertise_passive_only_l1, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.advertise_passive_only_l1, null)
        prefix_advertise_passive_l2             = try(af.advertise_passive_only_l2, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.advertise_passive_only_l2, null)
        control                                 = try(af.adjacency_check, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.adjacency_check, null) != null ? (try(af.adjacency_check, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.adjacency_check) ? "adj-check" : null) : null
        default_information_originate           = try(af.default_information_originate, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.default_information_originate, null)
        default_information_originate_route_map = try(af.default_information_originate_route_map, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.default_information_originate_route_map, null)
        distance                                = try(af.distance, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.distance, null)
        max_ecmp                                = try(af.maximum_paths, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.maximum_paths, null)
        multi_topology                          = try(replace(replace(replace(af.multi_topology, "standard", "st"), "multi_topology_transition", "mtt"), "multi_topology", "mt"), replace(replace(replace(local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.multi_topology, "standard", "st"), "multi_topology_transition", "mtt"), "multi_topology", "mt"), null)
        router_id_interface                     = try(af.router_id_interface_type, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.router_id_interface_type, null) != null ? "${local.intf_prefix_map[try(af.router_id_interface_type, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.router_id_interface_type)]}${try(af.router_id_interface_id, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.router_id_interface_id, "")}" : null
        router_id_ip_address                    = try(af.router_id_ip_address, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.router_id_ip_address, null)
        table_map                               = try(af.table_map, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.table_map, null)
        table_map_filter                        = try(af.table_map_filter, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.table_map_filter, null) != null ? (try(af.table_map_filter, local.defaults.nxos.devices.configuration.routing.isis_instances.vrfs.address_families.table_map_filter) ? "enabled" : "disabled") : null
      } }
    } }

    interfaces = { for int in local.isis_interfaces : "${int.type}${int.id}" => {
      authentication_check         = int.isis_authentication_check
      authentication_check_l1      = int.isis_authentication_check_level_1
      authentication_check_l2      = int.isis_authentication_check_level_2
      authentication_key           = int.isis_authentication_key_chain
      authentication_key_l1        = int.isis_authentication_key_chain_level_1
      authentication_key_l2        = int.isis_authentication_key_chain_level_2
      authentication_type          = int.isis_authentication_type
      authentication_type_l1       = int.isis_authentication_type_level_1
      authentication_type_l2       = int.isis_authentication_type_level_2
      circuit_type                 = int.isis_circuit_type
      vrf                          = int.vrf
      hello_interval               = int.isis_hello_interval
      hello_interval_l1            = int.isis_hello_interval_l1
      hello_interval_l2            = int.isis_hello_interval_l2
      hello_multiplier             = int.isis_hello_multiplier
      hello_multiplier_l1          = int.isis_hello_multiplier_l1
      hello_multiplier_l2          = int.isis_hello_multiplier_l2
      hello_padding                = int.isis_hello_padding
      instance_name                = int.isis_instance_name
      metric_l1                    = int.isis_metric_l1
      metric_l2                    = int.isis_metric_l2
      mtu_check                    = int.isis_mtu_check
      mtu_check_l1                 = int.isis_mtu_check_l1
      mtu_check_l2                 = int.isis_mtu_check_l2
      network_type_p2p             = int.isis_network_type_p2p
      passive                      = int.isis_passive
      priority_l1                  = int.isis_priority_l1
      priority_l2                  = int.isis_priority_l2
      enable_ipv4                  = int.isis_ipv4
      csnp_interval_l1             = int.isis_csnp_interval_l1
      csnp_interval_l2             = int.isis_csnp_interval_l2
      lsp_refresh_interval         = int.isis_lsp_refresh_interval
      mesh_group_blocked           = int.isis_mesh_group_blocked
      mesh_group_id                = int.isis_mesh_group_id
      ipv6_metric_l1               = int.isis_ipv6_metric_l1
      ipv6_metric_l2               = int.isis_ipv6_metric_l2
      n_flag_clear                 = int.isis_n_flag_clear
      retransmit_interval          = int.isis_retransmit_interval
      retransmit_throttle_interval = int.isis_retransmit_throttle_interval
      suppressed_state             = int.isis_suppressed_state
      ipv4_bfd                     = int.isis_ipv4_bfd
      ipv6_bfd                     = int.isis_ipv6_bfd
      ipv6                         = int.isis_ipv6
    } if int.device == each.key && int.isis_instance_name == inst.name }
  } }

  depends_on = [
    nxos_feature.feature,
    nxos_loopback_interface.loopback_interface,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_svi_interface.svi_interface,
    nxos_vrf.vrf,
  ]
}
