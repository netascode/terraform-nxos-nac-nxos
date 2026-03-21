locals {
  pim_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device               = device.name
        vrf                  = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.ethernets.vrf, "default")
        interface_id         = "eth${int.id}"
        bfd                  = try(int.pim.bfd_instance, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.bfd_instance, null)
        dr_priority          = try(int.pim.dr_priority, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.dr_priority, null)
        passive              = try(int.pim.passive, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.passive, null)
        sparse_mode          = try(int.pim.sparse_mode, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.sparse_mode, null)
        border               = try(int.pim.border, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.border, null)
        border_router        = try(int.pim.border_router, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.border_router, null)
        dr_delay             = try(int.pim.dr_delay, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.dr_delay, null)
        join_prune_route_map = try(int.pim.jp_policy, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.jp_policy, null)
        neighbor_route_map   = try(int.pim.neighbor_policy, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.neighbor_policy, null)
        neighbor_prefix_list = try(int.pim.neighbor_policy_prefix_list, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.neighbor_policy_prefix_list, null)
        rfc_strict           = try(int.pim.strict_rfc_compliant, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.strict_rfc_compliant, null)
      } if try(int.pim, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device               = device.name
        vrf                  = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.port_channels.vrf, "default")
        interface_id         = "po${int.id}"
        bfd                  = try(int.pim.bfd_instance, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.bfd_instance, null)
        dr_priority          = try(int.pim.dr_priority, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.dr_priority, null)
        passive              = try(int.pim.passive, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.passive, null)
        sparse_mode          = try(int.pim.sparse_mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.sparse_mode, null)
        border               = try(int.pim.border, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.border, null)
        border_router        = try(int.pim.border_router, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.border_router, null)
        dr_delay             = try(int.pim.dr_delay, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.dr_delay, null)
        join_prune_route_map = try(int.pim.jp_policy, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.jp_policy, null)
        neighbor_route_map   = try(int.pim.neighbor_policy, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.neighbor_policy, null)
        neighbor_prefix_list = try(int.pim.neighbor_policy_prefix_list, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.neighbor_policy_prefix_list, null)
        rfc_strict           = try(int.pim.strict_rfc_compliant, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.strict_rfc_compliant, null)
      } if try(int.pim, null) != null],
      [for int in try(local.device_config[device.name].interfaces.loopbacks, []) : {
        device               = device.name
        vrf                  = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.loopbacks.vrf, "default")
        interface_id         = "lo${int.id}"
        bfd                  = try(int.pim.bfd_instance, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.bfd_instance, null)
        dr_priority          = try(int.pim.dr_priority, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.dr_priority, null)
        passive              = try(int.pim.passive, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.passive, null)
        sparse_mode          = try(int.pim.sparse_mode, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.sparse_mode, null)
        border               = try(int.pim.border, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.border, null)
        border_router        = try(int.pim.border_router, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.border_router, null)
        dr_delay             = try(int.pim.dr_delay, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.dr_delay, null)
        join_prune_route_map = try(int.pim.jp_policy, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.jp_policy, null)
        neighbor_route_map   = try(int.pim.neighbor_policy, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.neighbor_policy, null)
        neighbor_prefix_list = try(int.pim.neighbor_policy_prefix_list, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.neighbor_policy_prefix_list, null)
        rfc_strict           = try(int.pim.strict_rfc_compliant, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.strict_rfc_compliant, null)
      } if try(int.pim, null) != null],
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        device               = device.name
        vrf                  = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.vlans.vrf, "default")
        interface_id         = "vlan${int.id}"
        bfd                  = try(int.pim.bfd_instance, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.bfd_instance, null)
        dr_priority          = try(int.pim.dr_priority, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.dr_priority, null)
        passive              = try(int.pim.passive, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.passive, null)
        sparse_mode          = try(int.pim.sparse_mode, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.sparse_mode, null)
        border               = try(int.pim.border, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.border, null)
        border_router        = try(int.pim.border_router, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.border_router, null)
        dr_delay             = try(int.pim.dr_delay, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.dr_delay, null)
        join_prune_route_map = try(int.pim.jp_policy, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.jp_policy, null)
        neighbor_route_map   = try(int.pim.neighbor_policy, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.neighbor_policy, null)
        neighbor_prefix_list = try(int.pim.neighbor_policy_prefix_list, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.neighbor_policy_prefix_list, null)
        rfc_strict           = try(int.pim.strict_rfc_compliant, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.strict_rfc_compliant, null)
      } if try(int.pim, null) != null],
    )
  ])
  pim_interfaces_by_device_vrf = { for item in local.pim_interfaces :
    "${item.device}/${item.vrf}" => item...
  }
}

resource "nxos_pim" "pim" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].routing.pim, null) != null ||
  length([for int in local.pim_interfaces : int if int.device == device.name]) > 0 }
  device               = each.key
  admin_state          = "enabled"
  instance_admin_state = "enabled"
  evpn_border_leaf     = try(local.device_config[each.key].routing.pim.evpn_border_leaf, local.defaults.nxos.devices.configuration.routing.pim.evpn_border_leaf, null)
  extra_net            = try(local.device_config[each.key].routing.pim.extranet, local.defaults.nxos.devices.configuration.routing.pim.extranet, null)
  join_prune_delay     = try(local.device_config[each.key].routing.pim.jp_delay, local.defaults.nxos.devices.configuration.routing.pim.jp_delay, null)

  vrfs = merge(
    # Synthetic "default" VRF from process-level attributes
    {
      "default" = {
        bfd                  = try(local.device_config[each.key].routing.pim.bfd, local.defaults.nxos.devices.configuration.routing.pim.bfd, null)
        auto_enable          = try(local.device_config[each.key].routing.pim.auto_enable, local.defaults.nxos.devices.configuration.routing.pim.auto_enable, null)
        flush_routes         = try(local.device_config[each.key].routing.pim.flush_routes, local.defaults.nxos.devices.configuration.routing.pim.flush_routes, null)
        join_prune_delay     = try(local.device_config[each.key].routing.pim.jp_delay, local.defaults.nxos.devices.configuration.routing.pim.jp_delay, null)
        log_neighbor_changes = try(local.device_config[each.key].routing.pim.log_neighbor_changes, local.defaults.nxos.devices.configuration.routing.pim.log_neighbor_changes, null)
        mtu                  = try(local.device_config[each.key].routing.pim.mtu, local.defaults.nxos.devices.configuration.routing.pim.mtu, null)
        register_rate_limit  = try(local.device_config[each.key].routing.pim.register_rate_limit, local.defaults.nxos.devices.configuration.routing.pim.register_rate_limit, null)
        rfc_strict           = try(local.device_config[each.key].routing.pim.strict_rfc_compliant, local.defaults.nxos.devices.configuration.routing.pim.strict_rfc_compliant, null)
        spt_switch_graceful  = try(local.device_config[each.key].routing.pim.spt_switch_graceful, local.defaults.nxos.devices.configuration.routing.pim.spt_switch_graceful, null)

        ssm_range_group_list_1 = try(local.device_config[each.key].routing.pim.ssm.range_1, local.defaults.nxos.devices.configuration.routing.pim.ssm.range_1, null)
        ssm_range_group_list_2 = try(local.device_config[each.key].routing.pim.ssm.range_2, local.defaults.nxos.devices.configuration.routing.pim.ssm.range_2, null)
        ssm_range_group_list_3 = try(local.device_config[each.key].routing.pim.ssm.range_3, local.defaults.nxos.devices.configuration.routing.pim.ssm.range_3, null)
        ssm_range_group_list_4 = try(local.device_config[each.key].routing.pim.ssm.range_4, local.defaults.nxos.devices.configuration.routing.pim.ssm.range_4, null)
        ssm_range_prefix_list  = try(local.device_config[each.key].routing.pim.ssm.prefix_list, local.defaults.nxos.devices.configuration.routing.pim.ssm.prefix_list, null)
        ssm_range_route_map    = try(local.device_config[each.key].routing.pim.ssm.route_map, local.defaults.nxos.devices.configuration.routing.pim.ssm.route_map, null)
        ssm_range_none         = try(local.device_config[each.key].routing.pim.ssm.none, local.defaults.nxos.devices.configuration.routing.pim.ssm.none, null)

        static_rps = { for rp in try(local.device_config[each.key].routing.pim.rps, []) : rp.address => {
          group_lists = { for gl in try(rp.group_lists, [{ group_list = try(rp.group_list, local.defaults.nxos.devices.configuration.routing.pim.rps.group_list, "224.0.0.0/4") }]) :
            try(gl.group_list, gl.address, "224.0.0.0/4") => {
              bidir    = try(gl.bidir, rp.bidir, local.defaults.nxos.devices.configuration.routing.pim.rps.bidir, null)
              override = try(gl.override, rp.override, local.defaults.nxos.devices.configuration.routing.pim.rps.override, null)
            }
          }
        } }

        anycast_rp_local_interface  = try(local.device_config[each.key].routing.pim.anycast_rp_local_interface_type, local.defaults.nxos.devices.configuration.routing.pim.anycast_rp_local_interface_type, null) != null ? "${local.intf_prefix_map[try(local.device_config[each.key].routing.pim.anycast_rp_local_interface_type, local.defaults.nxos.devices.configuration.routing.pim.anycast_rp_local_interface_type)]}${try(local.device_config[each.key].routing.pim.anycast_rp_local_interface_id, local.defaults.nxos.devices.configuration.routing.pim.anycast_rp_local_interface_id, "")}" : null
        anycast_rp_source_interface = try(local.device_config[each.key].routing.pim.anycast_rp_source_interface_type, local.defaults.nxos.devices.configuration.routing.pim.anycast_rp_source_interface_type, null) != null ? "${local.intf_prefix_map[try(local.device_config[each.key].routing.pim.anycast_rp_source_interface_type, local.defaults.nxos.devices.configuration.routing.pim.anycast_rp_source_interface_type)]}${try(local.device_config[each.key].routing.pim.anycast_rp_source_interface_id, local.defaults.nxos.devices.configuration.routing.pim.anycast_rp_source_interface_id, "")}" : null

        anycast_rp_peers = { for rp in try(local.device_config[each.key].routing.pim.anycast_rps, []) :
          "${rp.address}/32;${rp.set_address}/32" => {}
        }

        interfaces = { for int in try(local.pim_interfaces_by_device_vrf["${each.key}/default"], []) : int.interface_id => {
          bfd                  = int.bfd
          dr_priority          = int.dr_priority
          passive              = int.passive
          sparse_mode          = int.sparse_mode
          border               = int.border
          border_router        = int.border_router
          dr_delay             = int.dr_delay
          join_prune_route_map = int.join_prune_route_map
          neighbor_route_map   = int.neighbor_route_map
          neighbor_prefix_list = int.neighbor_prefix_list
          rfc_strict           = int.rfc_strict
        } }
      }
    },
    # Explicit non-default VRFs
    { for vrf in try(local.device_config[each.key].routing.pim.vrfs, []) : vrf.vrf => {
      bfd                  = try(vrf.bfd, local.defaults.nxos.devices.configuration.routing.pim.vrfs.bfd, null)
      auto_enable          = try(vrf.auto_enable, local.defaults.nxos.devices.configuration.routing.pim.vrfs.auto_enable, null)
      flush_routes         = try(vrf.flush_routes, local.defaults.nxos.devices.configuration.routing.pim.vrfs.flush_routes, null)
      join_prune_delay     = try(vrf.jp_delay, local.defaults.nxos.devices.configuration.routing.pim.vrfs.jp_delay, null)
      log_neighbor_changes = try(vrf.log_neighbor_changes, local.defaults.nxos.devices.configuration.routing.pim.vrfs.log_neighbor_changes, null)
      mtu                  = try(vrf.mtu, local.defaults.nxos.devices.configuration.routing.pim.vrfs.mtu, null)
      register_rate_limit  = try(vrf.register_rate_limit, local.defaults.nxos.devices.configuration.routing.pim.vrfs.register_rate_limit, null)
      rfc_strict           = try(vrf.strict_rfc_compliant, local.defaults.nxos.devices.configuration.routing.pim.vrfs.strict_rfc_compliant, null)
      spt_switch_graceful  = try(vrf.spt_switch_graceful, local.defaults.nxos.devices.configuration.routing.pim.vrfs.spt_switch_graceful, null)

      ssm_range_group_list_1 = try(vrf.ssm.range_1, local.defaults.nxos.devices.configuration.routing.pim.vrfs.ssm.range_1, null)
      ssm_range_group_list_2 = try(vrf.ssm.range_2, local.defaults.nxos.devices.configuration.routing.pim.vrfs.ssm.range_2, null)
      ssm_range_group_list_3 = try(vrf.ssm.range_3, local.defaults.nxos.devices.configuration.routing.pim.vrfs.ssm.range_3, null)
      ssm_range_group_list_4 = try(vrf.ssm.range_4, local.defaults.nxos.devices.configuration.routing.pim.vrfs.ssm.range_4, null)
      ssm_range_prefix_list  = try(vrf.ssm.prefix_list, local.defaults.nxos.devices.configuration.routing.pim.vrfs.ssm.prefix_list, null)
      ssm_range_route_map    = try(vrf.ssm.route_map, local.defaults.nxos.devices.configuration.routing.pim.vrfs.ssm.route_map, null)
      ssm_range_none         = try(vrf.ssm.none, local.defaults.nxos.devices.configuration.routing.pim.vrfs.ssm.none, null)

      static_rps = { for rp in try(vrf.rps, []) : rp.address => {
        group_lists = { for gl in try(rp.group_lists, [{ group_list = try(rp.group_list, local.defaults.nxos.devices.configuration.routing.pim.vrfs.rps.group_list, "224.0.0.0/4") }]) :
          try(gl.group_list, gl.address, "224.0.0.0/4") => {
            bidir    = try(gl.bidir, rp.bidir, local.defaults.nxos.devices.configuration.routing.pim.vrfs.rps.bidir, null)
            override = try(gl.override, rp.override, local.defaults.nxos.devices.configuration.routing.pim.vrfs.rps.override, null)
          }
        }
      } }

      anycast_rp_local_interface  = try(vrf.anycast_rp_local_interface_type, local.defaults.nxos.devices.configuration.routing.pim.vrfs.anycast_rp_local_interface_type, null) != null ? "${local.intf_prefix_map[try(vrf.anycast_rp_local_interface_type, local.defaults.nxos.devices.configuration.routing.pim.vrfs.anycast_rp_local_interface_type)]}${try(vrf.anycast_rp_local_interface_id, local.defaults.nxos.devices.configuration.routing.pim.vrfs.anycast_rp_local_interface_id, "")}" : null
      anycast_rp_source_interface = try(vrf.anycast_rp_source_interface_type, local.defaults.nxos.devices.configuration.routing.pim.vrfs.anycast_rp_source_interface_type, null) != null ? "${local.intf_prefix_map[try(vrf.anycast_rp_source_interface_type, local.defaults.nxos.devices.configuration.routing.pim.vrfs.anycast_rp_source_interface_type)]}${try(vrf.anycast_rp_source_interface_id, local.defaults.nxos.devices.configuration.routing.pim.vrfs.anycast_rp_source_interface_id, "")}" : null

      anycast_rp_peers = { for rp in try(vrf.anycast_rps, []) :
        "${rp.address}/32;${rp.set_address}/32" => {}
      }

      interfaces = { for int in try(local.pim_interfaces_by_device_vrf["${each.key}/${vrf.vrf}"], []) : int.interface_id => {
        bfd                  = int.bfd
        dr_priority          = int.dr_priority
        passive              = int.passive
        sparse_mode          = int.sparse_mode
        border               = int.border
        border_router        = int.border_router
        dr_delay             = int.dr_delay
        join_prune_route_map = int.join_prune_route_map
        neighbor_route_map   = int.neighbor_route_map
        neighbor_prefix_list = int.neighbor_prefix_list
        rfc_strict           = int.rfc_strict
      } }
    } },
    # Create VRF entries for PIM interfaces that belong to VRFs not explicitly listed in routing.pim.vrfs
    { for vrf_key, ints in local.pim_interfaces_by_device_vrf :
      split("/", vrf_key)[1] => {
        bfd                  = null
        auto_enable          = null
        flush_routes         = null
        join_prune_delay     = null
        log_neighbor_changes = null
        mtu                  = null
        register_rate_limit  = null
        rfc_strict           = null
        spt_switch_graceful  = null

        ssm_range_group_list_1 = null
        ssm_range_group_list_2 = null
        ssm_range_group_list_3 = null
        ssm_range_group_list_4 = null
        ssm_range_prefix_list  = null
        ssm_range_route_map    = null
        ssm_range_none         = null

        static_rps = {}

        anycast_rp_local_interface  = null
        anycast_rp_source_interface = null

        anycast_rp_peers = {}

        interfaces = { for int in ints : int.interface_id => {
          bfd                  = int.bfd
          dr_priority          = int.dr_priority
          passive              = int.passive
          sparse_mode          = int.sparse_mode
          border               = int.border
          border_router        = int.border_router
          dr_delay             = int.dr_delay
          join_prune_route_map = int.join_prune_route_map
          neighbor_route_map   = int.neighbor_route_map
          neighbor_prefix_list = int.neighbor_prefix_list
          rfc_strict           = int.rfc_strict
        } }
      }
      if split("/", vrf_key)[0] == each.key &&
      !contains([for vrf in try(local.device_config[each.key].routing.pim.vrfs, []) : vrf.vrf], split("/", vrf_key)[1]) &&
      split("/", vrf_key)[1] != "default"
    }
  )

  depends_on = [
    nxos_feature.feature,
    nxos_loopback_interface.loopback_interface,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_route_policy.route_policy,
    nxos_svi_interface.svi_interface,
    nxos_vrf.vrf,
  ]
}
