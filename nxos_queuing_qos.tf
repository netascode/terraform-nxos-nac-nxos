resource "nxos_queuing_qos" "queuing_qos" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].qos.system_service_policy_queuing_output, null) != null ||
  length(try(local.device_config[device.name].qos.queuing_policy_maps, [])) > 0 }
  device                     = each.key
  system_out_policy_map_name = try(local.device_config[each.key].qos.system_service_policy_queuing_output, null)
  policy_map_statistics      = try(local.device_config[each.key].qos.system_service_policy_queuing_output_statistics, null)
  policy_maps = { for pm in try(local.device_config[each.key].qos.queuing_policy_maps, []) : pm.name => {
    match_type = try(pm.match_type, null)
    match_class_maps = { for cls in try(pm.classes, []) : cls.name => {
      next_class_map      = try(cls.next_class_map, null)
      previous_class_map  = try(cls.previous_class_map, null)
      priority            = try(cls.priority_level, null)
      remaining_bandwidth = try(cls.bandwidth_remaining_percent, null)
    } }
  } }
}
