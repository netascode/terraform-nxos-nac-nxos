resource "nxos_queuing_qos" "queuing_qos" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].qos.system_out_queuing_policy_map, local.defaults.nxos.devices.configuration.qos.system_out_queuing_policy_map, null) != null ||
  length(try(local.device_config[device.name].qos.queuing_policy_maps, [])) > 0 }
  device                     = each.key
  system_out_policy_map_name = try(local.device_config[each.key].qos.system_out_queuing_policy_map, local.defaults.nxos.devices.configuration.qos.system_out_queuing_policy_map, null)
  policy_map_statistics      = try(local.device_config[each.key].qos.system_out_queuing_policy_map_statistics, local.defaults.nxos.devices.configuration.qos.system_out_queuing_policy_map_statistics, null)
  policy_maps = { for pm in try(local.device_config[each.key].qos.queuing_policy_maps, []) : pm.name => {
    match_type = try(pm.match_type, local.defaults.nxos.devices.configuration.qos.queuing_policy_maps.match_type, null)
    match_class_maps = { for cls in try(pm.classes, []) : cls.name => {
      next_class_map      = try(cls.next_class_map, local.defaults.nxos.devices.configuration.qos.queuing_policy_maps.classes.next_class_map, null)
      previous_class_map  = try(cls.previous_class_map, local.defaults.nxos.devices.configuration.qos.queuing_policy_maps.classes.previous_class_map, null)
      priority            = try(cls.priority, local.defaults.nxos.devices.configuration.qos.queuing_policy_maps.classes.priority, null)
      remaining_bandwidth = try(cls.remaining_bandwidth, local.defaults.nxos.devices.configuration.qos.queuing_policy_maps.classes.remaining_bandwidth, null)
    } }
  } }
}
