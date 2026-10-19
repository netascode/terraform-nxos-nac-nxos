locals {
  pim_interface_sources = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device       = device.name
        vrf          = try(int.vrf, "default")
        interface_id = "eth${int.id}"
        pim          = int.pim
      } if try(int.pim, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device       = device.name
        vrf          = try(int.vrf, "default")
        interface_id = "po${int.id}"
        pim          = int.pim
      } if try(int.pim, null) != null],
      [for int in try(local.device_config[device.name].interfaces.loopbacks, []) : {
        device       = device.name
        vrf          = try(int.vrf, "default")
        interface_id = "lo${int.id}"
        pim          = int.pim
      } if try(int.pim, null) != null],
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        device       = device.name
        vrf          = try(int.vrf, "default")
        interface_id = "vlan${int.id}"
        pim          = int.pim
      } if try(int.pim, null) != null],
      # Subinterfaces (ethernets)
      flatten([for eth in try(local.device_config[device.name].interfaces.ethernets, []) :
        [for sub in try(eth.subinterfaces, []) : {
          device       = device.name
          vrf          = try(sub.vrf, "default")
          interface_id = "eth${eth.id}.${sub.id}"
          pim          = sub.pim
        } if try(sub.pim, null) != null]
      ]),
      # Subinterfaces (port channels)
      flatten([for pc in try(local.device_config[device.name].interfaces.port_channels, []) :
        [for sub in try(pc.subinterfaces, []) : {
          device       = device.name
          vrf          = try(sub.vrf, "default")
          interface_id = "po${pc.id}.${sub.id}"
          pim          = sub.pim
        } if try(sub.pim, null) != null]
      ]),
    )
  ])
  pim_interfaces = [for int in local.pim_interface_sources : {
    device                        = int.device
    vrf                           = int.vrf
    interface_id                  = int.interface_id
    bfd                           = try(int.pim.bfd_instance, null) == null ? null : (try(int.pim.bfd_instance) ? "enabled" : "disabled")
    dr_priority                   = try(int.pim.dr_priority, null)
    passive                       = try(int.pim.passive, null)
    sparse_mode                   = try(int.pim.sparse_mode, null)
    border                        = try(int.pim.border, null)
    dr_delay                      = try(int.pim.dr_delay, null)
    join_prune_route_map          = try(int.pim.jp_policy, null)
    neighbor_route_map            = try(int.pim.neighbor_policy, null)
    neighbor_prefix_list          = try(int.pim.neighbor_policy_prefix_list, null)
    rfc_strict                    = try(int.pim.strict_rfc_compliant, null)
    hello_interval                = try(int.pim.hello_interval, null)
    hello_authentication_type     = try(int.pim.hello_authentication_ah_md5, null) != null ? "ah-md5" : null
    hello_authentication_key      = try(int.pim.hello_authentication_ah_md5, null)
    hello_authentication_keychain = try(int.pim.hello_authentication_keychain, null)
  }]
  pim_interfaces_by_device_vrf = { for item in local.pim_interfaces :
    "${item.device}/${item.vrf}" => item...
  }

  # Per device: VRF name => VRF configuration. The default VRF is built from the
  # process-level attributes, VRFs only referenced by PIM interfaces get an empty configuration.
  pim_vrf_configs = { for device in local.devices : device.name => merge(
    { for vrf_key, ints in local.pim_interfaces_by_device_vrf : split("/", vrf_key)[1] => {} if split("/", vrf_key)[0] == device.name },
    { "default" = try(local.device_config[device.name].routing.pim, {}) },
    { for vrf in try(local.device_config[device.name].routing.pim.vrfs, []) : vrf.vrf => vrf },
  ) }
}

resource "nxos_pim" "pim" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].routing.pim, null) != null ||
  length([for int in local.pim_interfaces : int if int.device == device.name]) > 0 }
  device               = each.key
  admin_state          = null
  instance_admin_state = null
  evpn_border_leaf     = try(local.device_config[each.key].routing.pim.evpn_border_leaf, null)
  extra_net            = try(local.device_config[each.key].routing.pim.extranet, null)
  isolate              = try(local.device_config[each.key].routing.pim.isolate, null)

  vrfs = { for vrf_name, vrf in local.pim_vrf_configs[each.key] : vrf_name => {
    bfd                  = try(vrf.bfd, null)
    auto_enable          = try(vrf.auto_enable, null)
    flush_routes         = try(vrf.flush_routes, null)
    log_neighbor_changes = try(vrf.log_neighbor_changes, null)
    mtu                  = try(vrf.mtu, null)
    rfc_strict           = try(vrf.strict_rfc_compliant, null)
    spt_switch_graceful  = try(vrf.spt_switch_graceful, null)

    ssm_range_group_list_1 = try(vrf.ssm.range_1, null)
    ssm_range_group_list_2 = try(vrf.ssm.range_2, null)
    ssm_range_group_list_3 = try(vrf.ssm.range_3, null)
    ssm_range_group_list_4 = try(vrf.ssm.range_4, null)
    ssm_range_prefix_list  = try(vrf.ssm.prefix_list, null)
    ssm_range_route_map    = try(vrf.ssm.route_map, null)
    ssm_range_none         = try(vrf.ssm.none, null)

    # ip pim pre-build-spt [force] [route-map <rm> | prefix-list <pl>]
    pre_build_spt          = anytrue([try(vrf.pre_build_spt_force, null) == true, try(vrf.pre_build_spt_route_map, null) != null, try(vrf.pre_build_spt_prefix_list, null) != null]) ? true : try(vrf.pre_build_spt, null)
    pre_build_spt_force    = try(vrf.pre_build_spt_force, null)
    asm_policy_route_map   = try(vrf.pre_build_spt_route_map, null)
    asm_policy_prefix_list = try(vrf.pre_build_spt_prefix_list, null)

    # ip pim {spt-threshold infinity | use-shared-tree-only} group-list {<rm> | prefix-list <pl>}
    shared_tree_route_map                 = try(vrf.spt_threshold_infinity_group_list, vrf.use_shared_tree_only_group_list, null)
    shared_tree_prefix_list               = try(vrf.spt_threshold_infinity_group_list_prefix_list, vrf.use_shared_tree_only_group_list_prefix_list, null)
    shared_tree_use_spt_threshold_command = anytrue([try(vrf.spt_threshold_infinity_group_list, null) != null, try(vrf.spt_threshold_infinity_group_list_prefix_list, null) != null]) ? true : anytrue([try(vrf.use_shared_tree_only_group_list, null) != null, try(vrf.use_shared_tree_only_group_list_prefix_list, null) != null]) ? false : null

    sg_expiry_timer             = try(vrf.sg_expiry_timer, null)
    sg_expiry_timer_route_map   = try(vrf.sg_expiry_timer_sg_list, null)
    sg_expiry_timer_prefix_list = try(vrf.sg_expiry_timer_prefix_list, null)

    register_policy_route_map   = try(vrf.register_policy, null)
    register_policy_prefix_list = try(vrf.register_policy_prefix_list, null)
    register_policy_max_rate    = try(vrf.register_rate_limit, null)
    register_source_interface   = try(vrf.register_source_interface_type, null) != null ? "${local.intf_prefix_map[try(vrf.register_source_interface_type)]}${try(vrf.register_source_interface_id, "")}" : null

    bsr_control = anytrue([try(vrf.bsr.listen, null) != null, try(vrf.bsr.forward, null) != null]) ? join(",", compact([
      try(vrf.bsr.forward, false) ? "forward" : "",
      try(vrf.bsr.listen, false) ? "listen" : "",
    ])) : null
    bsr_candidate_source_interface    = try(vrf.bsr.bsr_candidate_interface_type, null) != null ? "${local.intf_prefix_map[try(vrf.bsr.bsr_candidate_interface_type)]}${try(vrf.bsr.bsr_candidate_interface_id, "")}" : null
    bsr_candidate_hash_length         = try(vrf.bsr.bsr_candidate_hash_len, null)
    bsr_candidate_priority            = try(vrf.bsr.bsr_candidate_priority, null)
    bsr_candidate_interval            = try(vrf.bsr.bsr_candidate_interval, null)
    bsr_rp_candidate_source_interface = try(vrf.bsr.rp_candidate_interface_type, null) != null ? "${local.intf_prefix_map[try(vrf.bsr.rp_candidate_interface_type)]}${try(vrf.bsr.rp_candidate_interface_id, "")}" : null
    bsr_rp_candidate_priority         = try(vrf.bsr.rp_candidate_priority, null)
    bsr_rp_candidate_interval         = try(vrf.bsr.rp_candidate_interval, null)
    bsr_rp_candidate_group_ranges = anytrue([try(vrf.bsr.rp_candidate_group_list, null) != null, try(vrf.bsr.rp_candidate_route_map, null) != null, try(vrf.bsr.rp_candidate_prefix_list, null) != null]) ? {
      (try(vrf.bsr.rp_candidate_bidir, false) ? "yes" : "no") = {
        group_list_1 = try(vrf.bsr.rp_candidate_group_list, null)
        route_map    = try(vrf.bsr.rp_candidate_route_map, null)
        prefix_list  = try(vrf.bsr.rp_candidate_prefix_list, null)
      }
    } : null
    bsr_policy_route_map              = try(vrf.bsr.bsr_policy, null)
    bsr_rp_candidate_policy_route_map = try(vrf.bsr.rp_candidate_policy, null)

    auto_rp_control = anytrue([try(vrf.auto_rp.listen, null) != null, try(vrf.auto_rp.forward, null) != null]) ? join(",", compact([
      try(vrf.auto_rp.forward, false) ? "forward" : "",
      try(vrf.auto_rp.listen, false) ? "listen" : "",
    ])) : null
    auto_rp_mapping_agent_source_interface = try(vrf.auto_rp.mapping_agent_interface_type, null) != null ? "${local.intf_prefix_map[try(vrf.auto_rp.mapping_agent_interface_type)]}${try(vrf.auto_rp.mapping_agent_interface_id, "")}" : null
    auto_rp_mapping_agent_scope            = try(vrf.auto_rp.mapping_agent_scope, null)
    auto_rp_rp_candidate_source_interface  = try(vrf.auto_rp.rp_candidate_interface_type, null) != null ? "${local.intf_prefix_map[try(vrf.auto_rp.rp_candidate_interface_type)]}${try(vrf.auto_rp.rp_candidate_interface_id, "")}" : null
    auto_rp_rp_candidate_scope             = try(vrf.auto_rp.rp_candidate_scope, null)
    auto_rp_rp_candidate_interval          = try(vrf.auto_rp.rp_candidate_interval, null)
    auto_rp_rp_candidate_group_ranges = anytrue([try(vrf.auto_rp.rp_candidate_group_list, null) != null, try(vrf.auto_rp.rp_candidate_route_map, null) != null, try(vrf.auto_rp.rp_candidate_prefix_list, null) != null]) ? {
      (try(vrf.auto_rp.rp_candidate_bidir, false) ? "yes" : "no") = {
        group_list_1 = try(vrf.auto_rp.rp_candidate_group_list, null)
        route_map    = try(vrf.auto_rp.rp_candidate_route_map, null)
        prefix_list  = try(vrf.auto_rp.rp_candidate_prefix_list, null)
      }
    } : null
    auto_rp_mapping_agent_policy_route_map = try(vrf.auto_rp.mapping_agent_policy, null)
    auto_rp_rp_candidate_policy_route_map  = try(vrf.auto_rp.rp_candidate_policy, null)

    # ip pim rp-address <rp> [group-list <prefix> | route-map <rm> | prefix-list <pl>] [bidir] [override]
    static_rps = length(try(vrf.rp_addresses, [])) > 0 ? { for rp in try(vrf.rp_addresses, []) : rp.address => {
      group_lists = anytrue([try(rp.route_map, null) != null, try(rp.prefix_list, null) != null]) ? null : { for gl in try(rp.group_lists, [{ group_list = try(rp.group_list, "224.0.0.0/4") }]) :
        try(gl.group_list, gl.address, "224.0.0.0/4") => {
          bidir    = try(gl.bidir, rp.bidir, null)
          override = try(gl.override, rp.override, null)
        }
      }
      group_ranges = anytrue([try(rp.route_map, null) != null, try(rp.prefix_list, null) != null]) ? {
        (try(rp.bidir, false) ? "yes" : "no") = {
          route_map   = try(rp.route_map, null)
          prefix_list = try(rp.prefix_list, null)
          override    = try(rp.override, null)
        }
      } : null
    } } : null

    anycast_rp_peers = length(try(vrf.anycast_rps, [])) > 0 ? { for rp in try(vrf.anycast_rps, []) :
      "${rp.address}/32;${rp.set_address}/32" => {}
    } : null

    interfaces = length(try(local.pim_interfaces_by_device_vrf["${each.key}/${vrf_name}"], [])) > 0 ? { for int in try(local.pim_interfaces_by_device_vrf["${each.key}/${vrf_name}"], []) : int.interface_id => {
      bfd                           = int.bfd
      dr_priority                   = int.dr_priority
      passive                       = int.passive
      sparse_mode                   = int.sparse_mode
      border                        = int.border
      dr_delay                      = int.dr_delay
      join_prune_route_map          = int.join_prune_route_map
      neighbor_route_map            = int.neighbor_route_map
      neighbor_prefix_list          = int.neighbor_prefix_list
      rfc_strict                    = int.rfc_strict
      hello_interval                = int.hello_interval
      hello_authentication_type     = int.hello_authentication_type
      hello_authentication_key      = int.hello_authentication_key
      hello_authentication_keychain = int.hello_authentication_keychain
    } } : null
  } }

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
    nxos_loopback_interface.loopback_interface,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_route_policy.route_policy,
    nxos_subinterface.subinterface,
    nxos_svi_interface.svi_interface,
    nxos_vrf.vrf,
  ]
}
