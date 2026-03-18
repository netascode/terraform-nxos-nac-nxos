resource "nxos_spanning_tree" "spanning_tree" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].spanning_tree, null) != null ||
    length([for int in try(local.device_config[device.name].interfaces.ethernets, []) : int if try(int.spanning_tree, null) != null]) > 0 ||
  length([for int in try(local.device_config[device.name].interfaces.port_channels, []) : int if try(int.spanning_tree, null) != null]) > 0 }
  device                   = each.key
  admin_state              = try(local.device_config[each.key].spanning_tree.admin_state, local.defaults.nxos.devices.configuration.spanning_tree.admin_state, null) != null ? (try(local.device_config[each.key].spanning_tree.admin_state, local.defaults.nxos.devices.configuration.spanning_tree.admin_state) ? "enabled" : "disabled") : null
  bridge_assurance         = try(local.device_config[each.key].spanning_tree.bridge_assurance, local.defaults.nxos.devices.configuration.spanning_tree.bridge_assurance, null) != null ? (try(local.device_config[each.key].spanning_tree.bridge_assurance, local.defaults.nxos.devices.configuration.spanning_tree.bridge_assurance) ? "enabled" : "disabled") : null
  fcoe                     = try(local.device_config[each.key].spanning_tree.fcoe, local.defaults.nxos.devices.configuration.spanning_tree.fcoe, null) != null ? (try(local.device_config[each.key].spanning_tree.fcoe, local.defaults.nxos.devices.configuration.spanning_tree.fcoe) ? "enabled" : "disabled") : null
  l2_gateway_stp_domain_id = try(local.device_config[each.key].spanning_tree.l2_gateway_stp_domain_id, local.defaults.nxos.devices.configuration.spanning_tree.l2_gateway_stp_domain_id, null)
  linecard_issu            = try(local.device_config[each.key].spanning_tree.linecard_issu, local.defaults.nxos.devices.configuration.spanning_tree.linecard_issu, null)
  loopguard                = try(local.device_config[each.key].spanning_tree.loopguard, local.defaults.nxos.devices.configuration.spanning_tree.loopguard, null) != null ? (try(local.device_config[each.key].spanning_tree.loopguard, local.defaults.nxos.devices.configuration.spanning_tree.loopguard) ? "enabled" : "disabled") : null
  mode                     = try(local.device_config[each.key].spanning_tree.mode, local.defaults.nxos.devices.configuration.spanning_tree.mode, null)
  pathcost_method          = try(local.device_config[each.key].spanning_tree.pathcost_method, local.defaults.nxos.devices.configuration.spanning_tree.pathcost_method, null)
  interfaces = merge(
    { for int in try(local.device_config[each.key].interfaces.ethernets, []) : "eth${int.id}" => {
      bpdu_filter   = try(int.spanning_tree.bpdu_filter, local.defaults.nxos.devices.configuration.interfaces.ethernets.spanning_tree.bpdu_filter, null)
      bpdu_guard    = try(int.spanning_tree.bpdu_guard, local.defaults.nxos.devices.configuration.interfaces.ethernets.spanning_tree.bpdu_guard, null)
      cost          = try(int.spanning_tree.cost, local.defaults.nxos.devices.configuration.interfaces.ethernets.spanning_tree.cost, null)
      guard         = try(int.spanning_tree.guard, local.defaults.nxos.devices.configuration.interfaces.ethernets.spanning_tree.guard, null)
      link_type     = try(int.spanning_tree.link_type, local.defaults.nxos.devices.configuration.interfaces.ethernets.spanning_tree.link_type, null)
      mode          = try(int.spanning_tree.port_type, local.defaults.nxos.devices.configuration.interfaces.ethernets.spanning_tree.port_type, null)
      port_priority = try(int.spanning_tree.port_priority, local.defaults.nxos.devices.configuration.interfaces.ethernets.spanning_tree.port_priority, null)
    } if try(int.spanning_tree, null) != null },
    { for int in try(local.device_config[each.key].interfaces.port_channels, []) : "po${int.id}" => {
      bpdu_filter   = try(int.spanning_tree.bpdu_filter, local.defaults.nxos.devices.configuration.interfaces.port_channels.spanning_tree.bpdu_filter, null)
      bpdu_guard    = try(int.spanning_tree.bpdu_guard, local.defaults.nxos.devices.configuration.interfaces.port_channels.spanning_tree.bpdu_guard, null)
      cost          = try(int.spanning_tree.cost, local.defaults.nxos.devices.configuration.interfaces.port_channels.spanning_tree.cost, null)
      guard         = try(int.spanning_tree.guard, local.defaults.nxos.devices.configuration.interfaces.port_channels.spanning_tree.guard, null)
      link_type     = try(int.spanning_tree.link_type, local.defaults.nxos.devices.configuration.interfaces.port_channels.spanning_tree.link_type, null)
      mode          = try(int.spanning_tree.port_type, local.defaults.nxos.devices.configuration.interfaces.port_channels.spanning_tree.port_type, null)
      port_priority = try(int.spanning_tree.port_priority, local.defaults.nxos.devices.configuration.interfaces.port_channels.spanning_tree.port_priority, null)
    } if try(int.spanning_tree, null) != null },
  )

  depends_on = [
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
  ]
}
