resource "nxos_hmm" "hmm" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].system.fabric_forwarding, local.defaults.nxos.devices.configuration.system.fabric_forwarding, null) != null ||
  length([for int in try(local.device_config[device.name].interfaces.vlans, []) : int if try(int.fabric_forwarding_mode, local.defaults.nxos.devices.configuration.interfaces.vlans.fabric_forwarding_mode, null) != null]) > 0 }
  device                  = each.key
  admin_state             = "enabled"
  instance_admin_state    = "enabled"
  anycast_mac             = try(local.device_config[each.key].system.fabric_forwarding.anycast_gateway_mac, local.defaults.nxos.devices.configuration.system.fabric_forwarding.anycast_gateway_mac, null)
  administrative_distance = try(local.device_config[each.key].system.fabric_forwarding.distance, local.defaults.nxos.devices.configuration.system.fabric_forwarding.distance, null)
  control                 = try(local.device_config[each.key].system.fabric_forwarding.stateful_ha, local.defaults.nxos.devices.configuration.system.fabric_forwarding.stateful_ha, false) ? "stateful-ha" : ""
  limit_vlan_mac          = try(local.device_config[each.key].system.fabric_forwarding.limit_vlan_mac, local.defaults.nxos.devices.configuration.system.fabric_forwarding.limit_vlan_mac, null)
  selective_host_probe    = try(local.device_config[each.key].system.fabric_forwarding.selective_host_probe, local.defaults.nxos.devices.configuration.system.fabric_forwarding.selective_host_probe, false) ? "yes" : "no"
  interfaces = { for int in try(local.device_config[each.key].interfaces.vlans, []) : "vlan${int.id}" => {
    admin_state = "enabled"
    mode        = try(int.fabric_forwarding_mode, local.defaults.nxos.devices.configuration.interfaces.vlans.fabric_forwarding_mode, null)
    description = try(int.fabric_forwarding_description, local.defaults.nxos.devices.configuration.interfaces.vlans.fabric_forwarding_description, null)
  } if try(int.fabric_forwarding_mode, local.defaults.nxos.devices.configuration.interfaces.vlans.fabric_forwarding_mode, null) != null }

  depends_on = [
    nxos_feature.feature,
    nxos_svi_interface.svi_interface
  ]
}
