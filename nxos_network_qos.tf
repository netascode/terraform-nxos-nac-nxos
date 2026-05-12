resource "nxos_network_qos" "network_qos" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].qos.system_service_policy_network_input, null) != null ||
    length(try(local.device_config[device.name].qos.network_class_maps, [])) > 0 ||
  length(try(local.device_config[device.name].qos.network_policy_maps, [])) > 0 }
  device                    = each.key
  system_in_policy_map_name = try(local.device_config[each.key].qos.system_service_policy_network_input, null)
  policy_map_statistics     = try(local.device_config[each.key].qos.system_service_policy_network_input_statistics, null)
  class_maps = length(try(local.device_config[each.key].qos.network_class_maps, [])) > 0 ? { for cm in try(local.device_config[each.key].qos.network_class_maps, []) : cm.name => {
    match_type = try(cm.match_type, null)
    cos_values = length(try(cm.match_cos_values, [])) > 0 ? { for cos in try(cm.match_cos_values, []) : cos => {
    } } : null
  } } : null
  policy_maps = length(try(local.device_config[each.key].qos.network_policy_maps, [])) > 0 ? { for pm in try(local.device_config[each.key].qos.network_policy_maps, []) : pm.name => {
    match_type = try(pm.match_type, null)
    match_class_maps = length(try(pm.classes, [])) > 0 ? { for cls in try(pm.classes, []) : cls.name => {
      mtu_value              = try(cls.mtu, null)
      pause_no_drop          = try(cls.no_drop, null)
      pause_pfc_cos_0        = try(contains(cls.pause_pfc_cos, 0), null)
      pause_pfc_cos_1        = try(contains(cls.pause_pfc_cos, 1), null)
      pause_pfc_cos_2        = try(contains(cls.pause_pfc_cos, 2), null)
      pause_pfc_cos_3        = try(contains(cls.pause_pfc_cos, 3), null)
      pause_pfc_cos_4        = try(contains(cls.pause_pfc_cos, 4), null)
      pause_pfc_cos_5        = try(contains(cls.pause_pfc_cos, 5), null)
      pause_pfc_cos_6        = try(contains(cls.pause_pfc_cos, 6), null)
      pause_pfc_cos_7        = try(contains(cls.pause_pfc_cos, 7), null)
      pause_receive          = try(cls.pause_buffer_size_receive, null)
      pause_buffer_size      = try(cls.pause_buffer_size, null)
      pause_headroom         = try(cls.pause_buffer_size_headroom, null)
      pause_dynamic          = try(cls.congestion_control_dynamic, null)
      pause_threshold        = try(cls.congestion_control_threshold, null)
      pause_resume_threshold = try(cls.congestion_control_resume_threshold, null)
      pause_resume_offset    = try(cls.congestion_control_resume_offset, null)
    } } : null
  } } : null
}
