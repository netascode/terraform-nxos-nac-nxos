locals {
  spanning_tree_mode_map = {
    "rapid-pvst" = "pvrst"
    "mst"        = "mst"
  }

  spanning_tree_interfaces_map = { for device in local.devices : device.name =>
    merge(
      { for int in try(local.device_config[device.name].interfaces.ethernets, []) : "eth${int.id}" => {
        bpdu_filter               = try(int.spanning_tree.bpdufilter, null) == null ? null : (try(int.spanning_tree.bpdufilter) ? "enable" : "disable")
        bpdu_guard                = try(int.spanning_tree.bpduguard, null) == null ? null : (try(int.spanning_tree.bpduguard) ? "enable" : "disable")
        cost                      = try(int.spanning_tree.cost, null)
        guard                     = try(int.spanning_tree.guard, null)
        link_type                 = try(int.spanning_tree.link_type, null) == "point-to-point" ? "p2p" : try(int.spanning_tree.link_type, null)
        mode                      = try(int.spanning_tree.port_type, null)
        priority                  = try(int.spanning_tree.port_priority, null)
        prestandard_configuration = try(int.spanning_tree.mst_pre_standard, null) == null ? null : (try(int.spanning_tree.mst_pre_standard) ? "enabled" : "disabled")
        simulate_pvst             = try(int.spanning_tree.mst_simulate_pvst, null) == null ? null : (try(int.spanning_tree.mst_simulate_pvst) ? "enabled" : "disabled")
        mst_instances = length(try(int.spanning_tree.mst_instances, [])) > 0 ? { for inst in try(int.spanning_tree.mst_instances, []) : tostring(inst.id) => {
          cost     = try(inst.cost, null)
          priority = try(inst.port_priority, null)
        } } : null
      } if try(int.spanning_tree, null) != null && try(int.switchport.enabled, local.default_switchport_enabled[device.name]) },
      { for int in try(local.device_config[device.name].interfaces.port_channels, []) : "po${int.id}" => {
        bpdu_filter               = try(int.spanning_tree.bpdufilter, null) == null ? null : (try(int.spanning_tree.bpdufilter) ? "enable" : "disable")
        bpdu_guard                = try(int.spanning_tree.bpduguard, null) == null ? null : (try(int.spanning_tree.bpduguard) ? "enable" : "disable")
        cost                      = try(int.spanning_tree.cost, null)
        guard                     = try(int.spanning_tree.guard, null)
        link_type                 = try(int.spanning_tree.link_type, null) == "point-to-point" ? "p2p" : try(int.spanning_tree.link_type, null)
        mode                      = try(int.spanning_tree.port_type, null)
        priority                  = try(int.spanning_tree.port_priority, null)
        prestandard_configuration = try(int.spanning_tree.mst_pre_standard, null) == null ? null : (try(int.spanning_tree.mst_pre_standard) ? "enabled" : "disabled")
        simulate_pvst             = try(int.spanning_tree.mst_simulate_pvst, null) == null ? null : (try(int.spanning_tree.mst_simulate_pvst) ? "enabled" : "disabled")
        mst_instances = length(try(int.spanning_tree.mst_instances, [])) > 0 ? { for inst in try(int.spanning_tree.mst_instances, []) : tostring(inst.id) => {
          cost     = try(inst.cost, null)
          priority = try(inst.port_priority, null)
        } } : null
      } if try(int.spanning_tree, null) != null && try(int.switchport.enabled, local.default_switchport_enabled[device.name]) },
    )
  }

  spanning_tree_mst_configuration_instances = { for device in local.devices : device.name => {
    for inst in try(local.device_config[device.name].spanning_tree.mst.configuration.instances, []) : tostring(inst.id) => inst
  } }

  spanning_tree_mst_root_instances = { for device in local.devices : device.name => {
    for inst in try(local.device_config[device.name].spanning_tree.mst.instances, []) : tostring(inst.id) => inst
  } }

  spanning_tree_mst_instances_map = { for device in local.devices : device.name => {
    for id in distinct(concat(keys(local.spanning_tree_mst_configuration_instances[device.name]), keys(local.spanning_tree_mst_root_instances[device.name]))) : id => {
      vlan_range = try(provider::utils::normalize_vlans(local.spanning_tree_mst_configuration_instances[device.name][id].vlans, "string-nxos"), null)
      diameter   = try(local.spanning_tree_mst_root_instances[device.name][id].diameter, null)
      priority   = try(local.spanning_tree_mst_root_instances[device.name][id].priority, null)
      root_mode  = try(local.spanning_tree_mst_root_instances[device.name][id].root, null) != null ? "enabled" : null
      root_type  = try(local.spanning_tree_mst_root_instances[device.name][id].root, null)
    }
  } }
}

resource "nxos_spanning_tree" "spanning_tree" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].spanning_tree, null) != null ||
    length([for int in try(local.device_config[device.name].interfaces.ethernets, []) : int if try(int.spanning_tree, null) != null]) > 0 ||
  length([for int in try(local.device_config[device.name].interfaces.port_channels, []) : int if try(int.spanning_tree, null) != null]) > 0 }
  device               = each.key
  instance_admin_state = null
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
  l2_gateway_stp_domain_id = try(local.device_config[each.key].spanning_tree.l2gateway_stp_domain_id, null)
  linecard_issu            = try(local.device_config[each.key].spanning_tree.lc_issu, null)
  loopguard                = try(local.device_config[each.key].spanning_tree.loopguard, null) != null ? (try(local.device_config[each.key].spanning_tree.loopguard) ? "enabled" : "disabled") : null
  mode                     = try(local.spanning_tree_mode_map[try(local.device_config[each.key].spanning_tree.mode)], null)
  pathcost_option          = try(local.device_config[each.key].spanning_tree.pathcost_method, null)
  mst_forward_time         = try(local.device_config[each.key].spanning_tree.mst.forward_time, null)
  mst_hello_time           = try(local.device_config[each.key].spanning_tree.mst.hello_time, null)
  mst_max_age              = try(local.device_config[each.key].spanning_tree.mst.max_age, null)
  mst_maximum_hops         = try(local.device_config[each.key].spanning_tree.mst.max_hops, null)
  mst_region_name          = try(local.device_config[each.key].spanning_tree.mst.configuration.name, null)
  mst_revision             = try(local.device_config[each.key].spanning_tree.mst.configuration.revision, null)
  mst_simulate_pvst        = try(local.device_config[each.key].spanning_tree.mst.simulate_pvst_global, null) != null ? (try(local.device_config[each.key].spanning_tree.mst.simulate_pvst_global) ? "enabled" : "disabled") : null
  mst_instances            = length(local.spanning_tree_mst_instances_map[each.key]) > 0 ? local.spanning_tree_mst_instances_map[each.key] : null
  interfaces               = length(local.spanning_tree_interfaces_map[each.key]) > 0 ? local.spanning_tree_interfaces_map[each.key] : null
  vlans = length(try(local.device_config[each.key].spanning_tree.vlans, [])) > 0 ? merge([for group in try(local.device_config[each.key].spanning_tree.vlans, []) : {
    for vlan_id in try(provider::utils::normalize_vlans(group.vlans, "list"), []) :
    tostring(vlan_id) => {
      diameter     = try(group.diameter, null)
      forward_time = try(group.forward_time, null)
      hello_time   = try(group.hello_time, null)
      max_age      = try(group.max_age, null)
      priority     = try(group.priority, null) != null ? tostring(try(group.priority)) : null
      root_mode    = try(group.root, null) != null ? "enabled" : null
      root_type    = try(group.root, null)
    }
  }]...) : null

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
  ]
}
