locals {
  ospfv3_interfaces = concat(local.interfaces_ethernets, local.interfaces_loopbacks, local.interfaces_vlans, local.interfaces_port_channels)
  ospfv3_address_family_map = {
    "ipv6_unicast" = "ipv6-ucast"
  }
}

resource "nxos_ospfv3" "ospfv3" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].feature.ospfv3, local.defaults.nxos.devices.configuration.feature.ospfv3, false) }
  device      = each.key
  admin_state = "enabled"

  instances = { for proc in try(local.device_config[each.key].routing.ospfv3_processes, []) : proc.name => {
    admin_state  = try(proc.shutdown, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.shutdown, false) ? "disabled" : "enabled"
    flush_routes = try(proc.flush_routes, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.flush_routes, null)
    isolate      = try(proc.isolate, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.isolate, null)

    vrfs = { for vrf in try(proc.vrfs, []) : vrf.vrf => {
      admin_state               = try(vrf.shutdown, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.shutdown, false) ? "disabled" : "enabled"
      bandwidth_reference       = try(vrf.auto_cost_reference_bandwidth, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.auto_cost_reference_bandwidth, null)
      bandwidth_reference_unit  = try(vrf.auto_cost_reference_bandwidth_unit, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.auto_cost_reference_bandwidth_unit, null)
      router_id                 = try(vrf.router_id, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.router_id, null)
      bfd_control               = try(vrf.bfd, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.bfd, null)
      log_adjacency_changes     = try(vrf.log_adjacency_changes, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.log_adjacency_changes, null)
      discard_route_external    = try(vrf.discard_route_external, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.discard_route_external, null)
      discard_route_internal    = try(vrf.discard_route_internal, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.discard_route_internal, null)
      name_lookup               = try(vrf.name_lookup, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.name_lookup, null)
      passive_interface_default = try(vrf.passive_interface_default, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.passive_interface_default, null)

      areas = { for area in try(vrf.areas, []) : area.id => {
        type                     = try(area.type, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.areas.type, null)
        redistribute             = try(area.redistribute, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.areas.redistribute, null)
        nssa_translator_role     = try(area.nssa_translate_type7, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.areas.nssa_translate_type7, null)
        summary                  = try(area.summary, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.areas.summary, null)
        suppress_forward_address = try(area.nssa_translate_type7_suppress_fa, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.areas.nssa_translate_type7_suppress_fa, null)
      } }

      address_families = { for af in try(vrf.address_families, []) : local.ospfv3_address_family_map[af.address_family] => {
        administrative_distance       = try(af.distance, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.address_families.distance, null)
        default_metric                = try(af.default_metric, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.address_families.default_metric, null)
        default_route_nssa_pbit_clear = try(af.default_route_nssa_abr_pbit_clear, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.address_families.default_route_nssa_abr_pbit_clear, null)
        max_ecmp_cost                 = try(af.maximum_paths, local.defaults.nxos.devices.configuration.routing.ospfv3_processes.vrfs.address_families.maximum_paths, null)
      } }
    } }
  } }

  interfaces = { for int in local.ospfv3_interfaces : "${int.type}${int.id}" => {
    advertise_secondaries = int.ospfv3_advertise_secondaries
    area                  = int.ospfv3_area
    bfd_control           = int.ospfv3_bfd
    cost                  = int.ospfv3_cost
    dead_interval         = int.ospfv3_dead_interval
    hello_interval        = int.ospfv3_hello_interval
    network_type          = int.ospfv3_network_type
    passive               = int.ospfv3_passive_interface
    priority              = int.ospfv3_priority
    admin_state           = "enabled"
    instance_name         = int.ospfv3_process
    instance_id           = int.ospfv3_instance_id
    mtu_ignore            = int.ospfv3_mtu_ignore
    retransmit_interval   = int.ospfv3_retransmit_interval
    transmit_delay        = int.ospfv3_transmit_delay
  } if int.device == each.key && int.ospfv3_process != null }

  depends_on = [
    nxos_feature.feature,
    nxos_loopback_interface.loopback_interface,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_svi_interface.svi_interface,
    nxos_vrf.vrf,
  ]
}
