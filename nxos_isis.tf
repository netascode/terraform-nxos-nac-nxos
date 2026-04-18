locals {
  isis_interfaces = concat(local.interfaces_ethernets, local.interfaces_loopbacks, local.interfaces_vlans, local.interfaces_port_channels, local.interfaces_subinterfaces)
}

resource "nxos_isis" "isis" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].feature.isis, false) }
  device      = each.key
  admin_state = "enabled"

  instances = { for inst in try(local.device_config[each.key].routing.isis_instances, []) : inst.name => {
    flush_routes = try(inst.flush_routes, null)
    isolate      = try(inst.isolate, null)

    vrfs = merge(
      # Synthetic "default" VRF from instance-level attributes
      {
        "default" = {
          admin_state              = try(inst.shutdown, false) ? "disabled" : "enabled"
          authentication_check_l1  = try(inst.authentication_check_level_1, null)
          authentication_check_l2  = try(inst.authentication_check_level_2, null)
          authentication_key_l1    = try(inst.authentication_key_chain_level_1, null)
          authentication_key_l2    = try(inst.authentication_key_chain_level_2, null)
          authentication_type_l1   = try(inst.authentication_type_level_1, null)
          authentication_type_l2   = try(inst.authentication_type_level_2, null)
          bandwidth_reference      = try(inst.bandwidth_reference, null)
          bandwidth_reference_unit = try(inst.bandwidth_reference_unit, null)
          is_type                  = try(inst.is_type, null)
          metric_type              = try(inst.metric_style, null)
          mtu                      = try(inst.lsp_mtu, null)
          net                      = try(inst.net, null)
          passive_default          = try(inst.passive_default, null)
          control                  = try(inst.log_adjacency_changes, null) != null ? (try(inst.log_adjacency_changes) ? "log-adj-changes" : "unspecified") : null
          lsp_lifetime             = try(inst.max_lsp_lifetime, null)
          queue_limit              = try(inst.queue_limit, null)
          overload_admin_state     = try(inst.set_overload_bit, null)
          overload_startup_time    = try(inst.overload_startup_time, null)
          overload_bgp_as_number   = try(inst.overload_bgp_as_number, null)
          overload_suppress        = try(inst.overload_suppress, null)

          address_families = { for af in try(inst.address_families, []) : replace(replace(af.address_family, "ipv4-unicast", "v4"), "ipv6-unicast", "v6") => {
            segment_routing_mpls                    = try(af.segment_routing_mpls, null)
            enable_bfd                              = try(af.bfd, null)
            prefix_advertise_passive_l1             = try(af.advertise_passive_only_l1, null)
            prefix_advertise_passive_l2             = try(af.advertise_passive_only_l2, null)
            control                                 = try(af.adjacency_check, null) != null ? (try(af.adjacency_check) ? "adj-check" : null) : null
            default_information_originate           = try(af.default_information_originate, null)
            default_information_originate_route_map = try(af.default_information_originate_route_map, null)
            distance                                = try(af.distance, null)
            max_ecmp                                = try(af.maximum_paths, null)
            multi_topology                          = try(replace(replace(replace(af.multi_topology, "standard", "st"), "multi-topology-transition", "mtt"), "multi-topology", "mt"), null)
            router_id_interface                     = try(af.router_id_interface_type, null) != null ? "${local.intf_prefix_map[try(af.router_id_interface_type)]}${try(af.router_id_interface_id, "")}" : null
            router_id_ip_address                    = try(af.router_id_ip_address, null)
            table_map                               = try(af.table_map, null)
            table_map_filter                        = try(af.table_map_filter, null) != null ? (try(af.table_map_filter) ? "enabled" : "disabled") : null
          } }
        }
      },
      # Explicit non-default VRFs
      { for vrf in try(inst.vrfs, []) : vrf.vrf => {
        admin_state              = try(vrf.shutdown, false) ? "disabled" : "enabled"
        authentication_check_l1  = try(vrf.authentication_check_level_1, null)
        authentication_check_l2  = try(vrf.authentication_check_level_2, null)
        authentication_key_l1    = try(vrf.authentication_key_chain_level_1, null)
        authentication_key_l2    = try(vrf.authentication_key_chain_level_2, null)
        authentication_type_l1   = try(vrf.authentication_type_level_1, null)
        authentication_type_l2   = try(vrf.authentication_type_level_2, null)
        bandwidth_reference      = try(vrf.bandwidth_reference, null)
        bandwidth_reference_unit = try(vrf.bandwidth_reference_unit, null)
        is_type                  = try(vrf.is_type, null)
        metric_type              = try(vrf.metric_style, null)
        mtu                      = try(vrf.lsp_mtu, null)
        net                      = try(vrf.net, null)
        passive_default          = try(vrf.passive_default, null)
        control                  = try(vrf.log_adjacency_changes, null) != null ? (try(vrf.log_adjacency_changes) ? "log-adj-changes" : "unspecified") : null
        lsp_lifetime             = try(vrf.max_lsp_lifetime, null)
        queue_limit              = try(vrf.queue_limit, null)
        overload_admin_state     = try(vrf.set_overload_bit, null)
        overload_startup_time    = try(vrf.overload_startup_time, null)
        overload_bgp_as_number   = try(vrf.overload_bgp_as_number, null)
        overload_suppress        = try(vrf.overload_suppress, null)

        address_families = { for af in try(vrf.address_families, []) : replace(replace(af.address_family, "ipv4-unicast", "v4"), "ipv6-unicast", "v6") => {
          segment_routing_mpls                    = try(af.segment_routing_mpls, null)
          enable_bfd                              = try(af.bfd, null)
          prefix_advertise_passive_l1             = try(af.advertise_passive_only_l1, null)
          prefix_advertise_passive_l2             = try(af.advertise_passive_only_l2, null)
          control                                 = try(af.adjacency_check, null) != null ? (try(af.adjacency_check) ? "adj-check" : null) : null
          default_information_originate           = try(af.default_information_originate, null)
          default_information_originate_route_map = try(af.default_information_originate_route_map, null)
          distance                                = try(af.distance, null)
          max_ecmp                                = try(af.maximum_paths, null)
          multi_topology                          = try(replace(replace(replace(af.multi_topology, "standard", "st"), "multi-topology-transition", "mtt"), "multi-topology", "mt"), null)
          router_id_interface                     = try(af.router_id_interface_type, null) != null ? "${local.intf_prefix_map[try(af.router_id_interface_type)]}${try(af.router_id_interface_id, "")}" : null
          router_id_ip_address                    = try(af.router_id_ip_address, null)
          table_map                               = try(af.table_map, null)
          table_map_filter                        = try(af.table_map_filter, null) != null ? (try(af.table_map_filter) ? "enabled" : "disabled") : null
        } }
      } }
    )

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
      network_type_p2p             = int.isis_network_point_to_point
      passive                      = int.isis_passive_interface
      priority_l1                  = int.isis_priority_l1
      priority_l2                  = int.isis_priority_l2
      enable_ipv4                  = int.isis_ipv4
      csnp_interval_l1             = int.isis_csnp_interval_l1
      csnp_interval_l2             = int.isis_csnp_interval_l2
      lsp_refresh_interval         = int.isis_lsp_interval
      mesh_group_blocked           = int.isis_mesh_group_blocked
      mesh_group_id                = int.isis_mesh_group
      ipv6_metric_l1               = int.isis_ipv6_metric_l1
      ipv6_metric_l2               = int.isis_ipv6_metric_l2
      n_flag_clear                 = int.isis_n_flag_clear
      retransmit_interval          = int.isis_retransmit_interval
      retransmit_throttle_interval = int.isis_retransmit_throttle_interval
      suppressed_state             = int.isis_suppress_prefix
      ipv4_bfd                     = int.isis_bfd
      ipv6_bfd                     = int.isis_ipv6_bfd
      ipv6                         = int.isis_ipv6
    } if int.device == each.key && int.isis_instance_name == inst.name }
  } }

  depends_on = [
    nxos_feature.feature,
    nxos_loopback_interface.loopback_interface,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_subinterface.subinterface,
    nxos_svi_interface.svi_interface,
    nxos_vrf.vrf,
  ]
}
