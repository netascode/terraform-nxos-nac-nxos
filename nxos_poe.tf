locals {
  poe_interfaces_map = { for device in local.devices : device.name => {
    for int in try(local.device_config[device.name].interfaces.ethernets, []) : "eth${int.id}" => {
      port_mode                = try(int.power_inline, null)
      max_consumption          = try(int.power_inline_max, null)
      port_default_consumption = try(int.power_inline_default_consumption, null)
      port_police              = try(int.power_inline_police_action, null)
      port_priority            = try(int.power_inline_port_priority, null)
    } if try(int.power_inline, null) != null || try(int.power_inline_max, null) != null || try(int.power_inline_default_consumption, null) != null || try(int.power_inline_police_action, null) != null || try(int.power_inline_port_priority, null) != null
  } }
}

resource "nxos_poe" "poe" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].system.logging_level_poed, null) != null || length(local.poe_interfaces_map[device.name]) > 0 }
  device               = each.key
  instance_admin_state = "enabled"
  logging_level        = try(local.device_config[each.key].system.logging_level_poed, null)
  interfaces           = length(local.poe_interfaces_map[each.key]) > 0 ? local.poe_interfaces_map[each.key] : null

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
    nxos_physical_interface.physical_interface,
  ]
}
