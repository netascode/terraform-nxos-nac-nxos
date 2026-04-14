resource "nxos_logging" "logging" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].logging, null) != null }
  device = each.key

  # loggingLogLevel
  all   = try(local.device_config[each.key].logging.level, null) != null ? "enableall" : null
  level = try(local.device_config[each.key].logging.level, null)
  facilities = { for facility in try(local.device_config[each.key].logging.facilities, []) : facility.name => {
    level = try(facility.level, null)
  } }

  # syslogFile
  file_admin_state          = try(local.device_config[each.key].logging.logfile_name, null) != null ? "enabled" : null
  file_name                 = try(local.device_config[each.key].logging.logfile_name, null)
  file_size                 = try(local.device_config[each.key].logging.logfile_size, null)
  file_persistent_threshold = try(local.device_config[each.key].logging.logfile_persistent_threshold, null)

  # syslogRemoteDest
  remote_destinations = { for server in try(local.device_config[each.key].logging.servers, []) : server.host => {
    admin_state                = "enabled"
    severity                   = try(server.severity, null)
    port                       = try(server.port, null)
    vrf_name                   = try(server.vrf, null)
    forwarding_facility        = try(server.facility, null)
    transport                  = try(server.transport, null)
    trustpoint_client_identity = try(server.trustpoint_client_identity, null)
  } }

  # syslogSourceInterface
  source_interface_admin_state = try(local.device_config[each.key].logging.source_interface_type, null) != null ? "enabled" : null
  source_interface_name        = try(local.device_config[each.key].logging.source_interface_type, null) != null ? "${local.intf_prefix_map[try(local.device_config[each.key].logging.source_interface_type)]}${try(local.device_config[each.key].logging.source_interface_id, "")}" : null

  # syslogTimeStamp
  timestamp_format = try(local.device_config[each.key].logging.timestamp, null)

  # syslogTermMonitor
  monitor_admin_state = try(local.device_config[each.key].logging.monitor_severity, null) != null ? "enabled" : null
  monitor_severity    = try(local.device_config[each.key].logging.monitor_severity, null)

  # syslogConsole
  console_admin_state = try(local.device_config[each.key].logging.console_severity, null) != null ? "enabled" : null
  console_severity    = try(local.device_config[each.key].logging.console_severity, null)

  # syslogOriginid
  origin_id_type  = try(local.device_config[each.key].logging.origin_id_type, null)
  origin_id_value = try(local.device_config[each.key].logging.origin_id_value, null)
}
