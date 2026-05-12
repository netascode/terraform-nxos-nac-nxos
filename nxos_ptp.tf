locals {
  ptp_interfaces_map = { for device in local.devices : device.name =>
    { for int in local.ptp_interfaces : int.id => {
      announce_interval_type               = try(int.ptp.announce_interval_type, null)
      announce_interval_value              = try(int.ptp.announce_interval, null)
      announce_timeout_type                = try(int.ptp.announce_timeout_type, null)
      announce_timeout_value               = try(int.ptp.announce_timeout, null)
      asymmetric_delay_value               = try(int.ptp.asymmetric_delay_value, null)
      asymmetric_direction                 = try(int.ptp.asymmetric_delay_direction, null)
      cost                                 = try(int.ptp.cost, null)
      delay_request_min_interval_type      = try(int.ptp.delay_request_minimum_interval_type, null)
      delay_request_min_interval_value     = try(int.ptp.delay_request_minimum_interval, null)
      destination_mac                      = try(int.ptp.destination_mac, null)
      domain                               = try(int.ptp.domain, null)
      ipv6_multicast_receive_scope         = try(int.ptp.ipv6_multicast_receive_scope, null)
      ipv6_multicast_transmit_scope        = try(int.ptp.ipv6_multicast_transmit_scope, null)
      negotiation_schema                   = try(int.ptp.negotiation_schema, null)
      neighbor_propagation_delay_threshold = try(int.ptp.neighbor_propagation_delay_threshold, null)
      profile_override                     = try(int.ptp.profile_override, null)
      ptp                                  = try(int.ptp.admin_state, null)
      receive_no_match                     = try(int.ptp.receive_no_match, null)
      role                                 = try(int.ptp.role, null)
      sync_interval_type                   = try(int.ptp.sync_interval_type, null)
      sync_interval_value                  = try(int.ptp.sync_interval, null)
      transmission                         = try(int.ptp.transmission, null)
      transport                            = try(int.ptp.transport, null)
      unicast_source                       = try(int.ptp.unicast_source, null)
      unicast_source_ipv6                  = try(int.ptp.unicast_source_ipv6, null)
      unicast_vrf                          = try(int.ptp.unicast_vrf, null)
      unicast_vrf_ipv6                     = try(int.ptp.unicast_vrf_ipv6, null)
      vlan                                 = try(int.ptp.vlan, null) != null ? "vlan-${try(int.ptp.vlan)}" : null
      peers = length(try(int.ptp.unicast_peers, [])) > 0 ? { for peer in try(int.ptp.unicast_peers, []) : peer.ip => {
        negotiation_schema = try(peer.negotiation_schema, null)
      } } : null
    } if int.device == device.name }
  }
  ptp_device_type_map = {
    "boundary-clock"             = "boundaryClock"
    "generalized-ptp"            = "generalizedPtp"
    "ordinary-clock-grandmaster" = "ordinaryClockGm"
  }

  ptp_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        key    = format("%s/eth%s", device.name, int.id)
        device = device.name
        id     = "eth${int.id}"
        ptp    = try(int.ptp, null)
      } if try(int.ptp, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        key    = format("%s/po%s", device.name, int.id)
        device = device.name
        id     = "po${int.id}"
        ptp    = try(int.ptp, null)
      } if try(int.ptp, null) != null],
    )
  ])
}

resource "nxos_ptp" "ptp" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].ptp, null) != null ||
  length([for int in local.ptp_interfaces : int if int.device == device.name]) > 0 }
  device                               = each.key
  acl_redirect                         = try(local.device_config[each.key].ptp.acl_redirect, null) == null ? null : (try(local.device_config[each.key].ptp.acl_redirect) ? "enabled" : "disabled")
  clock_identity                       = try(local.device_config[each.key].ptp.clock_identity, null)
  clock_operation_one_step             = try(local.device_config[each.key].ptp.clock_operation_one_step, null) == null ? null : (try(local.device_config[each.key].ptp.clock_operation_one_step) ? "enabled" : "disabled")
  clock_periodic_update                = try(local.device_config[each.key].ptp.clock_periodic_update, null) == null ? null : (try(local.device_config[each.key].ptp.clock_periodic_update) ? "enabled" : "disabled")
  clock_periodic_update_interval       = try(local.device_config[each.key].ptp.clock_periodic_update_interval, null)
  clock_sync_auto                      = try(local.device_config[each.key].ptp.clock_sync_auto, null)
  convergence_time                     = try(local.device_config[each.key].ptp.convergence_time, null)
  correction_range_logging             = try(local.device_config[each.key].ptp.correction_range_logging, null) == null ? null : (try(local.device_config[each.key].ptp.correction_range_logging) ? "enabled" : "disabled")
  correction_range_threshold           = try(local.device_config[each.key].ptp.correction_range, null)
  device_type                          = try(local.ptp_device_type_map[try(local.device_config[each.key].ptp.device_type)], null)
  domain_number                        = try(local.device_config[each.key].ptp.domain, null)
  enhanced_client_scale                = try(local.device_config[each.key].ptp.enhanced_client_scale, null) == null ? null : (try(local.device_config[each.key].ptp.enhanced_client_scale) ? "enabled" : "disabled")
  forward_version1                     = try(local.device_config[each.key].ptp.forward_version1, null) == null ? null : (try(local.device_config[each.key].ptp.forward_version1) ? "enabled" : "disabled")
  grandmaster_capable                  = try(local.device_config[each.key].ptp.grandmaster_capable, null) == null ? null : (try(local.device_config[each.key].ptp.grandmaster_capable) ? "enabled" : "disabled")
  grandmaster_capable_convergence_time = try(local.device_config[each.key].ptp.grandmaster_capable_convergence_time, null)
  ipv6_multicast_receive_scope         = try(local.device_config[each.key].ptp.ipv6_multicast_receive_scope, null)
  ipv6_multicast_transmit_scope        = try(local.device_config[each.key].ptp.ipv6_multicast_transmit_scope, null)
  management                           = try(local.device_config[each.key].ptp.management, null) == null ? null : (try(local.device_config[each.key].ptp.management) ? "enabled" : "disabled")
  mean_path_delay                      = try(local.device_config[each.key].ptp.mean_path_delay, null)
  multi_domain                         = try(local.device_config[each.key].ptp.multi_domain, null) == null ? null : (try(local.device_config[each.key].ptp.multi_domain) ? "enabled" : "disabled")
  multi_domain_transition_priority1    = try(local.device_config[each.key].ptp.multi_domain_transition_priority1, null)
  multi_domain_transition_priority2    = try(local.device_config[each.key].ptp.multi_domain_transition_priority2, null)
  notify_grandmaster_change            = try(local.device_config[each.key].ptp.notification_grandmaster_change, null) == null ? null : (try(local.device_config[each.key].ptp.notification_grandmaster_change) ? "enabled" : "disabled")
  notify_parent_change                 = try(local.device_config[each.key].ptp.notification_parent_change, null) == null ? null : (try(local.device_config[each.key].ptp.notification_parent_change) ? "enabled" : "disabled")
  offload                              = try(local.device_config[each.key].ptp.offload, null) == null ? null : (try(local.device_config[each.key].ptp.offload) ? "enabled" : "disabled")
  peer_delay_request_interval          = try(local.device_config[each.key].ptp.peer_delay_request_interval, null)
  priority1                            = try(local.device_config[each.key].ptp.priority1, null)
  priority2                            = try(local.device_config[each.key].ptp.priority2, null)
  scale_1g                             = try(local.device_config[each.key].ptp.scale_on_1g, null)
  source_ip                            = try(local.device_config[each.key].ptp.source, null)
  source_ipv6                          = try(local.device_config[each.key].ptp.source_ipv6, null)
  tolerance_mean_path_delay_state      = try(local.device_config[each.key].ptp.delay_tolerance_mean_path, null) == null ? null : (try(local.device_config[each.key].ptp.delay_tolerance_mean_path) ? "enabled" : "disabled")
  tolerance_mean_path_delay_value      = try(local.device_config[each.key].ptp.delay_tolerance_mean_path_value, null)
  tolerance_reverse_path_delay_state   = try(local.device_config[each.key].ptp.delay_tolerance_reverse_path, null) == null ? null : (try(local.device_config[each.key].ptp.delay_tolerance_reverse_path) ? "enabled" : "disabled")
  tolerance_reverse_path_delay_value   = try(local.device_config[each.key].ptp.delay_tolerance_reverse_path_value, null)
  using_system_clock                   = try(local.device_config[each.key].ptp.using_system_clock, null)
  vrf_name                             = try(local.device_config[each.key].ptp.vrf, null)
  vrf_name_ipv6                        = try(local.device_config[each.key].ptp.vrf_ipv6, null)

  domains = length(try(local.device_config[each.key].ptp.domains, [])) > 0 ? { for domain in try(local.device_config[each.key].ptp.domains, []) : domain.domain => {
    clock_accuracy_threshold = try(domain.clock_accuracy_threshold, null)
    clock_class_threshold    = try(domain.clock_class_threshold, null)
    priority                 = try(domain.priority, null)
  } } : null

  notify_high_correction_interval = try(local.device_config[each.key].ptp.notification_high_correction_interval, null)
  notify_high_correction          = try(local.device_config[each.key].ptp.notification_high_correction, null) == null ? null : (try(local.device_config[each.key].ptp.notification_high_correction) ? "enabled" : "disabled")
  notify_high_correction_periodic = try(local.device_config[each.key].ptp.notification_high_correction_periodic, null) == null ? null : (try(local.device_config[each.key].ptp.notification_high_correction_periodic) ? "enabled" : "disabled")

  notify_port_state_change_category = try(local.device_config[each.key].ptp.notification_port_state_change_category, null)
  notify_port_state_change_interval = try(local.device_config[each.key].ptp.notification_port_state_change_interval, null)
  notify_port_state_change          = try(local.device_config[each.key].ptp.notification_port_state_change, null) == null ? null : (try(local.device_config[each.key].ptp.notification_port_state_change) ? "enabled" : "disabled")
  notify_port_state_change_periodic = try(local.device_config[each.key].ptp.notification_port_state_change_periodic, null) == null ? null : (try(local.device_config[each.key].ptp.notification_port_state_change_periodic) ? "enabled" : "disabled")

  interfaces = length(local.ptp_interfaces_map[each.key]) > 0 ? local.ptp_interfaces_map[each.key] : null

  depends_on = [
    nxos_feature.feature,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
  ]
}
