locals {
  ospf_interfaces = concat(local.interfaces_ethernets, local.interfaces_loopbacks, local.interfaces_vlans, local.interfaces_port_channels)
}

resource "nxos_ospf" "ospf" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].feature.ospf, false) }
  device      = each.key
  admin_state = "enabled"

  instances = { for proc in try(local.device_config[each.key].routing.ospf_processes, []) : proc.name => {
    admin_state = "enabled"

    vrfs = merge(
      # Synthetic "default" VRF from process-level attributes
      {
        "default" = {
          admin_state              = try(proc.shutdown, false) ? "disabled" : "enabled"
          bandwidth_reference      = try(proc.auto_cost_reference_bandwidth, null)
          bandwidth_reference_unit = try(proc.auto_cost_reference_bandwidth_unit, null)
          capability_vrf_lite      = try(proc.capability_vrf_lite, null)
          control = join(",", sort(compact([
            try(proc.bfd, false) ? "bfd" : "",
            try(proc.passive_interface_default, false) ? "default-passive" : "",
            try(proc.name_lookup, false) ? "name-lookup" : "",
          ])))
          default_metric                = try(proc.default_metric, null)
          default_route_nssa_pbit_clear = try(proc.default_route_nssa_abr_pbit_clear, null)
          discard_route = join(",", sort(compact([
            try(proc.discard_route_external, false) ? "ext" : "",
            try(proc.discard_route_internal, false) ? "int" : "",
          ])))
          distance              = try(proc.distance, null)
          down_bit_ignore       = try(proc.down_bit_ignore, null)
          log_adjacency_changes = try(proc.log_adjacency_changes, null)
          max_ecmp              = try(proc.maximum_paths, null)
          name_lookup_vrf       = try(proc.name_lookup_use_vrf, null)
          rfc1583_compatible    = try(proc.rfc1583compatibility, null)
          router_id             = try(proc.router_id, null)

          max_metric_await_convergence_bgp_asn = try(proc.max_metric_router_lsa.on_startup_wait_for_bgp, null)
          max_metric_control = join(",", sort(compact([
            try(proc.max_metric_router_lsa.external_lsa, false) ? "external-lsa" : "",
            try(proc.max_metric_router_lsa.on_startup, false) ? "startup" : "",
            try(proc.max_metric_router_lsa.include_stub, false) ? "stub" : "",
            try(proc.max_metric_router_lsa.summary_lsa, false) ? "summary-lsa" : "",
          ])))
          max_metric_external_lsa     = try(proc.max_metric_router_lsa.external_lsa, false) ? try(proc.max_metric_router_lsa.external_lsa_max_metric, null) : null
          max_metric_summary_lsa      = try(proc.max_metric_router_lsa.summary_lsa, false) ? try(proc.max_metric_router_lsa.summary_lsa_max_metric, null) : null
          max_metric_startup_interval = try(proc.max_metric_router_lsa.on_startup, false) ? try(proc.max_metric_router_lsa.on_startup_timeout, null) : null

          areas = { for area in try(proc.areas, []) : area.id => {
            authentication_type = try(area.authentication, null)
            cost                = try(area.default_cost, null)
            control = join(",", sort(compact([
              try(area.nssa_no_redistribution, null) != null ? (try(area.nssa_no_redistribution, false) ? "" : "redistribute") : "",
              try(area.no_summary, null) != null ? (try(area.no_summary, false) ? "" : "summary") : "",
              try(area.nssa_translate_type7_suppress_fa, false) ? "suppress-fa" : "",
            ])))
            nssa_translator_role = try(area.nssa_translate_type7, null)
            segment_routing_mpls = try(area.segment_routing_mpls, false) ? "mpls" : "unspecified"
            type                 = try(area.type, null)
          } }

          redistributions = { for redist in try(proc.redistributions, []) : "${redist.protocol};${try(redist.protocol_instance, "none")};${try(redist.asn, "none")}" => {
            route_map = try(redist.route_map, null)
          } }

          interfaces = { for int in local.ospf_interfaces : "${int.type}${int.id}" => {
            advertise_secondaries = int.ospf_advertise_secondaries
            area                  = int.ospf_area
            bfd                   = int.ospf_bfd
            cost                  = int.ospf_cost
            dead_interval         = int.ospf_dead_interval
            hello_interval        = int.ospf_hello_interval
            network_type          = int.ospf_network_type
            passive               = int.ospf_passive
            priority              = int.ospf_priority
            control = join(",", sort(compact([
              int.ospf_advertise_subnet ? "advert-subnet" : "",
              int.ospf_mtu_ignore ? "mtu-ignore" : "",
            ])))
            node_flag                          = int.ospf_node_flag
            retransmit_interval                = int.ospf_retransmit_interval
            transmit_delay                     = int.ospf_transmit_delay
            authentication_key                 = int.ospf_authentication_key
            authentication_key_id              = int.ospf_authentication_key_id
            authentication_key_secure_mode     = int.ospf_authentication_key_secure_mode
            authentication_keychain            = int.ospf_authentication_keychain
            authentication_md5_key             = int.ospf_authentication_md5_key
            authentication_md5_key_secure_mode = int.ospf_authentication_md5_key_secure_mode
            authentication_type                = int.ospf_authentication_type
          } if int.device == each.key && int.ospf_process_name == proc.name && int.vrf == "default" }
        }
      },
      # Explicit non-default VRFs
      { for vrf in try(proc.vrfs, []) : vrf.vrf => {
        admin_state              = try(vrf.shutdown, false) ? "disabled" : "enabled"
        bandwidth_reference      = try(vrf.auto_cost_reference_bandwidth, null)
        bandwidth_reference_unit = try(vrf.auto_cost_reference_bandwidth_unit, null)
        capability_vrf_lite      = try(vrf.capability_vrf_lite, null)
        control = join(",", sort(compact([
          try(vrf.bfd, false) ? "bfd" : "",
          try(vrf.passive_interface_default, false) ? "default-passive" : "",
          try(vrf.name_lookup, false) ? "name-lookup" : "",
        ])))
        default_metric                = try(vrf.default_metric, null)
        default_route_nssa_pbit_clear = try(vrf.default_route_nssa_abr_pbit_clear, null)
        discard_route = join(",", sort(compact([
          try(vrf.discard_route_external, false) ? "ext" : "",
          try(vrf.discard_route_internal, false) ? "int" : "",
        ])))
        distance              = try(vrf.distance, null)
        down_bit_ignore       = try(vrf.down_bit_ignore, null)
        log_adjacency_changes = try(vrf.log_adjacency_changes, null)
        max_ecmp              = try(vrf.maximum_paths, null)
        name_lookup_vrf       = try(vrf.name_lookup_use_vrf, null)
        rfc1583_compatible    = try(vrf.rfc1583compatibility, null)
        router_id             = try(vrf.router_id, null)

        max_metric_await_convergence_bgp_asn = try(vrf.max_metric_router_lsa.on_startup_wait_for_bgp, null)
        max_metric_control = join(",", sort(compact([
          try(vrf.max_metric_router_lsa.external_lsa, false) ? "external-lsa" : "",
          try(vrf.max_metric_router_lsa.on_startup, false) ? "startup" : "",
          try(vrf.max_metric_router_lsa.include_stub, false) ? "stub" : "",
          try(vrf.max_metric_router_lsa.summary_lsa, false) ? "summary-lsa" : "",
        ])))
        max_metric_external_lsa     = try(vrf.max_metric_router_lsa.external_lsa, false) ? try(vrf.max_metric_router_lsa.external_lsa_max_metric, null) : null
        max_metric_summary_lsa      = try(vrf.max_metric_router_lsa.summary_lsa, false) ? try(vrf.max_metric_router_lsa.summary_lsa_max_metric, null) : null
        max_metric_startup_interval = try(vrf.max_metric_router_lsa.on_startup, false) ? try(vrf.max_metric_router_lsa.on_startup_timeout, null) : null

        areas = { for area in try(vrf.areas, []) : area.id => {
          authentication_type = try(area.authentication, null)
          cost                = try(area.default_cost, null)
          control = join(",", sort(compact([
            try(area.nssa_no_redistribution, null) != null ? (try(area.nssa_no_redistribution, false) ? "" : "redistribute") : "",
            try(area.no_summary, null) != null ? (try(area.no_summary, false) ? "" : "summary") : "",
            try(area.nssa_translate_type7_suppress_fa, false) ? "suppress-fa" : "",
          ])))
          nssa_translator_role = try(area.nssa_translate_type7, null)
          segment_routing_mpls = try(area.segment_routing_mpls, false) ? "mpls" : "unspecified"
          type                 = try(area.type, null)
        } }

        redistributions = { for redist in try(vrf.redistributions, []) : "${redist.protocol};${try(redist.protocol_instance, "none")};${try(redist.asn, "none")}" => {
          route_map = try(redist.route_map, null)
        } }

        interfaces = { for int in local.ospf_interfaces : "${int.type}${int.id}" => {
          advertise_secondaries = int.ospf_advertise_secondaries
          area                  = int.ospf_area
          bfd                   = int.ospf_bfd
          cost                  = int.ospf_cost
          dead_interval         = int.ospf_dead_interval
          hello_interval        = int.ospf_hello_interval
          network_type          = int.ospf_network_type
          passive               = int.ospf_passive
          priority              = int.ospf_priority
          control = join(",", sort(compact([
            int.ospf_advertise_subnet ? "advert-subnet" : "",
            int.ospf_mtu_ignore ? "mtu-ignore" : "",
          ])))
          node_flag                          = int.ospf_node_flag
          retransmit_interval                = int.ospf_retransmit_interval
          transmit_delay                     = int.ospf_transmit_delay
          authentication_key                 = int.ospf_authentication_key
          authentication_key_id              = int.ospf_authentication_key_id
          authentication_key_secure_mode     = int.ospf_authentication_key_secure_mode
          authentication_keychain            = int.ospf_authentication_keychain
          authentication_md5_key             = int.ospf_authentication_md5_key
          authentication_md5_key_secure_mode = int.ospf_authentication_md5_key_secure_mode
          authentication_type                = int.ospf_authentication_type
        } if int.device == each.key && int.ospf_process_name == proc.name && int.vrf == vrf.vrf }
      } }
    )
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
