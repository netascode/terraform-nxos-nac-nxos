locals {
  queuing_random_detect_threshold_map = {
    "burst-optimized" = "burst"
    "mesh-optimized"  = "mesh"
  }
}

resource "nxos_queuing_qos" "queuing_qos" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].qos.system_service_policy_queuing_output, null) != null ||
  length(try(local.device_config[device.name].qos.queuing_policy_maps, [])) > 0 }
  device                     = each.key
  system_out_policy_map_name = try(local.device_config[each.key].qos.system_service_policy_queuing_output, null)
  policy_map_statistics      = try(local.device_config[each.key].qos.system_service_policy_queuing_output_statistics, null)
  policy_maps = length(try(local.device_config[each.key].qos.queuing_policy_maps, [])) > 0 ? { for pm in try(local.device_config[each.key].qos.queuing_policy_maps, []) : pm.name => {
    match_type = try(pm.match_type, null)
    match_class_maps = length(try(pm.classes, [])) > 0 ? { for cls in try(pm.classes, []) : cls.name => {
      priority            = try(cls.priority_level, null)
      remaining_bandwidth = try(cls.bandwidth_remaining_percent, null)
      min_threshold       = try(cls.random_detect.minimum_threshold, null)
      min_threshold_unit  = try(cls.random_detect.minimum_threshold_unit, null)
      max_threshold       = try(cls.random_detect.maximum_threshold, null)
      max_threshold_unit  = try(cls.random_detect.maximum_threshold_unit, null)
      drop_availability   = try(cls.random_detect.drop_probability, null)
      weight              = try(cls.random_detect.weight, null)
      cap_average         = try(cls.random_detect.cap_average, null)
      optimization        = try(local.queuing_random_detect_threshold_map[cls.random_detect.threshold], null)
      random_detect_ecn   = try(cls.random_detect.ecn, null)
      queue_desired       = try(cls.afd.queue_desired, null)
      queue_desired_unit  = try(cls.afd.queue_desired_unit, null)
      afd_ecn             = try(cls.afd.ecn, null)
    } } : null
  } } : null

  depends_on = [
    nxos_cli.cli_pre_9,
  ]
}
