resource "nxos_spanning_tree" "spanning_tree" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].spanning_tree, null) != null ||
    length([for int in try(local.device_config[device.name].interfaces.ethernets, []) : int if try(int.spanning_tree, null) != null]) > 0 ||
  length([for int in try(local.device_config[device.name].interfaces.port_channels, []) : int if try(int.spanning_tree, null) != null]) > 0 }
  device               = each.key
  instance_admin_state = "enabled"
  bridge_assurance     = try(local.device_config[each.key].spanning_tree.bridge_assurance, null) != null ? (try(local.device_config[each.key].spanning_tree.bridge_assurance) ? "enabled" : "disabled") : null
  control = length(compact([
    try(local.device_config[each.key].spanning_tree.port_type_edge_bpdufilter_default, false) ? "extchp-bpdu-filter" : "",
    try(local.device_config[each.key].spanning_tree.port_type_edge_bpduguard_default, false) ? "extchp-bpdu-guard" : "",
    try(local.device_config[each.key].spanning_tree.port_type_edge_default, false) ? "extchp-edge" : "",
    ])) > 0 ? join(",", sort(compact([
      try(local.device_config[each.key].spanning_tree.port_type_edge_bpdufilter_default, false) ? "extchp-bpdu-filter" : "",
      try(local.device_config[each.key].spanning_tree.port_type_edge_bpduguard_default, false) ? "extchp-bpdu-guard" : "",
      try(local.device_config[each.key].spanning_tree.port_type_edge_default, false) ? "extchp-edge" : "",
      "normal",
  ]))) : null
  fcoe                     = try(local.device_config[each.key].spanning_tree.fcoe, null) != null ? (try(local.device_config[each.key].spanning_tree.fcoe) ? "enabled" : "disabled") : null
  l2_gateway_stp_domain_id = try(local.device_config[each.key].spanning_tree.l2_gateway_stp_domain_id, null)
  linecard_issu            = try(local.device_config[each.key].spanning_tree.linecard_issu, null)
  loopguard                = try(local.device_config[each.key].spanning_tree.loopguard, null) != null ? (try(local.device_config[each.key].spanning_tree.loopguard) ? "enabled" : "disabled") : null
  mode                     = try(local.device_config[each.key].spanning_tree.mode, null)
  pathcost_option          = try(local.device_config[each.key].spanning_tree.pathcost_method, null)
  interfaces = merge(
    { for int in try(local.device_config[each.key].interfaces.ethernets, []) : "eth${int.id}" => {
      bpdu_filter               = try(int.spanning_tree.bpdufilter, null) == null ? null : (try(int.spanning_tree.bpdufilter) ? "enable" : "disable")
      bpdu_guard                = try(int.spanning_tree.bpduguard, null) == null ? null : (try(int.spanning_tree.bpduguard) ? "enable" : "disable")
      cost                      = try(int.spanning_tree.cost, null)
      guard                     = try(int.spanning_tree.guard, null)
      link_type                 = try(int.spanning_tree.link_type, null)
      mode                      = try(int.spanning_tree.port_type, null)
      priority                  = try(int.spanning_tree.port_priority, null)
      prestandard_configuration = try(int.spanning_tree.mst_pre_standard, null) == null ? null : (try(int.spanning_tree.mst_pre_standard) ? "enabled" : "disabled")
      simulate_pvst             = try(int.spanning_tree.mst_simulate_pvst, null) == null ? null : (try(int.spanning_tree.mst_simulate_pvst) ? "enabled" : "disabled")
    } if try(int.spanning_tree, null) != null && try(int.switchport.enabled, true) },
    { for int in try(local.device_config[each.key].interfaces.port_channels, []) : "po${int.id}" => {
      bpdu_filter               = try(int.spanning_tree.bpdufilter, null) == null ? null : (try(int.spanning_tree.bpdufilter) ? "enable" : "disable")
      bpdu_guard                = try(int.spanning_tree.bpduguard, null) == null ? null : (try(int.spanning_tree.bpduguard) ? "enable" : "disable")
      cost                      = try(int.spanning_tree.cost, null)
      guard                     = try(int.spanning_tree.guard, null)
      link_type                 = try(int.spanning_tree.link_type, null)
      mode                      = try(int.spanning_tree.port_type, null)
      priority                  = try(int.spanning_tree.port_priority, null)
      prestandard_configuration = try(int.spanning_tree.mst_pre_standard, null) == null ? null : (try(int.spanning_tree.mst_pre_standard) ? "enabled" : "disabled")
      simulate_pvst             = try(int.spanning_tree.mst_simulate_pvst, null) == null ? null : (try(int.spanning_tree.mst_simulate_pvst) ? "enabled" : "disabled")
    } if try(int.spanning_tree, null) != null && try(int.switchport.enabled, true) },
  )
  vlans = { for vlan in try(local.device_config[each.key].spanning_tree.vlans, []) : tostring(vlan.vlan_id) => {
    diameter     = try(vlan.diameter, null)
    forward_time = try(vlan.forward_time, null)
    hello_time   = try(vlan.hello_time, null)
    max_age      = try(vlan.max_age, null)
    priority     = try(vlan.priority, null) != null ? tostring(try(vlan.priority)) : null
    root_mode    = try(vlan.root, null) != null ? "enabled" : null
    root_type    = try(vlan.root, null)
  } }

  depends_on = [
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
  ]
}
