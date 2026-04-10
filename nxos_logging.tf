resource "nxos_logging" "logging" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].logging.level, null) != null ||
  length(try(local.device_config[device.name].logging.facilities, [])) > 0 }
  device = each.key
  all    = try(local.device_config[each.key].logging.level, null) != null ? "enableall" : null
  level  = try(local.device_config[each.key].logging.level, null)
  facilities = { for facility in try(local.device_config[each.key].logging.facilities, []) : facility.name => {
    level = try(facility.level, null)
  } }
}
