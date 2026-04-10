resource "nxos_spanning_tree" "spanning_tree" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].spanning_tree, null) != null ||
    length([for int in try(local.device_config[device.name].interfaces.ethernets, []) : int if try(int.spanning_tree, null) != null]) > 0 ||
  length([for int in try(local.device_config[device.name].interfaces.port_channels, []) : int if try(int.spanning_tree, null) != null]) > 0 }
  device                   = each.key
  bridge_assurance         = try(local.device_config[each.key].spanning_tree.bridge_assurance, null) != null ? (try(local.device_config[each.key].spanning_tree.bridge_assurance) ? "enabled" : "disabled") : null
  fcoe                     = try(local.device_config[each.key].spanning_tree.fcoe, null) != null ? (try(local.device_config[each.key].spanning_tree.fcoe) ? "enabled" : "disabled") : null
  l2_gateway_stp_domain_id = try(local.device_config[each.key].spanning_tree.l2_gateway_stp_domain_id, null)
  linecard_issu            = try(local.device_config[each.key].spanning_tree.linecard_issu, null)
  loopguard                = try(local.device_config[each.key].spanning_tree.loopguard, null) != null ? (try(local.device_config[each.key].spanning_tree.loopguard) ? "enabled" : "disabled") : null
  mode                     = try(local.device_config[each.key].spanning_tree.mode, null)
  pathcost_option          = try(local.device_config[each.key].spanning_tree.pathcost_method, null)
  interfaces = merge(
    { for int in try(local.device_config[each.key].interfaces.ethernets, []) : "eth${int.id}" => {
      bpdu_filter = try(int.spanning_tree.bpdufilter, null) == null ? null : (try(int.spanning_tree.bpdufilter) ? "enable" : "disable")
      bpdu_guard  = try(int.spanning_tree.bpduguard, null) == null ? null : (try(int.spanning_tree.bpduguard) ? "enable" : "disable")
      cost        = try(int.spanning_tree.cost, null)
      guard       = try(int.spanning_tree.guard, null)
      link_type   = try(int.spanning_tree.link_type, null)
      mode        = try(int.spanning_tree.port_type, null)
      priority    = try(int.spanning_tree.port_priority, null)
    } if try(int.spanning_tree, null) != null && try(int.switchport.enabled, true) },
    { for int in try(local.device_config[each.key].interfaces.port_channels, []) : "po${int.id}" => {
      bpdu_filter = try(int.spanning_tree.bpdufilter, null) == null ? null : (try(int.spanning_tree.bpdufilter) ? "enable" : "disable")
      bpdu_guard  = try(int.spanning_tree.bpduguard, null) == null ? null : (try(int.spanning_tree.bpduguard) ? "enable" : "disable")
      cost        = try(int.spanning_tree.cost, null)
      guard       = try(int.spanning_tree.guard, null)
      link_type   = try(int.spanning_tree.link_type, null)
      mode        = try(int.spanning_tree.port_type, null)
      priority    = try(int.spanning_tree.port_priority, null)
    } if try(int.spanning_tree, null) != null && try(int.switchport.enabled, true) },
  )

  depends_on = [
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
  ]
}
