locals {
  pim_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device               = device.name
        vrf                  = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.ethernets.vrf, "default")
        interface_id         = "eth${int.id}"
        bfd                  = try(int.pim.bfd_instance, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.bfd_instance, null)
        dr_priority          = try(int.pim.dr_priority, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.dr_priority, null)
        sparse_mode          = try(int.pim.sparse_mode, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.sparse_mode, null)
        border               = try(int.pim.border, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.border, null)
        dr_delay             = try(int.pim.dr_delay, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.dr_delay, null)
        join_prune_route_map = try(int.pim.jp_policy, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.jp_policy, null)
        neighbor_route_map   = try(int.pim.neighbor_policy, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.neighbor_policy, null)
        neighbor_prefix_list = try(int.pim.neighbor_policy_prefix_list, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.neighbor_policy_prefix_list, null)
        rfc_strict           = try(int.pim.rfc_strict, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.rfc_strict, null)
      } if try(int.pim, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device               = device.name
        vrf                  = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.port_channels.vrf, "default")
        interface_id         = "po${int.id}"
        bfd                  = try(int.pim.bfd_instance, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.bfd_instance, null)
        dr_priority          = try(int.pim.dr_priority, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.dr_priority, null)
        sparse_mode          = try(int.pim.sparse_mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.sparse_mode, null)
        border               = try(int.pim.border, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.border, null)
        dr_delay             = try(int.pim.dr_delay, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.dr_delay, null)
        join_prune_route_map = try(int.pim.jp_policy, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.jp_policy, null)
        neighbor_route_map   = try(int.pim.neighbor_policy, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.neighbor_policy, null)
        neighbor_prefix_list = try(int.pim.neighbor_policy_prefix_list, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.neighbor_policy_prefix_list, null)
        rfc_strict           = try(int.pim.rfc_strict, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.rfc_strict, null)
      } if try(int.pim, null) != null],
      [for int in try(local.device_config[device.name].interfaces.loopbacks, []) : {
        device               = device.name
        vrf                  = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.loopbacks.vrf, "default")
        interface_id         = "lo${int.id}"
        bfd                  = try(int.pim.bfd_instance, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.bfd_instance, null)
        dr_priority          = try(int.pim.dr_priority, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.dr_priority, null)
        sparse_mode          = try(int.pim.sparse_mode, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.sparse_mode, null)
        border               = try(int.pim.border, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.border, null)
        dr_delay             = try(int.pim.dr_delay, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.dr_delay, null)
        join_prune_route_map = try(int.pim.jp_policy, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.jp_policy, null)
        neighbor_route_map   = try(int.pim.neighbor_policy, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.neighbor_policy, null)
        neighbor_prefix_list = try(int.pim.neighbor_policy_prefix_list, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.neighbor_policy_prefix_list, null)
        rfc_strict           = try(int.pim.rfc_strict, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.rfc_strict, null)
      } if try(int.pim, null) != null],
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        device               = device.name
        vrf                  = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.vlans.vrf, "default")
        interface_id         = "vlan${int.id}"
        bfd                  = try(int.pim.bfd_instance, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.bfd_instance, null)
        dr_priority          = try(int.pim.dr_priority, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.dr_priority, null)
        sparse_mode          = try(int.pim.sparse_mode, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.sparse_mode, null)
        border               = try(int.pim.border, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.border, null)
        dr_delay             = try(int.pim.dr_delay, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.dr_delay, null)
        join_prune_route_map = try(int.pim.jp_policy, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.jp_policy, null)
        neighbor_route_map   = try(int.pim.neighbor_policy, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.neighbor_policy, null)
        neighbor_prefix_list = try(int.pim.neighbor_policy_prefix_list, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.neighbor_policy_prefix_list, null)
        rfc_strict           = try(int.pim.rfc_strict, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.rfc_strict, null)
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
    { for vrf in try(local.device_config[each.key].routing.pim.vrfs, []) : vrf.vrf => {
      bfd                  = try(vrf.bfd, local.defaults.nxos.devices.configuration.routing.pim.vrfs.bfd, null)
      flush_routes         = try(vrf.flush_routes, local.defaults.nxos.devices.configuration.routing.pim.vrfs.flush_routes, null)
      join_prune_delay     = try(vrf.jp_delay, local.defaults.nxos.devices.configuration.routing.pim.vrfs.jp_delay, null)
      log_neighbor_changes = try(vrf.log_neighbor_changes, local.defaults.nxos.devices.configuration.routing.pim.vrfs.log_neighbor_changes, null)
      register_rate_limit  = try(vrf.register_rate_limit, local.defaults.nxos.devices.configuration.routing.pim.vrfs.register_rate_limit, null)
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
        sparse_mode          = int.sparse_mode
        border               = int.border
        dr_delay             = int.dr_delay
        join_prune_route_map = int.join_prune_route_map
        neighbor_route_map   = int.neighbor_route_map
        neighbor_prefix_list = int.neighbor_prefix_list
      } }
    } },
    # Create VRF entries for PIM interfaces that belong to VRFs not explicitly listed in routing.pim.vrfs
    { for vrf_key, ints in local.pim_interfaces_by_device_vrf :
      split("/", vrf_key)[1] => {
        bfd                  = null
        flush_routes         = null
        join_prune_delay     = null
        log_neighbor_changes = null
        register_rate_limit  = null
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
          sparse_mode          = int.sparse_mode
          border               = int.border
          dr_delay             = int.dr_delay
          join_prune_route_map = int.join_prune_route_map
          neighbor_route_map   = int.neighbor_route_map
          neighbor_prefix_list = int.neighbor_prefix_list
        } }
      }
      if split("/", vrf_key)[0] == each.key &&
      !contains([for vrf in try(local.device_config[each.key].routing.pim.vrfs, []) : vrf.vrf], split("/", vrf_key)[1])
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
