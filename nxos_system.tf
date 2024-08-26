resource "nxos_system" "system" {
  for_each = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.hostname, local.defaults.nxos.devices.configuration.system.hostname, null) != null }
  device   = each.key
  name     = try(local.device_config[each.value.name].system.hostname, local.defaults.nxos.devices.configuration.system.hostname)
}

resource "nxos_ethernet" "ethernet" {
  for_each = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.mtu, local.defaults.nxos.devices.configuration.system.mtu, null) != null }

  device = each.key
  mtu    = try(local.device_config[each.value.name].system.mtu, local.defaults.nxos.devices.configuration.system.mtu)
}
