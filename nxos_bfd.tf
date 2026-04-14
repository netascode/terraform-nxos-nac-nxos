resource "nxos_bfd" "bfd" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].bfd, null) != null }
  device               = each.key
  admin_state          = "enabled"
  instance_admin_state = "enabled"
  echo_interface       = try(local.device_config[each.key].bfd.echo_interface_type, null) != null ? "${local.intf_prefix_map[try(local.device_config[each.key].bfd.echo_interface_type)]}${try(local.device_config[each.key].bfd.echo_interface_id, "")}" : null
  hardware_offload     = try(local.device_config[each.key].bfd.hardware_offload, null) == null ? null : try(local.device_config[each.key].bfd.hardware_offload) ? "enable" : "disable"
  slow_interval        = try(local.device_config[each.key].bfd.slow_timer, null)
  startup_interval     = try(local.device_config[each.key].bfd.startup_timer, null)

  depends_on = [
    nxos_feature.feature,
  ]
}
