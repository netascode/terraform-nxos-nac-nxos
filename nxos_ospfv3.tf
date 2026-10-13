locals {
  ospfv3_interfaces_map = { for device in local.devices : device.name =>
    { for int in local.ospfv3_interfaces : "${int.type}${int.id}" => {
      advertise_secondaries = int.ospfv3_advertise_secondaries
      area                  = int.ospfv3_area == null ? null : can(tonumber(int.ospfv3_area)) ? format("%d.%d.%d.%d", floor(tonumber(int.ospfv3_area) / 16777216) % 256, floor(tonumber(int.ospfv3_area) / 65536) % 256, floor(tonumber(int.ospfv3_area) / 256) % 256, tonumber(int.ospfv3_area) % 256) : tostring(int.ospfv3_area)
      bfd_control           = int.ospfv3_bfd
      cost                  = int.ospfv3_cost
      dead_interval         = int.ospfv3_dead_interval
      hello_interval        = int.ospfv3_hello_interval
      network_type          = int.ospfv3_network_type
      passive               = int.ospfv3_passive_interface
      priority              = int.ospfv3_priority
      admin_state           = null
      instance_name         = int.ospfv3_process
      instance_id           = int.ospfv3_instance_id
      mtu_ignore            = int.ospfv3_mtu_ignore
      retransmit_interval   = int.ospfv3_retransmit_interval
      transmit_delay        = int.ospfv3_transmit_delay
    } if int.device == device.name && int.ospfv3_process != null }
  }
  ospfv3_interfaces = concat(local.interfaces_ethernets, local.interfaces_loopbacks, local.interfaces_vlans, local.interfaces_port_channels, local.interfaces_subinterfaces)
  ospfv3_address_family_map = {
    "ipv6-unicast" = "ipv6-ucast"
  }

  # Router-level areas (`area <id> ...`) and address family areas (`address-family ipv6 unicast` > `area <id> ...`) both map to the provider areas map
  ospfv3_vrfs = flatten([for device in local.devices : [for proc in try(local.device_config[device.name].routing.ospfv3_processes, []) : [
    for vrf_name, vrf in merge({ "default" = proc }, { for v in try(proc.vrfs, []) : v.vrf => v }) : {
      key          = "${device.name}/${proc.name}/${vrf_name}"
      router_areas = { for area in try(vrf.areas, []) : (can(tonumber(area.id)) ? format("%d.%d.%d.%d", floor(tonumber(area.id) / 16777216) % 256, floor(tonumber(area.id) / 65536) % 256, floor(tonumber(area.id) / 256) % 256, tonumber(area.id) % 256) : tostring(area.id)) => area }
      af_areas = { for af in try(vrf.address_families, []) : local.ospfv3_address_family_map[af.address_family] => {
        for area in try(af.areas, []) : (can(tonumber(area.id)) ? format("%d.%d.%d.%d", floor(tonumber(area.id) / 16777216) % 256, floor(tonumber(area.id) / 65536) % 256, floor(tonumber(area.id) / 256) % 256, tonumber(area.id) % 256) : tostring(area.id)) => area
      } }
    }
  ]]])

  ospfv3_areas_map = { for v in local.ospfv3_vrfs : v.key => {
    for area_id in distinct(concat(keys(v.router_areas), flatten([for af, areas in v.af_areas : keys(areas)]))) : area_id => {
      type                     = try(v.router_areas[area_id].type, null)
      redistribute             = try(v.router_areas[area_id].redistribute, null)
      nssa_translator_role     = try(v.router_areas[area_id].nssa_translate_type7, null)
      summary                  = try(v.router_areas[area_id].summary, null)
      suppress_forward_address = try(v.router_areas[area_id].nssa_translate_type7_suppress_fa, null)
      address_families = length([for af, areas in v.af_areas : af if contains(keys(areas), area_id)]) > 0 ? { for af, areas in v.af_areas : af => {
        cost = try(areas[area_id].default_cost, null) == null ? null : tostring(areas[area_id].default_cost)
        ranges = length(try(areas[area_id].ranges, [])) > 0 ? { for range in try(areas[area_id].ranges, []) : range.prefix => {
          control = try(range.not_advertise, null) == null ? null : (try(range.not_advertise) ? "no-advertise" : "unspecified")
          cost    = try(range.cost, null) == null ? null : tostring(range.cost)
        } } : null
      } if contains(keys(areas), area_id) } : null
    }
  } }
}

resource "nxos_ospfv3" "ospfv3" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].feature.ospfv3, false) }
  device      = each.key
  admin_state = null

  instances = length(try(local.device_config[each.key].routing.ospfv3_processes, [])) > 0 ? { for proc in try(local.device_config[each.key].routing.ospfv3_processes, []) : proc.name => {
    flush_routes = try(proc.flush_routes, null)
    isolate      = try(proc.isolate, null)

    vrfs = merge(
      # Synthetic "default" VRF from process-level attributes
      {
        "default" = {
          admin_state               = try(proc.shutdown, null) == null ? null : (try(proc.shutdown) ? "disabled" : "enabled")
          bandwidth_reference       = try(proc.auto_cost_reference_bandwidth, null)
          bandwidth_reference_unit  = try(proc.auto_cost_reference_bandwidth_unit, null)
          router_id                 = try(proc.router_id, null)
          bfd_control               = try(proc.bfd, null)
          log_adjacency_changes     = try(proc.log_adjacency_changes, null)
          discard_route_external    = try(proc.discard_route_external, null)
          discard_route_internal    = try(proc.discard_route_internal, null)
          name_lookup               = try(proc.name_lookup, null)
          passive_interface_default = try(proc.passive_interface_default, null)

          lsa_throttle_start_interval = try(proc.timers_throttle_lsa_start_time, null)
          lsa_throttle_hold_interval  = try(proc.timers_throttle_lsa_hold_time, null)
          lsa_throttle_max_interval   = try(proc.timers_throttle_lsa_max_time, null)
          lsa_arrival_interval        = try(proc.timers_lsa_arrival, null)
          lsa_group_pacing_interval   = try(proc.timers_lsa_group_pacing, null)
          graceful_restart_control    = try(proc.graceful_restart, null) == false ? "disabled" : (try(proc.graceful_restart_planned_only, false) ? "planned-only" : (try(proc.graceful_restart, null) == true ? "complete" : null))
          graceful_restart_period     = try(proc.graceful_restart_grace_period, null)
          graceful_restart_helper     = try(proc.graceful_restart_helper_disable, null) == null ? null : !try(proc.graceful_restart_helper_disable)

          areas = length(try(local.ospfv3_areas_map["${each.key}/${proc.name}/default"], {})) > 0 ? local.ospfv3_areas_map["${each.key}/${proc.name}/default"] : null

          address_families = length(try(proc.address_families, [])) > 0 ? { for af in try(proc.address_families, []) : local.ospfv3_address_family_map[af.address_family] => {
            administrative_distance       = try(af.distance, null)
            default_metric                = try(af.default_metric, null)
            default_route_nssa_pbit_clear = try(af.default_route_nssa_abr_pbit_clear, null)
            max_ecmp_cost                 = try(af.maximum_paths, null)

            default_information_originate_always    = try(af.default_information_originate_always, null) != null ? try(af.default_information_originate_always) : (try(af.default_information_originate, false) ? false : null)
            default_information_originate_route_map = try(af.default_information_originate_route_map, null)
            spf_throttle_initial_interval           = try(af.timers_throttle_spf_start_time, null)
            spf_throttle_hold_interval              = try(af.timers_throttle_spf_hold_time, null)
            spf_throttle_max_interval               = try(af.timers_throttle_spf_max_time, null)

            redistributions = length(try(af.redistributions, [])) > 0 ? { for redist in try(af.redistributions, []) : "${redist.protocol};${try(redist.protocol_instance, "none")};${try(redist.asn, "none")}" => {
              route_map        = try(redist.route_map, null)
              srv6_prefix_type = redist.protocol == "srv6" ? "locator" : null
            } } : null

            summary_addresses = length(try(af.summary_addresses, [])) > 0 ? { for sum in try(af.summary_addresses, []) : sum.prefix => {
              control = try(sum.not_advertise, null) == null ? null : (try(sum.not_advertise) ? "no-advertise" : "unspecified")
              tag     = try(sum.tag, null)
            } } : null
          } } : null
        }
      },
      # Explicit non-default VRFs
      { for vrf in try(proc.vrfs, []) : vrf.vrf => {
        admin_state               = try(vrf.shutdown, null) == null ? null : (try(vrf.shutdown) ? "disabled" : "enabled")
        bandwidth_reference       = try(vrf.auto_cost_reference_bandwidth, null)
        bandwidth_reference_unit  = try(vrf.auto_cost_reference_bandwidth_unit, null)
        router_id                 = try(vrf.router_id, null)
        bfd_control               = try(vrf.bfd, null)
        log_adjacency_changes     = try(vrf.log_adjacency_changes, null)
        discard_route_external    = try(vrf.discard_route_external, null)
        discard_route_internal    = try(vrf.discard_route_internal, null)
        name_lookup               = try(vrf.name_lookup, null)
        passive_interface_default = try(vrf.passive_interface_default, null)

        lsa_throttle_start_interval = try(vrf.timers_throttle_lsa_start_time, null)
        lsa_throttle_hold_interval  = try(vrf.timers_throttle_lsa_hold_time, null)
        lsa_throttle_max_interval   = try(vrf.timers_throttle_lsa_max_time, null)
        lsa_arrival_interval        = try(vrf.timers_lsa_arrival, null)
        lsa_group_pacing_interval   = try(vrf.timers_lsa_group_pacing, null)
        graceful_restart_control    = try(vrf.graceful_restart, null) == false ? "disabled" : (try(vrf.graceful_restart_planned_only, false) ? "planned-only" : (try(vrf.graceful_restart, null) == true ? "complete" : null))
        graceful_restart_period     = try(vrf.graceful_restart_grace_period, null)
        graceful_restart_helper     = try(vrf.graceful_restart_helper_disable, null) == null ? null : !try(vrf.graceful_restart_helper_disable)

        areas = length(try(local.ospfv3_areas_map["${each.key}/${proc.name}/${vrf.vrf}"], {})) > 0 ? local.ospfv3_areas_map["${each.key}/${proc.name}/${vrf.vrf}"] : null

        address_families = length(try(vrf.address_families, [])) > 0 ? { for af in try(vrf.address_families, []) : local.ospfv3_address_family_map[af.address_family] => {
          administrative_distance       = try(af.distance, null)
          default_metric                = try(af.default_metric, null)
          default_route_nssa_pbit_clear = try(af.default_route_nssa_abr_pbit_clear, null)
          max_ecmp_cost                 = try(af.maximum_paths, null)

          default_information_originate_always    = try(af.default_information_originate_always, null) != null ? try(af.default_information_originate_always) : (try(af.default_information_originate, false) ? false : null)
          default_information_originate_route_map = try(af.default_information_originate_route_map, null)
          spf_throttle_initial_interval           = try(af.timers_throttle_spf_start_time, null)
          spf_throttle_hold_interval              = try(af.timers_throttle_spf_hold_time, null)
          spf_throttle_max_interval               = try(af.timers_throttle_spf_max_time, null)

          redistributions = length(try(af.redistributions, [])) > 0 ? { for redist in try(af.redistributions, []) : "${redist.protocol};${try(redist.protocol_instance, "none")};${try(redist.asn, "none")}" => {
            route_map        = try(redist.route_map, null)
            srv6_prefix_type = redist.protocol == "srv6" ? "locator" : null
          } } : null

          summary_addresses = length(try(af.summary_addresses, [])) > 0 ? { for sum in try(af.summary_addresses, []) : sum.prefix => {
            control = try(sum.not_advertise, null) == null ? null : (try(sum.not_advertise) ? "no-advertise" : "unspecified")
            tag     = try(sum.tag, null)
          } } : null
        } } : null
      } }
    )
  } } : null

  interfaces = length(local.ospfv3_interfaces_map[each.key]) > 0 ? local.ospfv3_interfaces_map[each.key] : null

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
