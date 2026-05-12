locals {
  qos_policy_interface_in_map = { for device in local.devices : device.name =>
    merge([
      for intf_type, intf_prefix in { "ethernets" = "eth", "port_channels" = "po", "vlans" = "vlan" } : {
        for int in try(local.device_config[device.name].interfaces[intf_type], []) : "${intf_prefix}${int.id}" => {
          policy_map_name       = try(int.service_policy_type_qos_input)
          policy_map_statistics = try(int.service_policy_type_qos_input_statistics, null)
        } if try(int.service_policy_type_qos_input, null) != null
      }
    ]...)
  }
}

resource "nxos_default_qos" "default_qos" {
  for_each = { for device in local.devices : device.name => device
    if length(try(local.device_config[device.name].qos.class_maps, [])) > 0 ||
    length(try(local.device_config[device.name].qos.policy_maps, [])) > 0 ||
    length([for int in try(local.device_config[device.name].interfaces.ethernets, []) : int if try(int.service_policy_type_qos_input, null) != null]) > 0 ||
    length([for int in try(local.device_config[device.name].interfaces.vlans, []) : int if try(int.service_policy_type_qos_input, null) != null]) > 0 ||
  length([for int in try(local.device_config[device.name].interfaces.port_channels, []) : int if try(int.service_policy_type_qos_input, null) != null]) > 0 }
  device = each.key
  class_maps = length(try(local.device_config[each.key].qos.class_maps, [])) > 0 ? { for cm in try(local.device_config[each.key].qos.class_maps, []) : cm.name => {
    match_type = try(cm.match_type, null)
    dscp_values = length(try(cm.match_dscp_values, [])) > 0 ? { for dscp in try(cm.match_dscp_values, []) : try(local.dscp_int_to_string_map[dscp], tostring(dscp)) => {
    } } : null
  } } : null
  policy_maps = length(try(local.device_config[each.key].qos.policy_maps, [])) > 0 ? { for pm in try(local.device_config[each.key].qos.policy_maps, []) : pm.name => {
    match_type = try(pm.match_type, null)
    match_class_maps = length(try(pm.classes, [])) > 0 ? { for cls in try(pm.classes, []) : cls.name => {
      set_qos_group_id              = try(cls.set_qos_group, null)
      police_cir_rate               = try(cls.police.cir_rate, null)
      police_cir_unit               = try(cls.police.cir_unit, null)
      police_bc_rate                = try(cls.police.bc_rate, null)
      police_bc_unit                = try(cls.police.bc_unit, null)
      police_pir_rate               = try(cls.police.pir_rate, null)
      police_pir_unit               = try(cls.police.pir_unit, null)
      police_be_rate                = try(cls.police.be_rate, null)
      police_be_unit                = try(cls.police.be_unit, null)
      police_conform_action         = try(cls.police.conform_action, null)
      police_conform_set_cos        = try(cls.police.conform_set_cos, null)
      police_conform_set_dscp       = try(tostring(cls.police.conform_set_dscp), null) != null ? try(local.dscp_int_to_string_map[cls.police.conform_set_dscp], tostring(cls.police.conform_set_dscp)) : null
      police_conform_set_precedence = try(cls.police.conform_set_precedence, null)
      police_conform_set_qos_group  = try(cls.police.conform_set_qos_group, null)
      police_exceed_action          = try(cls.police.exceed_action, null)
      police_exceed_set_cos         = try(cls.police.exceed_set_cos, null)
      police_exceed_set_dscp        = try(tostring(cls.police.exceed_set_dscp), null) != null ? try(local.dscp_int_to_string_map[cls.police.exceed_set_dscp], tostring(cls.police.exceed_set_dscp)) : null
      police_exceed_set_precedence  = try(cls.police.exceed_set_precedence, null)
      police_exceed_set_qos_group   = try(cls.police.exceed_set_qos_group, null)
      police_violate_action         = try(cls.police.violate_action, null)
      police_violate_set_cos        = try(cls.police.violate_set_cos, null)
      police_violate_set_dscp       = try(tostring(cls.police.violate_set_dscp), null) != null ? try(local.dscp_int_to_string_map[cls.police.violate_set_dscp], tostring(cls.police.violate_set_dscp)) : null
      police_violate_set_precedence = try(cls.police.violate_set_precedence, null)
      police_violate_set_qos_group  = try(cls.police.violate_set_qos_group, null)
    } } : null
  } } : null
  policy_interface_in = length(local.qos_policy_interface_in_map[each.key]) > 0 ? local.qos_policy_interface_in_map[each.key] : null
  depends_on = [
    nxos_physical_interface.physical_interface,
    nxos_svi_interface.svi_interface,
    nxos_port_channel_interface.port_channel_interface,
  ]
}
