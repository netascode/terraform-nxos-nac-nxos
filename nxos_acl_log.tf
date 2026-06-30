resource "nxos_acl_log" "acl_log" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].system.acl_log, null) != null }
  device = each.key

  # acllogLogCache attributes
  detailed        = try(local.device_config[each.key].system.acl_log.detailed, null)
  entries         = try(local.device_config[each.key].system.acl_log.entries, null)
  include_mac     = try(local.device_config[each.key].system.acl_log.include_mac, null)
  include_sgt     = try(local.device_config[each.key].system.acl_log.include_sgt, null)
  interval        = try(local.device_config[each.key].system.acl_log.interval, null)
  match_log_level = try(local.device_config[each.key].system.acl_log.match_log_level, null)
  threshold       = try(local.device_config[each.key].system.acl_log.threshold, null)

  depends_on = [
    nxos_feature.feature,
  ]
}
