locals {
  vpc_keepalive = { for device in local.devices : device.name => {
    precedence_is_string = try(local.device_config[device.name].vpc.keepalive.precedence, null) != null ? can(tonumber(try(local.device_config[device.name].vpc.keepalive.precedence))) == false : false
    precedence_is_number = try(local.device_config[device.name].vpc.keepalive.precedence, null) != null ? can(tonumber(try(local.device_config[device.name].vpc.keepalive.precedence))) : false
    precedence_value     = try(local.device_config[device.name].vpc.keepalive.precedence, null)
    tos_is_string        = try(local.device_config[device.name].vpc.keepalive.tos, null) != null ? can(tonumber(try(local.device_config[device.name].vpc.keepalive.tos))) == false : false
    tos_is_number        = try(local.device_config[device.name].vpc.keepalive.tos, null) != null ? can(tonumber(try(local.device_config[device.name].vpc.keepalive.tos))) : false
    tos_value            = try(local.device_config[device.name].vpc.keepalive.tos, null)
    tos_byte_value       = try(local.device_config[device.name].vpc.keepalive.tos_byte, null)
  } }
}

resource "nxos_vpc" "vpc" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].vpc.domain_id, null) != null }
  device                                       = each.key
  admin_state                                  = "enabled"
  instance_admin_state                         = "enabled"
  domain_id                                    = try(local.device_config[each.key].vpc.domain_id, null)
  auto_recovery                                = try(local.device_config[each.key].vpc.auto_recovery, null) == null ? null : (try(local.device_config[each.key].vpc.auto_recovery) ? "enabled" : "disabled")
  auto_recovery_interval                       = try(local.device_config[each.key].vpc.auto_recovery_reload_delay, null)
  delay_restore_orphan_port                    = try(local.device_config[each.key].vpc.delay_restore_orphan_port, null)
  delay_restore_svi                            = try(local.device_config[each.key].vpc.delay_restore_interface_vlan, null)
  delay_restore_vpc                            = try(local.device_config[each.key].vpc.delay_restore, null)
  dscp                                         = try(local.device_config[each.key].vpc.dscp, null)
  fast_convergence                             = try(local.device_config[each.key].vpc.fast_convergence, null) == null ? null : (try(local.device_config[each.key].vpc.fast_convergence) ? "enabled" : "disabled")
  graceful_consistency_check                   = try(local.device_config[each.key].vpc.graceful_consistency_check, null) == null ? null : (try(local.device_config[each.key].vpc.graceful_consistency_check) ? "enabled" : "disabled")
  l3_peer_router                               = try(local.device_config[each.key].vpc.layer3_peer_router, null) == null ? null : (try(local.device_config[each.key].vpc.layer3_peer_router) ? "enabled" : "disabled")
  l3_peer_router_syslog                        = try(local.device_config[each.key].vpc.layer3_peer_router_syslog, null) == null ? null : (try(local.device_config[each.key].vpc.layer3_peer_router_syslog) ? "enabled" : "disabled")
  l3_peer_router_syslog_interval               = try(local.device_config[each.key].vpc.layer3_peer_router_syslog_interval, null)
  peer_gateway                                 = try(local.device_config[each.key].vpc.peer_gateway, null) == null ? null : (try(local.device_config[each.key].vpc.peer_gateway) ? "enabled" : "disabled")
  peer_ip                                      = try(local.device_config[each.key].vpc.virtual_peer_link_destination, null)
  peer_switch                                  = try(local.device_config[each.key].vpc.peer_switch, null) == null ? null : (try(local.device_config[each.key].vpc.peer_switch) ? "enabled" : "disabled")
  role_priority                                = try(local.device_config[each.key].vpc.role_priority, null)
  sys_mac                                      = try(local.device_config[each.key].vpc.system_mac, null)
  system_priority                              = try(local.device_config[each.key].vpc.system_priority, null)
  track                                        = try(local.device_config[each.key].vpc.track, null)
  virtual_ip                                   = try(local.device_config[each.key].vpc.virtual_peer_link_source, null)
  delay_peer_link_bringup                      = try(local.device_config[each.key].vpc.delay_peer_link, null)
  exclude_svi                                  = try(local.device_config[each.key].vpc.dual_active_exclude_interface_vlan, null)
  mac_bpdu_source_version_2                    = try(local.device_config[each.key].vpc.mac_address_bpdu_source_version_2, null)
  peer_gateway_exclude_vlan                    = try(local.device_config[each.key].vpc.peer_gateway_exclude_vlan, null)
  keepalive_destination_ip                     = try(local.device_config[each.key].vpc.keepalive.destination_ip, null)
  keepalive_flush_timeout                      = try(local.device_config[each.key].vpc.keepalive.hold_timeout, null)
  keepalive_interval                           = try(local.device_config[each.key].vpc.keepalive.interval, null)
  keepalive_precedence_type                    = local.vpc_keepalive[each.key].precedence_is_string ? tostring(local.vpc_keepalive[each.key].precedence_value) : null
  keepalive_precedence_value                   = local.vpc_keepalive[each.key].precedence_is_number ? tonumber(local.vpc_keepalive[each.key].precedence_value) : null
  keepalive_source_ip                          = try(local.device_config[each.key].vpc.keepalive.source_ip, null)
  keepalive_timeout                            = try(local.device_config[each.key].vpc.keepalive.timeout, null)
  keepalive_type_of_service_byte               = local.vpc_keepalive[each.key].tos_byte_value
  keepalive_type_of_service_configuration_type = local.vpc_keepalive[each.key].tos_byte_value != null ? "tos-byte" : local.vpc_keepalive[each.key].tos_is_string ? "tos-type" : local.vpc_keepalive[each.key].tos_is_number ? "tos-value" : local.vpc_keepalive[each.key].precedence_is_string ? "precedence-type" : local.vpc_keepalive[each.key].precedence_is_number ? "precedence-value" : null
  keepalive_type_of_service_type               = local.vpc_keepalive[each.key].tos_is_string ? tostring(local.vpc_keepalive[each.key].tos_value) : null
  keepalive_type_of_service_value              = local.vpc_keepalive[each.key].tos_is_number ? tonumber(local.vpc_keepalive[each.key].tos_value) : null
  keepalive_udp_port                           = try(local.device_config[each.key].vpc.keepalive.udp_port, null)
  keepalive_vrf                                = try(local.device_config[each.key].vpc.keepalive.vrf, null)
  peerlink_interface_id                        = try(local.device_config[each.key].vpc.peer_link_channel_group, null) != null ? "po${try(local.device_config[each.key].vpc.peer_link_channel_group)}" : null
  interfaces = { for int in try(local.device_config[each.key].interfaces.port_channels, []) : tostring(int.vpc_id) => {
    port_channel_interface_dn = "sys/intf/aggr-[po${int.id}]"
  } if try(int.vpc_id, null) != null }

  depends_on = [
    nxos_feature.feature,
    nxos_port_channel_interface.port_channel_interface,
  ]
}
