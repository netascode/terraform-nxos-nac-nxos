locals {
  vtp_interfaces_map = { for device in local.devices : device.name =>
    merge(
      { for int in try(local.device_config[device.name].interfaces.ethernets, []) : "eth${int.id}" => {
        admin_state = try(int.vtp) ? "enabled" : "disabled"
      } if try(int.vtp, null) != null && try(int.switchport.enabled, local.default_switchport_enabled[device.name]) },
      { for int in try(local.device_config[device.name].interfaces.port_channels, []) : "po${int.id}" => {
        admin_state = try(int.vtp) ? "enabled" : "disabled"
      } if try(int.vtp, null) != null && try(int.switchport.enabled, local.default_switchport_enabled[device.name]) },
    )
  }
}

resource "nxos_vtp" "vtp" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].vtp, null) != null || length(local.vtp_interfaces_map[device.name]) > 0 }
  device               = each.key
  admin_state          = "enabled"
  instance_admin_state = "enabled"
  domain               = try(local.device_config[each.key].vtp.domain, null)
  file_path            = try(local.device_config[each.key].vtp.file, null)
  mode                 = try(local.device_config[each.key].vtp.mode, null)
  password             = try(local.device_config[each.key].vtp.password, null)
  version              = try(local.device_config[each.key].vtp.version, null)
  interfaces           = length(local.vtp_interfaces_map[each.key]) > 0 ? local.vtp_interfaces_map[each.key] : null

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
  ]
}
