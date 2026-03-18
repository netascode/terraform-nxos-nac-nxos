locals {
  ospf_interfaces = concat(local.interfaces_ethernets, local.interfaces_loopbacks, local.interfaces_vlans, local.interfaces_port_channels)
}

resource "nxos_ospf" "ospf" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.ospf, local.defaults.nxos.devices.configuration.system.feature.ospf, false) }
  device      = each.key
  admin_state = "enabled"

  instances = { for proc in try(local.device_config[each.key].routing.ospf_processes, []) : proc.name => {
    admin_state = "enabled"

    vrfs = { for vrf in try(proc.vrfs, []) : vrf.vrf => {
      admin_state              = try(vrf.shutdown, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.shutdown, false) ? "disabled" : "enabled"
      bandwidth_reference      = try(vrf.bandwidth_reference, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.bandwidth_reference, null)
      bandwidth_reference_unit = try(vrf.bandwidth_reference_unit, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.bandwidth_reference_unit, null)
      capability_vrf_lite      = try(vrf.capability_vrf_lite, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.capability_vrf_lite, null)
      control = join(",", sort(compact([
        try(vrf.bfd, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.bfd, false) ? "bfd" : "",
        try(vrf.default_passive, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.default_passive, false) ? "default-passive" : "",
        try(vrf.name_lookup, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.name_lookup, false) ? "name-lookup" : "",
      ])))
      default_metric                = try(vrf.default_metric, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.default_metric, null)
      default_route_nssa_pbit_clear = try(vrf.default_route_nssa_pbit_clear, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.default_route_nssa_pbit_clear, null)
      discard_route = join(",", sort(compact([
        try(vrf.discard_route_external, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.discard_route_external, false) ? "ext" : "",
        try(vrf.discard_route_internal, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.discard_route_internal, false) ? "int" : "",
      ])))
      distance              = try(vrf.distance, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.distance, null)
      down_bit_ignore       = try(vrf.down_bit_ignore, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.down_bit_ignore, null)
      log_adjacency_changes = try(vrf.log_adjacency_changes, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.log_adjacency_changes, null)
      max_ecmp              = try(vrf.max_ecmp, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.max_ecmp, null)
      name_lookup_vrf       = try(vrf.name_lookup_vrf, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.name_lookup_vrf, null)
      rfc1583_compatible    = try(vrf.rfc1583_compatible, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.rfc1583_compatible, null)
      router_id             = try(vrf.router_id, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.router_id, null)

      max_metric_await_convergence_bgp_asn = try(vrf.max_metric.await_convergence_bgp_asn, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.max_metric.await_convergence_bgp_asn, null)
      max_metric_control = join(",", sort(compact([
        try(vrf.max_metric.external_lsa, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.max_metric.external_lsa, false) ? "external-lsa" : "",
        try(vrf.max_metric.startup, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.max_metric.startup, false) ? "startup" : "",
        try(vrf.max_metric.stub, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.max_metric.stub, false) ? "stub" : "",
        try(vrf.max_metric.summary_lsa, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.max_metric.summary_lsa, false) ? "summary-lsa" : "",
      ])))
      max_metric_external_lsa     = try(vrf.max_metric.external_lsa_max_metric, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.max_metric.external_lsa_max_metric, null)
      max_metric_summary_lsa      = try(vrf.max_metric.summary_lsa_max_metric, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.max_metric.summary_lsa_max_metric, null)
      max_metric_startup_interval = try(vrf.max_metric.startup_interval, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.max_metric.startup_interval, null)

      areas = { for area in try(vrf.areas, []) : area.area => {
        authentication_type = try(area.authentication_type, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.areas.authentication_type, null)
        cost                = try(area.cost, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.areas.cost, null)
        control = join(",", sort(compact([
          try(area.filter_redistribute, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.areas.filter_redistribute, false) ? "redistribute" : "",
          try(area.filter_summary, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.areas.filter_summary, false) ? "summary" : "",
          try(area.suppress_forwarding_address, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.areas.suppress_forwarding_address, false) ? "suppress-fa" : "",
        ])))
        nssa_translator_role = try(area.nssa_translator_role, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.areas.nssa_translator_role, null)
        segment_routing_mpls = try(area.segment_routing_mpls, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.areas.segment_routing_mpls, false) ? "mpls" : "unspecified"
        type                 = try(area.type, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.areas.type, null)
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
