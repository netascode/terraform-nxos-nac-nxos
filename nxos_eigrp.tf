locals {
  eigrp_metric_version_map = {
    "32bit" = "narrow"
    "64bit" = "wide"
  }

  # Every interface (incl. subinterfaces) that carries an `eigrp` section.
  eigrp_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.loopbacks, []) : { device = device.name, id = "lo${int.id}", vrf = try(int.vrf, "default"), eigrp = int.eigrp } if try(int.eigrp.process, null) != null],
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : { device = device.name, id = "vlan${int.id}", vrf = try(int.vrf, "default"), eigrp = int.eigrp } if try(int.eigrp.process, null) != null],
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : { device = device.name, id = "eth${int.id}", vrf = try(int.vrf, "default"), eigrp = int.eigrp } if try(int.eigrp.process, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : { device = device.name, id = "po${int.id}", vrf = try(int.vrf, "default"), eigrp = int.eigrp } if try(int.eigrp.process, null) != null],
      flatten([for int in try(local.device_config[device.name].interfaces.ethernets, []) : [
        for sub in try(int.subinterfaces, []) : { device = device.name, id = "eth${int.id}.${sub.id}", vrf = try(sub.vrf, "default"), eigrp = sub.eigrp } if try(sub.eigrp.process, null) != null
      ]]),
      flatten([for int in try(local.device_config[device.name].interfaces.port_channels, []) : [
        for sub in try(int.subinterfaces, []) : { device = device.name, id = "po${int.id}.${sub.id}", vrf = try(sub.vrf, "default"), eigrp = sub.eigrp } if try(sub.eigrp.process, null) != null
      ]]),
    )
  ])

  # device => "process/vrf" => interface map
  eigrp_interfaces_map = { for device in local.devices : device.name => {
    for proc_vrf in distinct([for int in local.eigrp_interfaces : "${int.eigrp.process}/${int.vrf}" if int.device == device.name]) :
    proc_vrf => { for int in local.eigrp_interfaces : int.id => {
      address_families = {
        "ipv4-ucast" = {
          admin_state              = try(int.eigrp.shutdown, null) == null ? null : (try(int.eigrp.shutdown) ? "disabled" : "enabled")
          authentication_mode      = try(int.eigrp.authentication_mode, null)
          authentication_key_chain = try(int.eigrp.authentication_key_chain, null)
          bandwidth                = try(int.eigrp.bandwidth, null)
          bandwidth_percent        = try(int.eigrp.bandwidth_percent, null)
          bfd                      = try(int.eigrp.bfd, null) == null ? null : (try(int.eigrp.bfd) ? "enabled" : "disabled")
          delay                    = try(int.eigrp.delay, null)
          delay_unit               = try(int.eigrp.delay_picoseconds, null) == null ? null : (try(int.eigrp.delay_picoseconds) ? "pico" : "tens-of-micro")
          hello_interval           = try(int.eigrp.hello_interval, null)
          hold_time                = try(int.eigrp.hold_time, null)
          mtu                      = try(int.eigrp.mtu, null)
          next_hop_self            = try(int.eigrp.next_hop_self, null)
          passive                  = try(int.eigrp.passive_interface, null) == null ? null : (try(int.eigrp.passive_interface) ? "enabled" : "disabled")
          split_horizon            = try(int.eigrp.split_horizon, null)
          distribute_lists = length(try(int.eigrp.distribute_lists, [])) > 0 ? { for dl in try(int.eigrp.distribute_lists, []) : dl.direction => {
            route_map   = try(dl.route_map, null)
            prefix_list = try(dl.prefix_list, null)
          } } : null
          offset_lists = length(try(int.eigrp.offset_lists, [])) > 0 ? { for ol in try(int.eigrp.offset_lists, []) : ol.direction => {
            route_map   = try(ol.route_map, null)
            prefix_list = try(ol.prefix_list, null)
            offset      = try(ol.offset, null)
          } } : null
          summary_addresses = length(try(int.eigrp.summary_addresses, [])) > 0 ? { for sa in try(int.eigrp.summary_addresses, []) : sa.prefix => {
            route_map = try(sa.leak_map, null)
            distance  = try(sa.distance, null)
          } } : null
        }
      }
    } if int.device == device.name && "${int.eigrp.process}/${int.vrf}" == proc_vrf }
  } }

  # One entry per (device, process, vrf): the process itself is the "default" VRF.
  eigrp_af_sources = flatten([
    for device in local.devices : [
      for proc in try(local.device_config[device.name].routing.eigrp_processes, []) : concat(
        [{ key = "${device.name}/${proc.name}/default", c = proc }],
        [for vrf in try(proc.vrfs, []) : { key = "${device.name}/${proc.name}/${vrf.vrf}", c = vrf }],
      )
    ]
  ])

  # "device/process/vrf" => ipv4-ucast address family attributes
  eigrp_af_map = { for e in local.eigrp_af_sources : e.key => {
    admin_state              = try(e.c.shutdown, null) == null ? null : (try(e.c.shutdown) ? "disabled" : "enabled")
    asn                      = try(e.c.autonomous_system, null)
    router_id                = try(e.c.router_id, null)
    authentication_mode      = try(e.c.authentication_mode, null)
    authentication_key_chain = try(e.c.authentication_key_chain, null)
    bfd                      = try(e.c.bfd, null)

    default_information_originate_always    = try(e.c.default_information_originate, false) ? try(e.c.default_information_originate_always, false) : null
    default_information_originate_route_map = try(e.c.default_information_originate, false) ? try(e.c.default_information_originate_route_map, null) : null

    default_metric_bandwidth   = try(e.c.default_metric_bandwidth, null)
    default_metric_delay       = try(e.c.default_metric_delay, null)
    default_metric_reliability = try(e.c.default_metric_reliability, null)
    default_metric_load        = try(e.c.default_metric_load, null)
    default_metric_mtu         = try(e.c.default_metric_mtu, null)

    internal_distance = try(e.c.distance_internal, null)
    external_distance = try(e.c.distance_external, null)

    graceful_restart                      = try(e.c.graceful_restart, null)
    graceful_restart_convergence_interval = try(e.c.timers_nsf_converge, null)
    graceful_restart_route_hold_interval  = try(e.c.timers_nsf_route_hold, null)
    graceful_restart_signal_interval      = try(e.c.timers_nsf_signal, null)

    log_adjacency_changes          = try(e.c.log_adjacency_changes, null)
    log_neighbor_warnings_state    = try(e.c.log_neighbor_warnings, null) == null ? null : (try(e.c.log_neighbor_warnings) ? "enabled" : "disabled")
    log_neighbor_warnings_interval = try(e.c.log_neighbor_warnings_interval, null)

    maximum_paths = try(e.c.maximum_paths, null)
    maximum_hops  = try(e.c.metric_maximum_hops, null)
    rib_scale     = try(e.c.metric_rib_scale, null)
    metric_style  = try(local.eigrp_metric_version_map[e.c.metric_version], null)

    metric_weights_type_of_service = try(e.c.metric_weights_tos, null)
    metric_weights_k1              = try(e.c.metric_weights_k1, null)
    metric_weights_k2              = try(e.c.metric_weights_k2, null)
    metric_weights_k3              = try(e.c.metric_weights_k3, null)
    metric_weights_k4              = try(e.c.metric_weights_k4, null)
    metric_weights_k5              = try(e.c.metric_weights_k5, null)
    metric_weights_k6              = try(e.c.metric_weights_k6, null)

    passive_interface_default = try(e.c.passive_interface_default, null)
    suppress_fib_pending      = try(e.c.suppress_fib_pending, null)

    redistribute_maximum_prefix           = try(e.c.redistribute_maximum_prefix, null)
    redistribute_maximum_prefix_threshold = try(e.c.redistribute_maximum_prefix_threshold, null)
    redistribute_maximum_prefix_control   = try(e.c.redistribute_maximum_prefix_warning_only, false) ? "warning" : (try(e.c.redistribute_maximum_prefix_withdraw, false) ? "withdraw" : null)
    redistribute_maximum_prefix_retries   = try(e.c.redistribute_maximum_prefix_withdraw_retries, null)
    redistribute_maximum_prefix_duration  = try(e.c.redistribute_maximum_prefix_withdraw_timeout, null)

    stub_direct       = try(e.c.stub, false) ? try(e.c.stub_direct, false) : null
    stub_static       = try(e.c.stub, false) ? try(e.c.stub_static, false) : null
    stub_summary      = try(e.c.stub, false) ? try(e.c.stub_summary, false) : null
    stub_external     = try(e.c.stub, false) ? try(e.c.stub_redistributed, false) : null
    stub_receive_only = try(e.c.stub, false) ? try(e.c.stub_receive_only, false) : null
    stub_leak_map     = try(e.c.stub, false) ? try(e.c.stub_leak_map, null) : null

    table_map_route_map = try(e.c.table_map, null)
    table_map_always    = try(e.c.table_map, null) == null ? null : (try(e.c.table_map_filter, false) ? false : true)

    active_interval_state = try(e.c.timers_active_time, null) == null ? null : (try(e.c.timers_active_time) == "disabled" ? "disabled" : "enabled")
    active_interval       = try(e.c.timers_active_time, null) == null ? null : (try(e.c.timers_active_time) == "disabled" ? null : try(tonumber(e.c.timers_active_time), null))

    redistributions = length(try(e.c.redistributions, [])) > 0 ? { for redist in try(e.c.redistributions, []) : "${redist.protocol};${try(redist.protocol_instance, "none")};${try(redist.asn, "none")}" => {
      route_map = try(redist.route_map, null)
    } } : null
  } }
}

resource "nxos_eigrp" "eigrp" {
  for_each = { for device in local.devices : device.name => device
  if length(try(local.device_config[device.name].routing.eigrp_processes, [])) > 0 }
  device = each.key

  instances = { for proc in try(local.device_config[each.key].routing.eigrp_processes, []) : proc.name => {
    flush_routes = try(proc.flush_routes, null)
    isolate      = try(proc.isolate, null)

    vrfs = merge(
      # Synthetic "default" VRF from process-level attributes
      {
        "default" = {
          address_families = {
            "ipv4-ucast" = local.eigrp_af_map["${each.key}/${proc.name}/default"]
          }
          interfaces = length(try(local.eigrp_interfaces_map[each.key]["${proc.name}/default"], {})) > 0 ? local.eigrp_interfaces_map[each.key]["${proc.name}/default"] : null
        }
      },
      # Explicit non-default VRFs
      { for vrf in try(proc.vrfs, []) : vrf.vrf => {
        address_families = {
          "ipv4-ucast" = local.eigrp_af_map["${each.key}/${proc.name}/${vrf.vrf}"]
        }
        interfaces = length(try(local.eigrp_interfaces_map[each.key]["${proc.name}/${vrf.vrf}"], {})) > 0 ? local.eigrp_interfaces_map[each.key]["${proc.name}/${vrf.vrf}"] : null
      } }
    )
  } }

  depends_on = [
    nxos_feature.feature,
    nxos_keychain.keychain,
    nxos_loopback_interface.loopback_interface,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_route_policy.route_policy,
    nxos_subinterface.subinterface,
    nxos_svi_interface.svi_interface,
    nxos_vrf.vrf,
  ]
}
