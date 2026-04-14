resource "nxos_snmp" "snmp" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].snmp, null) != null }
  device                     = each.key
  contact                    = try(local.device_config[each.key].snmp.contact, null)
  location                   = try(local.device_config[each.key].snmp.location, null)
  engine_id                  = try(local.device_config[each.key].snmp.engine_id, null)
  packet_size                = try(local.device_config[each.key].snmp.packetsize, null)
  tcp_session_authentication = try(local.device_config[each.key].snmp.tcp_session_auth, null) == null ? null : (try(local.device_config[each.key].snmp.tcp_session_auth) ? "tcpSessAuth" : "no")
  source_interface_traps     = try(local.device_config[each.key].snmp.source_interface_type, null) != null ? "${local.intf_prefix_map[try(local.device_config[each.key].snmp.source_interface_type)]}${try(local.device_config[each.key].snmp.source_interface_id, "")}" : null
  enable_all                 = try(local.device_config[each.key].snmp.enable_traps, null) == null ? null : (try(local.device_config[each.key].snmp.enable_traps) ? "yes" : "no")
  local_users = { for user in try(local.device_config[each.key].snmp.users, []) : user.name => {
    authentication_password = try(user.authentication_password, null)
    authentication_type     = try(user.authentication_type, null)
    ipv4_acl_name           = try(user.ipv4_acl, null)
    ipv6_acl_name           = try(user.ipv6_acl, null)
    enforce_privacy         = try(user.enforce_privacy, null)
    localized_v2_key        = try(user.localized_v2_key, null)
    localized_key           = try(user.localized_key, null)
    privacy_password        = try(user.privacy_password, null)
    privacy_type            = try(user.privacy_type, null)
    engine_id               = try(user.engine_id, null)
    groups                  = { for group in try(user.groups, []) : group => {} }
  } }
  hosts = { for host in try(local.device_config[each.key].snmp.hosts, []) : "${host.host};${try(host.udp_port, 162)}" => {
    community_name    = try(host.community, null)
    notification_type = try(host.notification_type, null)
    security_level    = try(host.security_level, null)
    version           = try(host.version, null)
  } }
  rmon_events = { for event in try(local.device_config[each.key].snmp.rmon_events, []) : event.number => {
    description = try(event.description, null)
    log         = try(event.log, null) == null ? null : (try(event.log) ? "yes" : "no")
    owner       = try(event.owner, null)
    trap        = try(event.trap, null)
  } }

  depends_on = [
    nxos_feature.feature,
  ]
}
