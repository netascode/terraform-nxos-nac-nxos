locals {
  eigrp_address_family_names_map = {
    "ipv4-unicast" = "ipv4-ucast"
    "ipv6-unicast" = "ipv6-ucast"
  }

  eigrp_interfaces = concat(local.interfaces_ethernets, local.interfaces_loopbacks, local.interfaces_vlans, local.interfaces_port_channels, local.interfaces_subinterfaces)

  # Address families per device, process and VRF ("default" VRF from process-level address_families)
  eigrp_address_families_map = { for device in local.devices : device.name => {
    for proc in try(local.device_config[device.name].routing.eigrp_processes, []) : proc.name => {
      for vrf in concat([{ vrf = "default", address_families = try(proc.address_families, []) }], try(proc.vrfs, [])) : vrf.vrf => {
        for af in try(vrf.address_families, []) : local.eigrp_address_family_names_map[af.address_family] => {
          admin_state                                                = try(af.shutdown, null) == null ? null : (try(af.shutdown) ? "disabled" : "enabled")
          asn                                                        = try(af.autonomous_system, null)
          router_id                                                  = try(af.router_id, null)
          internal_distance                                          = try(af.distance_internal, null)
          external_distance                                          = try(af.distance_external, null)
          maximum_paths                                              = try(af.maximum_paths, null)
          active_interval_state                                      = try(af.timers_active_time, null) == null ? null : (try(af.timers_active_time) == "disabled" ? "disabled" : "enabled")
          active_interval                                            = try(af.timers_active_time, null) == null || try(af.timers_active_time, null) == "disabled" ? null : try(af.timers_active_time)
          metric_style                                               = try(af.metric_version_64bit, null) == null ? null : (try(af.metric_version_64bit) ? "wide" : "narrow")
          rib_scale                                                  = try(af.metric_rib_scale, null)
          maximum_hops                                               = try(af.metric_maximum_hops, null)
          log_adjacency_changes                                      = try(af.log_adjacency_changes, null)
          log_neighbor_warnings_state                                = try(af.log_neighbor_warnings, null) == null ? null : (try(af.log_neighbor_warnings) ? "enabled" : "disabled")
          log_neighbor_warnings_interval                             = try(af.log_neighbor_warnings_interval, null)
          passive_interface_default                                  = try(af.passive_interface_default, null)
          suppress_fib_pending                                       = try(af.suppress_fib_pending, null)
          bfd                                                        = try(af.bfd, null)
          authentication_mode                                        = try(af.authentication_mode, null)
          authentication_key_chain                                   = try(af.authentication_key_chain, null)
          default_metric_bandwidth                                   = try(af.default_metric_bandwidth, null)
          default_metric_delay                                       = try(af.default_metric_delay, null)
          default_metric_reliability                                 = try(af.default_metric_reliability, null)
          default_metric_load                                        = try(af.default_metric_loading, null)
          default_metric_mtu                                         = try(af.default_metric_mtu, null)
          graceful_restart                                           = try(af.graceful_restart, null)
          graceful_restart_route_hold_interval                       = try(af.timers_nsf_route_hold, null)
          graceful_restart_convergence_interval                      = try(af.timers_nsf_converge, null)
          graceful_restart_signal_interval                           = try(af.timers_nsf_signal, null)
          graceful_restart_await_redistribution_protocol_convergence = try(af.nsf_await_redist_proto_convergence, null)
          metric_weights_type_of_service                             = try(af.metric_weights_tos, null)
          metric_weights_k1                                          = try(af.metric_weights_k1, null)
          metric_weights_k2                                          = try(af.metric_weights_k2, null)
          metric_weights_k3                                          = try(af.metric_weights_k3, null)
          metric_weights_k4                                          = try(af.metric_weights_k4, null)
          metric_weights_k5                                          = try(af.metric_weights_k5, null)
          metric_weights_k6                                          = try(af.metric_weights_k6, null)
          # `default-information originate` without options creates the policy with always = false
          default_information_originate_always    = try(af.default_information_originate_always, null) != null ? try(af.default_information_originate_always) : (try(af.default_information_originate, false) ? false : null)
          default_information_originate_route_map = try(af.default_information_originate_route_map, null)
          redistribute_maximum_prefix             = try(af.redistribute_maximum_prefix, null)
          redistribute_maximum_prefix_threshold   = try(af.redistribute_maximum_prefix_threshold, null)
          redistribute_maximum_prefix_control     = try(af.redistribute_maximum_prefix_warning_only, false) ? "warning" : (try(af.redistribute_maximum_prefix_withdraw, false) ? "withdraw" : null)
          redistribute_maximum_prefix_retries     = try(af.redistribute_maximum_prefix_retries, null)
          redistribute_maximum_prefix_duration    = try(af.redistribute_maximum_prefix_timeout, null)
          table_map_route_map                     = try(af.table_map, null)
          table_map_always                        = try(af.table_map_filter, null) == null ? null : !try(af.table_map_filter)
          # Plain `stub` advertises connected and summary routes
          stub_direct       = try(af.stub_direct, null) != null ? try(af.stub_direct) : (try(af.stub, false) ? true : null)
          stub_static       = try(af.stub_static, null)
          stub_summary      = try(af.stub_summary, null) != null ? try(af.stub_summary) : (try(af.stub, false) ? true : null)
          stub_external     = try(af.stub_redistributed, null)
          stub_receive_only = try(af.stub_receive_only, null)
          stub_leak_map     = try(af.stub_leak_map, null)
          redistributions = length(try(af.redistributions, [])) > 0 ? { for redist in try(af.redistributions, []) : "${redist.protocol};${try(redist.protocol_instance, "none")};${try(redist.asn, "none")}" => {
            route_map = try(redist.route_map, null)
          } } : null
        }
      }
    }
  } }

  # Interfaces per device and "<process>/<vrf>"
  eigrp_interfaces_map = { for device in local.devices : device.name => {
    for proc_vrf in distinct([for int in local.eigrp_interfaces : "${int.eigrp_instance_name}/${int.vrf}" if int.device == device.name && int.eigrp_instance_name != null]) :
    proc_vrf => { for int in local.eigrp_interfaces : "${int.type}${int.id}" => {
      address_families = length(int.eigrp_address_families) > 0 ? { for af in int.eigrp_address_families : local.eigrp_address_family_names_map[af.address_family] => {
        admin_state              = try(af.shutdown, null) == null ? null : (try(af.shutdown) ? "disabled" : "enabled")
        hello_interval           = try(af.hello_interval, null)
        hold_time                = try(af.hold_time, null)
        bandwidth                = try(af.bandwidth, null)
        bandwidth_percent        = try(af.bandwidth_percent, null)
        delay                    = try(af.delay, null)
        delay_unit               = try(af.delay_picoseconds, null) == null ? null : (try(af.delay_picoseconds) ? "pico" : "tens-of-micro")
        mtu                      = try(af.mtu, null)
        bfd                      = try(af.bfd, null) == null ? null : (try(af.bfd) ? "enabled" : "disabled")
        next_hop_self            = try(af.next_hop_self, null)
        split_horizon            = try(af.split_horizon, null)
        passive                  = try(af.passive_interface, null) == null ? null : (try(af.passive_interface) ? "enabled" : "disabled")
        authentication_mode      = try(af.authentication_mode, null)
        authentication_key_chain = try(af.authentication_key_chain, null)
        distribute_lists = length(try(af.distribute_lists, [])) > 0 ? { for dl in try(af.distribute_lists, []) : dl.direction => {
          route_map   = try(dl.route_map, null)
          prefix_list = try(dl.prefix_list, null)
        } } : null
        offset_lists = length(try(af.offset_lists, [])) > 0 ? { for ol in try(af.offset_lists, []) : ol.direction => {
          route_map   = try(ol.route_map, null)
          prefix_list = try(ol.prefix_list, null)
          offset      = try(ol.offset, null)
        } } : null
        summary_addresses = length(try(af.summary_addresses, [])) > 0 ? { for sa in try(af.summary_addresses, []) : sa.prefix => {
          route_map = try(sa.leak_map, null)
          distance  = try(sa.distance, null)
        } } : null
      } } : null
    } if int.device == device.name && int.eigrp_instance_name == split("/", proc_vrf)[0] && int.vrf == split("/", proc_vrf)[1] }
  } }
}

resource "nxos_eigrp" "eigrp" {
  for_each = { for device in local.devices : device.name => device if try(local.device_config[device.name].feature.eigrp, false) }
  device   = each.key

  instances = length(try(local.device_config[each.key].routing.eigrp_processes, [])) > 0 ? { for proc in try(local.device_config[each.key].routing.eigrp_processes, []) : proc.name => {
    flush_routes = try(proc.flush_routes, null)
    isolate      = try(proc.isolate, null)

    vrfs = { for vrf, afs in local.eigrp_address_families_map[each.key][proc.name] : vrf => {
      address_families = length(afs) > 0 ? afs : null
      interfaces       = length(try(local.eigrp_interfaces_map[each.key]["${proc.name}/${vrf}"], {})) > 0 ? local.eigrp_interfaces_map[each.key]["${proc.name}/${vrf}"] : null
    } }
  } } : null

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
