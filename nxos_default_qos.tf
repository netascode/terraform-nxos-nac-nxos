resource "nxos_default_qos" "default_qos" {
  for_each = { for device in local.devices : device.name => device
    if length(try(local.device_config[device.name].qos.class_maps, [])) > 0 ||
  length(try(local.device_config[device.name].qos.policy_maps, [])) > 0 }
  device = each.key
  class_maps = { for cm in try(local.device_config[each.key].qos.class_maps, []) : cm.name => {
    match_type = try(cm.match_type, null)
    dscp_values = { for dscp in try(cm.match_dscp_values, []) : dscp => {
    } }
  } }
  policy_maps = { for pm in try(local.device_config[each.key].qos.policy_maps, []) : pm.name => {
    match_type = try(pm.match_type, null)
    match_class_maps = { for cls in try(pm.classes, []) : cls.name => {
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
      police_conform_set_dscp       = try(cls.police.conform_set_dscp, null)
      police_conform_set_precedence = try(cls.police.conform_set_precedence, null)
      police_conform_set_qos_group  = try(cls.police.conform_set_qos_group, null)
      police_exceed_action          = try(cls.police.exceed_action, null)
      police_exceed_set_cos         = try(cls.police.exceed_set_cos, null)
      police_exceed_set_dscp        = try(cls.police.exceed_set_dscp, null)
      police_exceed_set_precedence  = try(cls.police.exceed_set_precedence, null)
      police_exceed_set_qos_group   = try(cls.police.exceed_set_qos_group, null)
      police_violate_action         = try(cls.police.violate_action, null)
      police_violate_set_cos        = try(cls.police.violate_set_cos, null)
      police_violate_set_dscp       = try(cls.police.violate_set_dscp, null)
      police_violate_set_precedence = try(cls.police.violate_set_precedence, null)
      police_violate_set_qos_group  = try(cls.police.violate_set_qos_group, null)
    } }
  } }
}
